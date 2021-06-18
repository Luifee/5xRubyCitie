FactoryBot.define do
  factory :product do
    name { "MyString" }
    vendor { nil }
    list_price { "9.99" }
    sell_price { "9.99" }
    specification { "MyString" }
    on_sell { false }
    code { "MyString" }
    deleted_at { "" }
  end
end
