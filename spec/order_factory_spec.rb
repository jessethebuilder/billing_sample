require 'spec_helper'

describe OrderFactory do
  describe '#build(orderers)' do
    before do
      @orderers = %w|aaa bbb ccc ddd|
      @orders = OrderFactory.build(@orderers)
    end

    it 'should return 100 orders from vendors provided by param' do
      expect(@orders.count).to eq(100)
    end

    specify 'All Orderers should be from list' do
      @orders.each do |order|
        expect(@orderers.include?(order[:name])).to eq(true)
      end
    end

    specify 'All Quantities should be from 1 to 100' do
      @orders.each do |order|
        quantity = order[:quantity]
        expect(quantity > 0 && quantity < 101).to eq(true)
      end
    end
  end
end
