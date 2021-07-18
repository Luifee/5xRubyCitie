FactoryBot.define do
  factory :sku do
    subtype { Faker::Name.name }
    quantity { Faker::Number.between(from: 1, to: 10) }

    product
  end
end
