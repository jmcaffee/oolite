##############################################################################
# File::    save_file.rb
# Purpose:: Parse the Oolite save file
#
# Author::    Jeff McAffee 05/19/2015
# Copyright:: Copyright (c) 2015, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'pathname'
require 'nokogiri'

module Oolite
  class SaveFile
    def initialize filename
      parse filename
    end

    def parse filename
      raise "Cannot find save file #{filename}" unless Pathname(filename).exist?

      @doc = Nokogiri::XML(File.open(filename)) do |config|
        config.noblanks
      end
    end

    def current_system_name
      node = get_data_node_for_key 'current_system_name'
      node.text
    end

    def cargo
      node = get_data_node_for_key 'max_cargo'
      node.text.to_i
    end

    def credits
      node = get_data_node_for_key 'credits'
      node.text.to_i
    end

    def local_market_data
      node = get_data_node_for_key 'localMarket'

      mdata = {}

      node.children.each do |child|
        type = child.children[0].text
        amount = child.children[1].text.to_i
        # Price is stored as an integer and displayed as price / 10.
        price = child.children[2].text.to_i
        mdata[type] = { amount: amount, price: price }
      end

      mdata
    end

    private

    def get_data_node_for_key key
      @doc.css('dict').children.each do |node|
        if node.name == 'key' && node.text == key
          return node.next
        end
      end

      raise "No data found for key #{key}"
    end
  end
end

