require 'rails_helper'

RSpec.describe CartItem, type: :model do
  it "每個Cart Item都可以計算它自己的金額（小計）" do
    cart = Cart.new
    p1 = FactoryBot.create(:product, sell_price: 7)
    p2 = FactoryBot.create(:product, sell_price: 3)

    3.times { cart.add_item(p1.id) }
    2.times { cart.add_item(p2.id) }

    expect(cart.items.first.total_price).to eq 21
    expect(cart.items.last.total_price).to eq 6
  end
end
