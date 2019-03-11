class ReportBuilder
  def initialize(orders)
    @orders = orders
    @orderer_data = ReportBuilder.orderer_seed
    generate
  end

  def total_revenue
    @orderer_data.inject(0) do |sum, n|
      sum += n[:quantity] * n[:price_per]
    end
  end

  def billing
    report = []

    @orderer_data.each do |orderer_datum|
      next if orderer_datum[:type] == :direct

      report << {
        name: orderer_datum[:name],
        amount_owed: orderer_datum[:quantity] * orderer_datum[:price_per]
      }
    end

    report
  end

  def profit
    report = []

    @orderer_data.each do |orderer_datum|
      next if orderer_datum[:type] == :direct

      quantity = orderer_datum[:quantity]
      revenue = orderer_datum[:sale_price] * quantity
      owed = orderer_datum[:price_per] * quantity

      report << {
        name: orderer_datum[:name],
        profit: revenue - owed
      }
    end

    report
  end

  private

  def generate
    @orders.each do |order|
      add_quantity_to_orderer_data(order)
    end

    add_price_per_to_order_data
  end

  def add_price_per_to_order_data
    @orderer_data.each do |orderer_datum|
      price_per = nil
      orderer = get_orderer(orderer_datum)

      case orderer[:type]

      when :direct
        price_per = 100
      when :affiliate
        quantity = orderer[:quantity]
        if quantity < 501
          price_per = 60
        elsif quantity > 1000
          price_per = 40
        else
          price_per = 50
        end
      when :reseller
        price_per = 50
      end

      orderer[:price_per] = price_per
    end
  end

  def add_quantity_to_orderer_data(order)
    get_orderer(order)[:quantity] += order[:quantity]
  end

  def get_orderer(order)
    @orderer_data.find{ |orderer_datum| orderer_datum[:name] == order[:name] }
  end

  def ReportBuilder.orderer_seed
    [
      {
        name: 'Direct Sale',
        type: :direct,
        sale_price: 100,
        quantity: 0
      },
      {
        name: 'A Company',
        type: :affiliate,
        sale_price: 75,
        quantity: 0
      },
      {
        name: 'Another Company',
        type: :affiliate,
        sale_price: 65,
        quantity: 0
      },
      {
        name: 'Even More Company',
        type: :affiliate,
        sale_price: 80,
        quantity: 0
      },
      {
        name: 'Resell This',
        type: :reseller,
        sale_price: 75,
        quantity: 0
      },
      {
        name: 'Resell More Things',
        type: :reseller,
        sale_price: 85,
        quantity: 0
      }
    ]
  end
end
