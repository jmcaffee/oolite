##############################################################################
# File::    systems_data.rb
# Purpose:: SystemsData stores info about systems
#           (ie. economy, government, etc)
#
# Author::    Jeff McAffee 05/22/2015
# Copyright:: Copyright (c) 2015, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

module Oolite
  class SystemsData
    def self.systems
      @systems ||= read_config
    end

    private

    def self.read_config
      data = Oolite.configuration.systems
      sys_objs = Hash.new

      data.each do |name, sys_data|
        sys_objs[name] = SystemData.new name, sys_data
      end

      sys_objs
    end

    def self.write_config
      Oolite.configure do |config|
        systems.each do |name, sys|
          config.systems[name] = sys.to_yaml
        end
      end

      Oolite.save_configuration
    end
  end
end
