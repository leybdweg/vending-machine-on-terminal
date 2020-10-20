# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../models/vending_machine'

describe VendingMachine do
  context 'price and change are working good' do

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

  context 'item managing' do
    let(:mate) { subject.instance_variable_get(:@products).find { |product| product.item_name == 'mate'} }

    it 'item was reduced after buying' do
      original_mate_amount = mate.item_amount
      subject.buy_product('mate', [2, 0.5])
      expect(mate.item_amount).to eq(original_mate_amount - 1)
    end

    it 'item out of stock after last buy - all bought' do
      mate.item_amount.times { subject.buy_product('mate', [2, 0.5]) }
      expect(subject.instance_variable_get(:@products).find { |product| product.item_name == 'mate'}).to be_nil
    end
    it 'item N/A - should have been checked before trying to buy' do
      expect { subject.buy_product('N/A', [2, 0.5]) }.to raise_exception(TypeError, 'no implicit conversion from nil to integer')
    end
  end

  context 'funds properly changing' do
    let(:funds) { subject.instance_variable_get(:@funds_available) }
    let(:beer) { subject.instance_variable_get(:@products).find { |product| product.item_name == 'beer'} }

    it 'money being added - exact value' do
      original_funds = funds.sum { |money| money.value * money.amount}
      subject.buy_product('beer', [5])
      expect(original_funds + 5).to eq(funds.sum { |money| money.value * money.amount})
    end

    it 'money being added - more than necessary' do
      original_funds = funds.sum { |money| money.value * money.amount}
      subject.buy_product('beer', [2, 2, 2])
      expect(original_funds + 5).to eq(funds.sum { |money| money.value * money.amount})
    end

    it 'change being removed from funds' do
      one_dollar = funds.find { |money| money.value == 1 }
      original_amount = one_dollar.amount
      subject.buy_product('beer', [2, 2, 2])
      expect(original_amount - 1 ).to eq(one_dollar.amount)
    end
  end
end
