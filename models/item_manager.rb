# frozen_string_literal: true

class ItemManager

  attr_reader :item_name, :item_price
  attr_accessor :item_amount

  def initialize(name, price, amount)
    @item_name = name
    @item_price = price
    @item_amount = amount
  end
end
