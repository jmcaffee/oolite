##############################################################################
# File::    csv_doc.rb
# Purpose:: CSVDoc class for emitting formatted CSV documents
#
# Author::    Jeff McAffee 05/19/2015
# Copyright:: Copyright (c) 2015, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################


module Oolite
  class CSVDoc
    def lines
      @lines ||= Array.new
    end

    def add line = []
      new_line = Array.new

      Array(line).each do |elem|
        if elem.include?(',')
          # Quote element if it contains a comma
          new_line << "\"#{elem}\""
        else
          new_line << elem
        end
      end

      lines << new_line
    end

    def write filepath
      pad_lines
      output_lines = Array.new
      lines.each do |line|
        output_lines << line.join(',')
      end

      File.open(filepath, 'w') do |f|
        f.write(output_lines.join("\n"))
      end
    end

    def pad_lines
      max = 0
      lines.each do |line|
        len = line.count
        if len > max
          max = len
        end
      end

      padded_lines = Array.new
      lines.each do |line|
        if line.count < max
          pads = max = line.count
          pads.times.each do
            line << ''
          end
        end
        padded_lines << line
      end

      @lines = padded_lines
    end
  end
end

