# frozen_string_literal: true

require_relative '../vending_machine'

describe VendingMachine do
  let(:vending_machine) { VendingMachine.new }
  it 'coke with 5.25' do
    expect(
      vending_machine.buy_product('coke', 5.25)
    ).to eq(
      [
        { coin: 2, amount: 1 },
        { coin: 0.25, amount: 1 }
      ]
    )
  end
it 'coke with 10' do
    expect(
      vending_machine.buy_product('coke', 10)
    ).to eq(
      [
        { coin: 5, amount: 1 },
        { coin: 2, amount: 1 }
      ]
    )
  end
end
