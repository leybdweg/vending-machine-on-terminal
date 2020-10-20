require 'highline'
require 'cli-console'
require_relative 'vending_machine'
require_relative 'vending_machine_ui'
require 'colorize'

loop { VendingMachineUI.new.offer_items }


