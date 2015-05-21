##############################################################################
# File::    market_file.rb
# Purpose:: Store market data
#
# Author::    Jeff McAffee 05/20/2015
# Copyright:: Copyright (c) 2015, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'pathname'
require 'yaml'

module Oolite
  class MarketFile
    def initialize
      Oolite.configure do |config|
        @save_file_path = Pathname(config.save_file_path)
        path = @save_file_path.dirname
        @market_data_path = path + (Pathname(config.market_data_filename).to_s + '.yml')
      end
    end

    def data
      @data ||= self.load
    end

    def data= new_data
      @data = new_data
    end

    def systems
      data.keys
    end

    def load
      if @market_data_path.nil? || @market_data_path.to_s.empty? || !@market_data_path.exist?
        Hash.new
      else
        input = YAML.load_file(@market_data_path)
        input or Hash.new
      end
    rescue
      Hash.new
    end

    def write
      raise "Missing filename" if @market_data_path.nil? || @market_data_path.to_s.empty?

      File.open(@market_data_path, 'w') do |f|
        f.write data.to_yaml
      end
    end
  end
end

