# frozen_string_literal: true
require 'yaml'
require_relative 'item_manager'
require_relative 'money'

class VendingMachine

  attr_reader :products

  def initialize
    @products = {}
    YAML.load_file('seed/products.yaml').each do |item|
      @products[item['name']] = ItemManager.new(item['name'], item['price'], item['amount'])
    end
    @funds_available = YAML.load_file('seed/machine_initial_funds.yaml')
                           .sort_by { |a| a['value'] }.reverse # strangely, it's the fastest approach
                           .map { |bill| Money.new(bill['amount'], bill['value']) }
  end

  def buy_product(product_name, bills_inserted)
    all_money_inserted = bills_inserted.sum
    return {status: :failed, message: 'product not available'} unless @products[product_name]

    return {status: :failed, message: 'not enough money'} if @products[product_name].item_price > all_money_inserted
    return {status: :failed, message: 'unable to provide correct change'} if all_money_inserted % @funds_available.last.value != 0

    # buy was accepted. If this was db, it'd start a db transaction
    bills_inserted.each do |bill|
      @funds_available.find { |money| money.value == bill}.amount += 1
    end

    # compute change and deduce from retained funds
    change_yet_to_be_given = all_money_inserted - @products[product_name].item_price
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
      if coin.value == @funds_available.last.value
        # if this was a db, a rollback would be in place
        raise 'Not enough change for operation'
      end
    end

    # remove if it's the last item
    if @products[product_name].item_amount == 1
      @products.delete(product_name)
    else
      @products[product_name].item_amount -= 1
    end

    { status: :success, message: final_change_to_s(final_change) }
  end

  def coins_accepted
    @funds_available.map(&:value)
  end

  def enough_money_to_buy_product?(product_name, money)
    @products[product_name] && @products[product_name].item_price <= money
  end

  private

  def final_change_to_s(final_change)
    return '' if final_change.empty?

    change_str = final_change.map { |change| "#{change[:amount]} coin(s) of $#{change[:coin]}"}.join("\n")
    "Here's your change: \n" + change_str
  end
end
