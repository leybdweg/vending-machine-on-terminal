# frozen_string_literal: true
require 'yaml'

class VendingMachine

  def initialize
    @products        = YAML.load_file('products.yaml')
    @funds_available = YAML.load_file('machine_initial_funds.yaml').sort { |a, b| a['value'] <=> b['value'] }.reverse
    @total_funds     = @funds_available.reduce(0) { |result, current| result + (current['value'] * current['amount']) }
  end

  def buy_product(product_name, money_inserted) #, bills_inserted)
    # money_inserted = bills_inserted.sum { |bill| bill['amount'] * bill['value']}
    desired_product_ix = @products.index { |product| product['name'] == product_name }
    return {status: :failed, message: 'product not available'} unless @products[desired_product_ix]

    return {status: :failed, message: 'not enough money'} if @products[desired_product_ix]['price'] > money_inserted
    return {status: :failed, message: 'unable to provide correct change'} if money_inserted % @funds_available.last['value'] != 0

    # buy was accepted. If this was db, it'd start a db transaction

    # remove if it's the last item
    @products[desired_product_ix]['amount'] == 1 ? @products.delete_at(desired_product_ix) : @products[desired_product_ix]['amount'] -= 1

    # compute change and deduce from retained funds
    change_yet_to_be_given = money_inserted - @products[desired_product_ix]['price']
    final_change = []
    @funds_available.each do |coin|
      bills_to_be_deduced = change_yet_to_be_given / coin['value']
      amount = bills_to_be_deduced.to_i < coin['amount'] ? bills_to_be_deduced.to_i : coin['amount']
      change_yet_to_be_given -= amount * coin['value']
      if amount.positive?
        final_change.push(coin: coin['value'], amount: amount)
        coin['amount'] -= amount
      end

      break if change_yet_to_be_given.zero?
    end

    final_change
  end

end
