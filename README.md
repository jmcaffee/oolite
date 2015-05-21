# Oolite

Utility scripts for monitoring the Oolite game's system markets and
providing trading suggestions based on the market data.

## Installation

If you wish to clone the repository:

    $ git clone https://github.com/jmcaffee/oolite.git
    $ cd oolite
    $ bundle

    # Use rake to install the gem
    rake install

    # To start a pry console using the local version of the gem
    rake console

Or install it yourself as:

    $ gem install oolite

## Usage

These scripts are provided as standalone utilities. Simply install
the gem as detailed above to provide the following commands:

    ooconfig - configure the scripts (ie. your save file location)
    ootrader - suggest the best trades based on current location and destination
    ooupdatemarket - update the market data (pulls from your save file)

### ooconfig

`ooconfig` displays and edits the configuration file.

The oolite scripts will look for the config file starting in your current directory
and ascending the directory tree until it reaches the root, then looks in your _home_
directory. I would suggest running your initial configuration from your home dir
so the scripts can always find the config file no matter where you call them from.

To get started, determine where your save file is located at and change to your
home directory.

    # Assuming your save file is at ~/oolite-saves/Jameson.oolite-save
    cd ~
    ooconfig save_file_path ~/oolite-saves/Jameson.oolite-save

You can see where the config file is located at by running

    ooconfig path

To see the current configuration values, run

    ooconfig show

To see available commands/options, run

    ooconfig

### ooupdatemarket

`ooupdatemarket` saves its data in the same directory as your game save file.
It also generates a `CSV` dump of the most recent market data for all visited
systems.

Note that the data is only current for the system you are located at when you
save your game. The other system data is retained from the last time you visited
the system, saved your game, and ran `ooupdatemarket`.

### ootrader

`ootrader` will ask you for your destination system based on existing data
(ie. you've visited the destination at least once, saved your game, and ran
`ooupdatemarket`), then calculate and display all profitable trades, then
display its suggested trades to make the most profit.

It uses the current market data, your available credits and max cargo space
to make its suggestions.

## About This Project

These scripts were thrown together over the course of a couple of days.
As such, the code is not the prettiest, and I'm sure it's ripe for
refactoring.

I know that there are OXPs that can perform the same functionality (and
they're in-game too!) but I'm just scratching my itch to code here.

If you find errors, please create issues in the issue tracker. If you'd like
to add additional features, fork the project and submit a pull request.

## Roadmap

* Refactor the code

## Contributing

1. Fork it ( https://github.com/[my-github-username]/oolite/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
