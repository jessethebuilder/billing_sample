require 'spec_helper'

describe ReportBuilder do
  def find_report_item_by_name(report, name)
    report.find{ |item| item[:name] == name}
  end

  before do
    @orderer_names = ReportBuilder.send(:orderer_seed).map{ |seed| seed[:name] }
    @orders = OrderFactory.build(@orderer_names)
    @builder = ReportBuilder.new(@orders)
    @orderer_data = @builder.instance_variable_get(:@orderer_data)
  end

  it 'should calculate the quantity of all orders' do
    data_total = @orderer_data.inject(0){ |sum, n| sum += n[:quantity] }
    orders_total = @orders.inject(0){ |sum, n| sum += n[:quantity] }
    expect(data_total).to eq(orders_total)
  end

  it 'should calculate price_per for each @orderer' do
    @orderer_data.each do |orderer_datum|
      price_per = orderer_datum[:price_per]

      case orderer_datum[:type]
      when :direct
        expect(price_per).to eq(100)
      when :affiliate
        quantity = orderer_datum[:quantity]
        if quantity < 501
          expect(price_per).to eq(60)
        elsif quantity > 1000
          expect(price_per).to eq(40)
        else
          expect(price_per).to eq(50)
        end
      when :reseller
        expect(orderer_datum[:price_per]).to eq(50)
      end
    end
  end

  describe 'Reports' do
    describe '#total_revenue' do
      it 'should return order total' do
        revenue = ReportBuilder.new([{
          name: 'Resell More Things', # As Reseller, pays 50
          quantity: 123
        }]).total_revenue

        expect(revenue).to eq(6150) # 50 * 123
      end

      it 'should return the total for all @orders' do
        total = @orderer_data.inject(0) do |sum, n|
          sum += n[:quantity] * n[:price_per]
        end

        expect(@builder.total_revenue).to eq(total)
      end
    end

    describe '#billing' do
      it 'should not include an entry for :direct (Direct Sale)' do
        types = @builder.billing.map{ |item| item[:name] }
        expect(types.include?('Direct Sale')).to eq(false)
      end

      it 'should return the total owed' do
        report = ReportBuilder.new([{
          name: 'Resell More Things', # As Reseller, pays 50
          quantity: 1000
        }]).billing

        expect(find_report_item_by_name(report, 'Resell More Things'))
              .to eq({name: 'Resell More Things', amount_owed: 50000})
      end

      describe 'affiliates' do
        before do
          @order_data = {
            name: 'A Company',
            quantity: 100 # Affiliates pay 60 at this tier.
          }
        end

        it 'should return the amount owed by :affiliate < 501 tier' do
          report = ReportBuilder.new([@order_data]).billing
          expect(find_report_item_by_name(report, 'A Company'))
                .to eq({name: 'A Company', amount_owed: 6000})
        end

        # TODO: each Tier
      end
    end # end Billing

    describe '#profit' do
      it 'should return profit for order' do
        report = ReportBuilder.new([{
          name: 'Resell This',
          quantity: 100 # Buys for 50, sells for 75
        }]).profit

        expect(find_report_item_by_name(report, 'Resell This'))
              .to eq({name: 'Resell This', profit: 2500})
      end

      # Todo Affiliate specs
    end
  end
end
