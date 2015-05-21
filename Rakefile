require "bundler/gem_tasks"

desc 'start a console'
task :console do
  require 'pry'
  $LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
  require 'oolite'
  ARGV.clear

  def console_help
    puts <<CONSOLE_HELP
 CONSOLE HELP
-------------

Starts a pry console and requires the *local* version of Oolite.

  Search and load the Oolite configuration (defaults will be set if
  no configuration file is found)

    Oolite.configure

  OR

    Oolite.configure do |config|
      config.some_setting = some_value
    end

  After a configuration has been instantiated, you can retrieve the
  current configuration with

    Oolite.configuration


CONSOLE_HELP
  end

  console_help
  Pry.start
end

