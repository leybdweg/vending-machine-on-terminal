# frozen_string_literal: true

require_relative '../vending_machine'

describe VendingMachine do
  it 'coke with 4.75' do
    expect(
      subject.buy_product('coke', 4.75)
    ).to eq(
      [
        { coin: 1, amount: 1 },
        { coin: 0.50, amount: 1 },
        { coin: 0.25, amount: 1 }
      ]
    )
  end

  it 'coke with 4.25' do
    expect(
      subject.buy_product('coke', 4.25)
    ).to eq(
      [
        { coin: 1, amount: 1 },
        { coin: 0.25, amount: 1 }
      ]
    )
  end

  it 'coke with 5.25' do
    expect(
      subject.buy_product('coke', 5.25)
    ).to eq(
      [
        { coin: 2, amount: 1 },
        { coin: 0.25, amount: 1 }
      ]
    )
  end

  it 'coke with 10' do
    expect(
      subject.buy_product('coke', 10)
    ).to eq(
      [
        { coin: 5, amount: 1 },
        { coin: 2, amount: 1 }
      ]
    )
  end

  it 'coke with 1' do
    expect(
      subject.buy_product('coke', 1)
    ).to eq(message: 'not enough money', status: :failed)
  end

  it 'coke with 3.333' do
    expect(
      subject.buy_product('coke', 3.333)
    ).to eq(message: 'unable to provide correct change', status: :failed)
  end
end
