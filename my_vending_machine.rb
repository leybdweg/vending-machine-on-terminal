require 'highline'
require 'cli-console'
require_relative 'vending_machine'



console = CLI::Console.new(HighLine.new)
# console.addExitCommand('exit', 'Exit from program')
# console.addAlias('quit', 'exit')

vending_machine = VendingMachine.new
loop do
  puts 'Choose which product you want:'
  item_chosen = console.getCommand(vending_machine.products.join("\n"))
  money_inserted = console.getCommand('Please pay ahead :) ')
  change = vending_machine.buy_product(item_chosen, money_inserted.to_f)
  puts change
  puts 'Thanks and please buy more   and more'
end


console.start('%s> ',[Dir.method(:pwd)])
