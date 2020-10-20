# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../models/vending_machine'

describe VendingMachine do
  context 'success flow' do
    it 'coke with 4.75' do
      expect(
        subject.buy_product('coke', [2, 0.5, 0.25, 2])
      ).to eq(message: "Here's your change: \n1 of $1\n1 of $0.5\n1 of $0.25", status: :success)
    end

    it 'coke with 5.25' do
      expect(
        subject.buy_product('coke', [2, 1, 1, 0.5, 0.5, 0.25])
      ).to eq(message: "Here's your change: \n1 of $2\n1 of $0.25", status: :success)
    end

    it 'coke with 5.25' do
      expect(
        subject.buy_product('coke', [0.25, 5])
      ).to eq(message: "Here's your change: \n1 of $2\n1 of $0.25", status: :success)
    end

    it 'coke with 5' do
      expect(
        subject.buy_product('coke', [5])
      ).to eq(message: "Here's your change: \n1 of $2", status: :success)
    end

    it 'coke with 3 - exact value' do
      expect(
        subject.buy_product('coke', [2, 1])
      ).to eq(message: '', status: :success)
    end
  end

  context 'failure cases' do
    it 'coke with 1' do
      expect(
        subject.buy_product('coke', [1])
      ).to eq(message: 'not enough money', status: :failed)
    end

    it 'coke with 3.333' do
      expect(
        subject.buy_product('coke', [3.333])
      ).to eq(message: 'unable to provide correct change', status: :failed)
    end

    it 'martini with 10' do
      subject.instance_variable_set(:@products, [ItemManager.new('martini', 9.75, 1)])
      subject.instance_variable_set(:@funds_available, [Money.new(2, 5)])

      expect { subject.buy_product('martini', [5, 5]) }.to raise_error(RuntimeError)
    end
  end
end
