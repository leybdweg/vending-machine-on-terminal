# frozen_string_literal: true
require 'yaml'

class VendingMachine

  def initialize
    @products        = YAML.load_file('products.yaml')
    @funds_available = YAML.load_file('change.yaml').sort { |a, b| a['value'] <=> b['value'] }.reverse
    @total_funds     = @funds_available.reduce(0) { |result, current| result + (current['value'] * current['amount']) }
  end

  def buy_product(product_name, money_inserted)
    desired_product = @products.find { |product| product['name'] == product_name }
    unless desired_product
      return { status: :failed, message: 'product not available' }
    end

    if desired_product['price'] > money_inserted
      return { status: :failed, message: 'not enough money' }
    end
    if desired_product['price'] % @funds_available.last['value'] != 0
      return { status: :failed, message: 'unable to provide correct change' }
    end


    @products.delete { |product| product['name'] == product_name }

    change_yet_to_be_given = money_inserted - desired_product['value']
    final_change = []
    @funds_available.each do |coin|
      money_in_this_value = change_yet_to_be_given / coin['value']
      amount = money_in_this_value.to_i < coin['amount'] ? money_in_this_value.to_i : coin['amount']
      change_yet_to_be_given -= amount * coin['value']
      if amount.positive?
        final_change.push(coin: coin['value'], amount: amount)
        coin['amount'] -= amount
      end

      break if change_yet_to_be_given.zero?
    end

  end

end
