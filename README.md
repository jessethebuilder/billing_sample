# Billing Sample

## Useage
### OrderFactory
Class `build` method accepts an Array of Names and returns 100 orders with those
names and a random quantity between 1 and 100 (inclusive).

```ruby
OrderFactory.build(['x', 'y', 'z'])
```

### ReportBuilder
Initialize with any number of orders. Orders must be an Array of hashes, containing
2 keys: :name, :quantity. Names MUST match those provided in project specification.

```ruby
orderer_names = ReportBuilder.send(:orderer_seed).map{ |o| o[:name] }
orders = OrderFactory.build(orderer_names)
builder = ReportBuilder.new(orders)
```

Provides public methods corresponding to project specification.
1. `total_revenue` -> Integer
2. `billing` -> {:name, :amount_owed}
3. `profit` -> {:name, :profit}

```ruby
builder.total_revenue
builder.profit
```

## Testing
```bash
bundle install
bundle exec rspec
```
