class OrderFactory
  def self.build(orderers)
    @orderers = orderers
    100.times.map{ build_order }
  end

  private

  def self.build_order
    {
      name: @orderers.sample,
      quantity: Random.rand(1..100)
    }
  end

end
