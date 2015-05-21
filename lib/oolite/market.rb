##############################################################################
# File::    market.rb
# Purpose:: Write out a market data file
#
# Author::    Jeff McAffee 05/19/2015
# Copyright:: Copyright (c) 2015, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'pathname'
require 'yaml'

module Oolite
  class Market
    def initialize
      Oolite.configure do |config|
        @save_file_path = Pathname(config.save_file_path)
        path = @save_file_path.dirname
        @market_data_path = path + (Pathname(config.market_data_filename).to_s + '.yml')
        @market_data_csv = path + (Pathname(config.market_data_filename).to_s + '.csv')
      end
    end

    def update filename = nil
      filename ||= @save_file_path

      savefile = SaveFile.new filename

      add_credits_to_config savefile.credits
      add_cargo_to_config savefile.cargo

      system_name = savefile.current_system_name
      add_system_to_config system_name
      puts "Updating data for #{system_name} system"

      data[system_name] = savefile.local_market_data

      write_data_file
    end

    def upgrade
      mf = MarketFile.new
      old_data = mf.data

      old_data.each do |key, d|
        updated_hash = Hash.new
        d.each do |item, price|
          if price.class == Hash
            updated_hash[item] = price
          else
            updated_hash[item] = { price: price, amount: 0 }
          end
        end

        data[key] = updated_hash
      end

      write_data_file
    end

    def upgrade_price
      mf = MarketFile.new
      old_data = mf.data

      old_data.each do |key, d|
        updated_hash = Hash.new
        d.each do |item, info|
          updated_hash[item] = { price: (info[:price] * 10).to_i, amount: info[:amount] }
        end

        data[key] = updated_hash
      end

      write_data_file
    end

    def write_csv filename = nil
      filename ||= @market_data_csv
      csv_doc = CSVDoc.new
      format_data csv_doc
      csv_doc.write filename

      puts "CSV file written to #{filename}"
    end

    private

    def data
      @data ||= MarketFile.new.data
    end

    def write_data_file
      mf = MarketFile.new
      mf.data = data
      mf.write
    end

    def format_data csv_doc
      line = Array.new
      line << ''
      line = line + data.keys
      csv_doc.add line

      data[data.keys.first].keys.each do |type|
        line = Array(type)
        data.each do |location, local_data|
          line << (local_data[type][:price] / 10.0).to_s
        end
        csv_doc.add line
      end
    end

    def add_system_to_config system
      Oolite.configure do |config|
        config.current_system_name = system

        unless config.systems.key?(system)
          details = { economy: '',
                      government: '',
                      tech_level: '',
          }
          config.systems[system] = details
        end
      end
      Oolite.save_configuration
    end

    def add_credits_to_config credits
      Oolite.configure do |config|
        config.current_credits = credits
      end
      Oolite.save_configuration
    end

    def add_cargo_to_config cargo
      Oolite.configure do |config|
        config.cargo = cargo
      end
      Oolite.save_configuration
    end
  end
end

