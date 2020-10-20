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

  def buy_product(product_name, bills_inserted)
    all_money_inserted = bills_inserted.sum
    desired_product_ix = @products.index { |item| item.item_name == product_name }
    return {status: :failed, message: 'product not available'} unless @products[desired_product_ix]

    return {status: :failed, message: 'not enough money'} if @products[desired_product_ix].item_price > all_money_inserted
    return {status: :failed, message: 'unable to provide correct change'} if all_money_inserted % @funds_available.last.value != 0

    # buy was accepted. If this was db, it'd start a db transaction
    bills_inserted.each do |bill|
      @funds_available.find { |money| money.value == bill}.amount += 1
    end

    # remove if it's the last item
    @products[desired_product_ix].item_amount == 1 ? @products.delete_at(desired_product_ix) : @products[desired_product_ix].item_amount -= 1

    # compute change and deduce from retained funds
    change_yet_to_be_given = all_money_inserted - @products[desired_product_ix].item_price
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

    { status: :success, message: final_change_to_s(final_change) }
  end

  def products
    @products.map { |item| "#{item.item_name} - $#{item.item_price}"}
  end

  def product(item_name)
    @products.find { |item| item.item_name == item_name}
  end

  def coins_accepted
    @funds_available.map(&:value)
  end

  def enough_money_to_buy_product?(product_name, money)
    product_found = product(product_name)
    return unless product_found

    product_found.item_price <= money
  end

  private

  def final_change_to_s(final_change)
    return '' if final_change.empty?

    str = "Here's your change: \n"
    str + final_change.map { |change| "#{change[:amount]} of $#{change[:coin]}"}.join("\n")
  end
end
