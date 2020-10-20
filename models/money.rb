# frozen_string_literal: true

class Money

  attr_reader :value
  attr_accessor :amount

  def initialize(amount, value)
    @amount = amount
    @value = value
  end
end
