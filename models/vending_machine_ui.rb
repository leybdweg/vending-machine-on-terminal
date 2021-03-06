class VendingMachineUI
  attr_accessor :money_in_progress # TODO: consider changing this. seems like a bad idea

  def initialize
    @console           = CLI::Console.new(HighLine.new)
    @vending_machine   = VendingMachine.new
    @money_in_progress = []
  end

  def items_text
    @vending_machine.products.map { |_key, item| "#{item.item_name} - $#{item.item_price}" }.join("\n")
  end

  def offer_items
    puts "\n"
    puts 'Choose which product you want or exit to leave'.blue.on_light_black
    item_chosen = @console.getCommand(items_text)
    exit if item_chosen == 'exit'
    return puts 'Product N/A'.black.on_white unless @vending_machine.products[item_chosen]

    puts 'Please insert money in one of these formats: '
    ask_for_more_money(item_chosen)
    @money_in_progress = []
  end

  private

  def ask_for_more_money(item_chosen)
    money_inserted = @console.getCommand(@vending_machine.coins_accepted.join(', ')).to_f
    if @vending_machine.coins_accepted.none? money_inserted
      puts 'Coin unknown'.red
      if @console.getCommand('Want me to return your money? y/n') == 'y'
        puts "Money received so far: #{@money_in_progress}"
        @money_in_progress = []
      else
        puts "Not enough balance to buy product (#{@money_in_progress.sum}). Please add more".black.on_white
        ask_for_more_money(item_chosen)
      end
    else
      @money_in_progress.push(money_inserted)
      if @vending_machine.enough_money_to_buy_product?(item_chosen, @money_in_progress.sum)
        result = @vending_machine.buy_product(item_chosen, @money_in_progress)
        puts result[:message].blue.on_white
        result[:status]
      else
        puts "Not enough balance to buy product (#{@money_in_progress.sum}). Please add more"
        ask_for_more_money(item_chosen)
      end
    end
  end
end
