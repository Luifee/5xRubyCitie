FactoryBot.define do
  factory :product do
    name { Faker::Name.name }
    vendor
    category
    list_price { Faker::Number.between(from: 100, to: 999) }
    sell_price { Faker::Number.between(from: 1, to: 99) }
    specification { "MyString" }
    on_sell { false }
  end
end
