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
    def display
      puts "= Oolite Trader ="
      puts
      puts "  Current Location: #{current_system_name}"
      puts
      puts "  Available destinations:"
      puts

      systems = market.systems
      systems.delete current_system_name
      systems.each_with_index do |sys,i|
        puts "      #{i} - #{sys}"
      end
      puts
      choice = ask "    Choose your destination (q to abort): "

      return if choice.downcase == 'q'
      puts

      dest_system = systems[choice.to_i]

      puts "  -- Suggested Trades (best to worst) for #{dest_system} --"
      puts
      puts "    #{'Item'.ljust(14)} #{'Amt Avail'.to_s.ljust(10)} #{'PricePerUnit'.to_s.rjust(8)} #{'ProfitPerUnit'.to_s.rjust(12)}"
      puts

      avail_trades = all_trades(dest_system)
      avail_trades.each do |trade|
        puts "    " + trade.to_s
      end

      puts

      puts "  -- Suggested Transactions for #{dest_system} --"
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

    def ask msg
      print "#{msg}"
      val = STDIN.getc
    end

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

    def calculate_all_trades dest_system
      src = market.data[current_system_name]
      dest = market.data[dest_system]

      # Remove contraband if configured.
      if Oolite.configuration.trade_contraband == false
        Oolite.configuration.contraband.each do |contr|
          src.delete contr
        end
      end

      positive_trades = Array.new

      src.keys.each do |item|
        sprice = src[item][:price]
        amount = src[item][:amount]
        dprice = dest[item][:price]

        revenue = dprice - sprice
        if revenue > 0.0 && amount > 0
          positive_trades << TradeItem.new(item, amount, sprice, revenue)
        end
      end

      positive_trades.sort { |a,b| b.revenue <=> a.revenue }
    end

    def calc_best_trades trades
      avail_cargo = Oolite.configuration.cargo
      credits = Oolite.configuration.current_credits

      if avail_cargo <= 0
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

      balance = credits
      cargo = avail_cargo
      suggested_trades_expensive_first = []
      affordable_trades.each do |trade|
        max_amt_by_price = balance / trade.cost
        max_amt_by_cargo = [cargo, trade.amount].min
        max_amt = [max_amt_by_price, max_amt_by_cargo].min

        balance = balance - (max_amt * trade.cost)
        cargo = cargo - max_amt

        if max_amt > 0
          transaction = { item: trade, amount: max_amt }
          suggested_trades_expensive_first << transaction.dup
        end
      end

      expensive_first_total_profit = 0
      suggested_trades_expensive_first.each do |transaction|
        profit = transaction[:item].revenue * transaction[:amount]
        expensive_first_total_profit += profit
      end

      balance = credits
      cargo = avail_cargo
      suggested_trades_cheap_first = []
      # Sort the trades in ascending order.
      cheap_affordable_trades = affordable_trades.sort { |a,b| a.revenue <=> b.revenue }
      cheap_affordable_trades.each do |trade|
        max_amt_by_price = balance / trade.cost
        max_amt_by_cargo = [cargo, trade.amount].min
        max_amt = [max_amt_by_price, max_amt_by_cargo].min

        balance = balance - (max_amt * trade.cost)
        cargo = cargo - max_amt

        if max_amt > 0
          transaction = { item: trade, amount: max_amt }
          suggested_trades_cheap_first << transaction.dup
        end
      end

      cheap_first_total_profit = 0
      suggested_trades_cheap_first.each do |transaction|
        profit = transaction[:item].revenue * transaction[:amount]
        cheap_first_total_profit += profit
      end

      if expensive_first_total_profit > cheap_first_total_profit
        return [suggested_trades_expensive_first, expensive_first_total_profit]
      else
        return [suggested_trades_cheap_first, cheap_first_total_profit]
      end
    end
  end
end

