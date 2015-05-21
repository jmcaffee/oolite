require "oolite/version"

if ENV['DEBUG'].nil?
  $debug = false
else
  $debug = true
end

module Oolite
  CONFIG_FILE_NAME = '.oolite'

  class << self
    attr_accessor :configuration
  end

  ##
  # Setup oolite configuration
  #
  # Attempts to find and load a configuration file the first time
  # it's requested. If a config file cannot be found in the current
  # directory tree (moving towards trunk, not the leaves), the user's
  # home directory will be searched. If still not found, a default
  # configuration object is created.
  #
  # If a block is provided, the configuration object is yielded to the block
  # after the configuration is loaded/created.
  #

  def self.configure
    if self.configuration.nil?
      unless self.load_configuration
        self.configuration = Configuration.new
      end
    end
    yield(configuration) if block_given?
  end

  ##
  # Walk up the directory tree from current working dir (pwd) till a file
  # named .oolite is found
  #
  # Returns file path if found, nil if not.
  #

  def self.find_config_path
    path = Pathname(Pathname.pwd).ascend{|d| h=d+CONFIG_FILE_NAME; break h if h.file?}
    if path.nil? && (Pathname(ENV['HOME']) + CONFIG_FILE_NAME).exist?
      path = Pathname(ENV['HOME']) + CONFIG_FILE_NAME
    end
    path
  end

  ##
  # Write configuration to disk
  #
  # Writes to current working dir (pwd) if path is nil
  #
  # Returns path of emitted file
  #

  def self.save_configuration(path = nil)
    # If no path provided, see if we can find one in the dir tree.
    if path.nil?
      path = find_config_path
    end

    # Still no path? Use the current working dir.
    if path.nil?
      path = Pathname.pwd
    end

    unless path.to_s.end_with?('/' + CONFIG_FILE_NAME)
      path = Pathname(path) + CONFIG_FILE_NAME
    end

    path = Pathname(path).expand_path
    File.write(path, YAML.dump(configuration))

    path
  end

  ##
  # Load the configuration from disk
  #
  # Returns true if config file found and loaded, false otherwise.
  #

  def self.load_configuration(path = nil)
    # If no path provided, see if we can find one in the dir tree.
    if path.nil?
      path = find_config_path
    end

    return false if path.nil?
    return false unless Pathname(path).exist?

    File.open(path, 'r') do |f|
      self.configuration = YAML.load(f)
      puts "configuration loaded from #{path}" if $debug
    end

    true
  end

  class Configuration
    attr_accessor :save_file_path
    attr_accessor :market_data_filename
    attr_accessor :current_system_name
    attr_accessor :current_credits
    attr_accessor :cargo
    attr_accessor :trade_contraband
    attr_accessor :contraband
    attr_accessor :economies
    attr_accessor :governments
    attr_accessor :systems


    def initialize
      reset
    end

    def reset
      @save_file_path = ''

      @market_data_filename = 'oolite.market'

      @current_system_name = ''
      @current_credits = 0
      @cargo = 0

      @trade_contraband = false

      @contraband = [
        "Slaves",
        "Narcotics",
        "Firearms",
      ]

      @economies = [
        "Rich Industrial",
        "Average Industrial",
        "Poor Industrial",
        "Mainly Industrial",
        "Mainly Agricultural",
        "Rich Agricultural",
        "Average Agricultural",
        "Poor Agricultural"
      ]

      @governments = [
        "Anarchy",
        "Feudal",
        "Multi-Government",
        "Dictatorship",
        "Communist",
        "Confederacy",
        "Democracy",
        "Corporate State"
      ]

      @systems = Hash.new
    end

    ##
    # Control which instance vars are emitted when dumped to YAML.
    #   Example - not used at this time.
    #

    def encode_with(coder)
      vars = instance_variables.map { |x| x.to_s }
      vars = vars - ["@dummy"]

      vars.each do |var|
        var_val = eval(var)
        coder[var.gsub('@', '')] = var_val
      end
    end
  end # Configuration
end

require 'yaml'

# Initialize the configuration
Oolite.configure

require 'oolite/csv_doc'
require 'oolite/save_file'
require 'oolite/market_file'
require 'oolite/market'
require 'oolite/trade'

