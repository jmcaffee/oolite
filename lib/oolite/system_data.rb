##############################################################################
# File::    system_data.rb
# Purpose:: SystemData stores info about a single system
#           (ie. economy, government, etc)
#
# Author::    Jeff McAffee 05/22/2015
# Copyright:: Copyright (c) 2015, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

module Oolite
  class SystemData
    attr_reader :name, :economy, :government, :tech_level

    def initialize name, data
      data = Hash(data)

      self.name = name
      self.economy = data[:economy]
      self.government = data[:government]
      self.tech_level = data[:tech_level]
    end

    def name= val
      fail "SystemData#name= name is nil" if val.nil?
      fail "SystemData#name= name is empty" if val.empty?
      @name = val
    end

    def economy= val
      if val.nil?
        @economy = ''
      else
        @economy = val
      end
    end

    def government= val
      if val.nil?
        @government = ''
      else
        @government = val
      end
    end

    def tech_level= val
      if val.nil?
        @tech_level = ''
      else
        @tech_level = val
      end
    end

    #
    # When emitting as YAML, emit as a hash
    #

    def to_yaml
      {
        economy: @economy,
        government: @government,
        tech_level: @tech_level,
      }
    end
  end
end
