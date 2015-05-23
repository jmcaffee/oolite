##############################################################################
# File::    console.rb
# Purpose:: Console Module includes helper methods related to console IO
# 
# Author::    Jeff McAffee 05/22/2015
# Copyright:: Copyright (c) 2015, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

module Oolite
  module Console
    def select_system systems, header, prompt = "? "
      selected_system = choose do |menu|
        menu.index = :letter
        menu.index_suffix = " - "
        menu.header = header
        menu.prompt = prompt

        systems.each do |sys|
          info = system_info sys
          menu.choice "#{sys.ljust(14)} #{info.ljust(50)}" do sys end
        end

        menu.choice :quit do 'q' end
      end
    end

    def select_from items, header, prompt = "? "
      selected_item = choose do |menu|
        #menu.index = :number
        menu.index_suffix = " - "
        menu.header = header
        menu.prompt = prompt

        items.each do |item|
          menu.choice item do item end
        end
      end
    end
  end
end # module
