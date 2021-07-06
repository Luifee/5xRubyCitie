require 'rails_helper'

RSpec.describe Cart, type: :model do

  describe "基本功能" do
    it "可以把商品丟到到購物車裡，然後購物車裡就有東西" do
      cart = Cart.new
      cart.add_item(100)

      expect(cart.empty?).to be false
    end

    it "加了相同商品到購物車，購買項目CartItem不會增加，但商品數量會改變" do
      cart = Cart.new
      3.times { cart.add_item(199) }
      2.times { cart.add_item(198) }

      expect(cart.items.count).to be 2
      expect(cart.items.first.quantity).to be 3
      expect(cart.items.last.quantity).to be 2
    end

    it "商品可以放到購物車裡，也可以再拿出來" do
      cart = Cart.new
      v1 = Vendor.create(title: '1stvendor')
      p1 = Product.create(name: '1stproduct', list_price: 10, sell_price: 9, vendor: v1)
      cart.add_item(p1.id)

      expect(cart.items.first.product).to be_a Product
    end

    it "每個 Cart Item 都可以計算它自己的金額（小計）" do

    end

    it "可以計算整台購物車的總消費金額" do

    end

    it "特別活動可搭配折扣（例如全面9折或滿額送百或滿額免運費）" do

    end

  end

  describe "進階功能" do
    it "可以將購物車內容轉換成 Hash 並存到 Session 裡" do
    end

    it "也可以存放在 Session 的內容（Hash 格式），還原成購物車的內容" do
    end
  end

end
