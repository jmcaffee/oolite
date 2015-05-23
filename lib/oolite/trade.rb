##############################################################################
# File::    trade.rb
# Purpose:: Determine the best trades based on current location and the next
#           destination
#
# Author::    Jeff McAffee 05/20/2015
# Copyright:: Copyright (c) 2015, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'pathname'
require 'yaml'

module Oolite
  class Trade
    include Console

    def systems_data
      @systems_data ||= SystemsData
    end

    def system_info sys_name
        info = ''
        if systems_data.names.include? sys_name
          sys_data = systems_data.systems[sys_name]

          econ = sys_data.economy
          gov = sys_data.government
          tech = sys_data.tech_level

          info = "(#{econ} - #{gov} - #{tech.to_s})"
        end
        info
    end

    def ask_user_to_update_system_data sys_name
      need_update = false
      need_update = true if !systems_data.names.include? sys_name
      unless need_update
        sys_data = systems_data.systems[sys_name]
        need_update = true if !sys_data.all_data_present?
      end

      return unless need_update

      if need_update
        puts "We need to update our records for #{sys_name}"
        result = ask("Would you like to update now (y/n)? ") { |q| q.default = 'y' }
        return if result.downcase == 'n'
      end

      collect_system_data sys_name
    end

    def collect_system_data sys_name
      econs = Oolite.configuration.economies
      govs = Oolite.configuration.governments
      prompt = ' Choice? '

      puts "  #{sys_name}"

      puts
      econ = select_from econs, 'Economy', prompt

      puts
      gov = select_from govs, 'Government', prompt

      puts
      puts "Tech Level:"
      puts
      tech_level = ask " Choice (1-12)? "

      sys_data = SystemData.new sys_name, {}
      sys_data.economy = econ
      sys_data.government = gov
      sys_data.tech_level = tech_level

      SystemsData.add sys_data

      puts
      puts " #{sys_name} has been updated."
      puts
    end

    def get_destination
      systems = market.systems
      systems.delete current_system_name
      systems.sort!

      select_system systems, "Available destinations", "Choose your destination: "
    end

    def display
      puts "= Oolite Trader ="
      puts
      ask_user_to_update_system_data current_system_name

      puts
      puts "  Current Location: #{current_system_name} #{system_info(current_system_name)}"
      puts

      dest_system = get_destination

      return if dest_system == 'q'

      puts
      puts "  -- Profitable Trades for #{dest_system} --"
      puts
      puts "    #{'Item'.ljust(14)} #{'Amt Avail'.to_s.ljust(10)} #{'PricePerUnit'.to_s.rjust(8)} #{'ProfitPerUnit'.to_s.rjust(12)}"
      puts

      avail_trades = all_trades(dest_system)
      avail_trades.each do |trade|
        puts "    " + trade.to_s
      end

      puts

      puts "  -- Suggested Transactions for #{current_system_name} to #{dest_system} Route --"
      puts
      puts "    #{'Item'.ljust(14)} #{'Purch Amt'.to_s.ljust(10)} #{'Profit'.to_s.rjust(8)}"
      puts

      trans, total_profit = calc_best_trades avail_trades
      trans.each do |tran|
        name = tran[:item].name
        revenue = tran[:item].revenue
        amount = tran[:amount]
        profit = revenue * amount

        puts "    #{name.ljust(14)} #{amount.to_s.ljust(10)} #{(profit / 10.0).to_s.rjust(8)}"
      end

      puts
      puts "Total Profit: #{(total_profit / 10.0).to_s}"
      puts

    end

    private

    def current_system_name
      Oolite.configuration.current_system_name
    end

    def market
      if @market.nil?
        @market = MarketFile.new
        @market.data
      end
      @market
    end

    def all_trades dest_system
      calculate_all_trades dest_system
    end

    class TradeItem
      attr_accessor :name
      attr_accessor :amount
      attr_accessor :cost
      attr_accessor :revenue

      def initialize name, amount, cost, revenue
        @name = name
        @amount = amount
        @cost = cost
        @revenue = revenue
      end

      def to_s
        "#{name.ljust(14)} #{amount.to_s.ljust(10)} #{(cost / 10.0).to_s.rjust(8)} #{(revenue / 10.0).to_s.rjust(12)}"
      end
    end

    #
    # Calculate and return all *profitable* trades.
    #
    # Returned trades are sorted most expensive to least
    #

    def calculate_all_trades dest_system
      src = market.data[current_system_name]
      dest = market.data[dest_system]

      # Remove contraband if configured.
      if Oolite.configuration.trade_contraband == false
        Oolite.configuration.contraband.each do |contr|
          src.delete contr
        end
      end

      profitable_trades = Array.new

      src.keys.each do |item|
        sprice = src[item][:price]
        amount = src[item][:amount]
        dprice = dest[item][:price]

        revenue = dprice - sprice
        if revenue > 0.0 && amount > 0
          profitable_trades << TradeItem.new(item, amount, sprice, revenue)
        end
      end

      profitable_trades.sort { |a,b| b.revenue <=> a.revenue }
    end

    #
    # Calculate the most profitable trades.
    #
    # We calculate 2 ways, buying the most expensive (and generally the
    # most profitable) trades, then buying the cheapest first. The most
    # profit determines the suggested trades.
    #

    def calc_best_trades trades
      max_cargo = Oolite.configuration.cargo
      credits = Oolite.configuration.current_credits

      if max_cargo <= 0
        return [[], 0]
      end

      affordable_trades = []
      trades.each do |trade|
        if trade.cost <= credits
          affordable_trades << trade
        end
      end

      if affordable_trades.count <= 0
        return [[], 0]
      end

      suggested_trades_exp = calc_trades(credits, max_cargo, affordable_trades)
      total_profit_exp = calc_total_profit(suggested_trades_exp)

      # Sort the trades in ascending order (cheapest first).
      affordable_trades_asc = affordable_trades.sort { |a,b| a.revenue <=> b.revenue }

      suggested_trades_cheap = calc_trades(credits, max_cargo, affordable_trades_asc)
      total_profit_cheap = calc_total_profit(suggested_trades_cheap)

      if total_profit_exp > total_profit_cheap
        return [suggested_trades_exp, total_profit_exp]
      else
        return [suggested_trades_cheap, total_profit_cheap]
      end
    end

    #
    # Calculate the best trades using available credits, cargo and profitable trades
    #

    def calc_trades credits, cargo, trades
      suggested_trades = []

      trades.each do |trade|
        # We're limited by how much we can buy,
        max_amt_by_price = credits / trade.cost
        # and cargo space versus amount for sale.
        max_amt_by_cargo = [cargo, trade.amount].min
        max_amt = [max_amt_by_price, max_amt_by_cargo].min

        credits = credits - (max_amt * trade.cost)
        cargo = cargo - max_amt

        if max_amt > 0
          transaction = { item: trade, amount: max_amt }
          suggested_trades << transaction.dup
        end
      end

      suggested_trades
    end

    #
    # Calculate the total anticipated profit if all trades are transacted.
    #

    def calc_total_profit trades
      total_profit = 0

      trades.each do |transaction|
        profit = transaction[:item].revenue * transaction[:amount]
        total_profit += profit
      end

      total_profit
    end
  end
end

