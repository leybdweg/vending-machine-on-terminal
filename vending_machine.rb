# frozen_string_literal: true
require 'yaml'
require_relative 'item_manager'
require_relative 'money'

class VendingMachine
  # include ItemManager

  def initialize
    @products        = YAML.load_file('products.yaml').map { |item| ItemManager.new(item['name'], item['price'], item['amount']) }
    @funds_available = YAML.load_file('machine_initial_funds.yaml')
                           .sort { |a, b| a['value'] <=> b['value'] }.reverse
                           .map { |bill| Money.new(bill['amount'], bill['value']) }
  end

  def buy_product(product_name, money_inserted)
    #, bills_inserted)
    # money_inserted = bills_inserted.sum { |bill| bill['amount'] * bill['value']}
    desired_product_ix = @products.index { |item| item.item_name == product_name }
    return {status: :failed, message: 'product not available'} unless @products[desired_product_ix]

    return {status: :failed, message: 'not enough money'} if @products[desired_product_ix].item_price > money_inserted
    return {status: :failed, message: 'unable to provide correct change'} if money_inserted % @funds_available.last.value != 0

    # buy was accepted. If this was db, it'd start a db transaction

    # remove if it's the last item
    @products[desired_product_ix].item_amount == 1 ? @products.delete_at(desired_product_ix) : @products[desired_product_ix].item_amount -= 1

    # compute change and deduce from retained funds
    change_yet_to_be_given = money_inserted - @products[desired_product_ix].item_price
    final_change           = []
    @funds_available.each do |coin|
      bills_to_be_deduced    = change_yet_to_be_given / coin.value
      amount                 = bills_to_be_deduced.to_i < coin.amount ? bills_to_be_deduced.to_i : coin.amount
      change_yet_to_be_given -= amount * coin.value
      if amount.positive?
        final_change.push(coin: coin.value, amount: amount)
        coin.amount -= amount
      end

      break if change_yet_to_be_given.zero?
    end

    # TODO: inserted money not being adding up to balance
    final_change_to_s(final_change)
  end

  def products
    @products.map { |item| "#{item.item_name} - $#{item.item_price}"}
  end

  def final_change_to_s(final_change)
    str = "Here's your change: \n"
    str + final_change.map { |change| "#{change[:amount]} of $#{change[:coin]}"}.join("\n")
  end
end
