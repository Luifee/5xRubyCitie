FactoryBot.define do
  factory :sku do
    product { nil }
    subtype { "MyString" }
    quantity { 1 }
    deleted_at { "2021-06-19 07:22:57" }
  end
end
