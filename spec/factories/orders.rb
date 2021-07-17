FactoryBot.define do
  factory :order do
    num { "MyString" }
    receipient { "MyString" }
    tel { "MyString" }
    address { "MyString" }
    note { "MyText" }
    user { nil }
    status { "MyString" }
    paid_at { "2021-07-17 07:53:05" }
    transaction_id { "MyString" }
    delete_at { "2021-07-17 07:53:05" }
  end
end
