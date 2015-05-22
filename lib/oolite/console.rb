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
    def ask msg
      print "#{msg}"
      STDIN.getc
    end
  end
end # module
