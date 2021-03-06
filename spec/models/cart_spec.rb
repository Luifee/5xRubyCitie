require 'rails_helper'

RSpec.describe Cart, type: :model do

  let(:cart) { Cart.new }

  describe "基本功能" do

    it "可以把商品丟到到購物車裡，然後購物車裡就有東西" do
      cart.add_sku(100)

      # expect(cart.empty?).to be false
      expect(cart).not_to be_empty
    end

    it "加了相同商品到購物車，購買項目CartItem不會增加，但商品數量會改變" do
      3.times { cart.add_sku(199) }
      2.times { cart.add_sku(198) }

      expect(cart.items.count).to be 2
      expect(cart.items.first.quantity).to be 3
      expect(cart.items.last.quantity).to be 2
    end

    it "商品可以放到購物車裡，也可以再拿出來" do
      # v1 = Vendor.create(title: '1stvendor')
      # p1 = Product.create(name: '1stproduct', list_price: 10, sell_price: 9, vendor: v1)
      p1 = FactoryBot.create(:product, :with_skus)
      cart.add_sku(p1.skus.first.id)

      expect(cart.items.first.product).to be_a Product
    end

    it "可以計算整台購物車的總消費金額" do
      p1 = FactoryBot.create(:product, :with_skus, sell_price: 7)
      p2 = FactoryBot.create(:product, :with_skus, sell_price: 3)

      3.times { cart.add_sku(p1.skus.first.id) }
      2.times { cart.add_sku(p2.skus.first.id) }

      expect(cart.total_price).to eq 27
    end

    it "特別活動可搭配折扣（例如全面9折或滿額送百或滿額免運費）" do
      pending
    end

  end

  describe "進階功能" do
    it "可以將購物車內容轉換成 Hash 並存到 Session 裡" do
      p1 = FactoryBot.create(:product, :with_skus)
      p2 = FactoryBot.create(:product, :with_skus)

      3.times { cart.add_sku(p1.skus.first.id) }
      2.times { cart.add_sku(p2.skus.first.id) }

      expect(cart.serialize).to eq cart_hash
    end

    it "也可以存放在 Session 的內容（Hash 格式），還原成購物車的內容" do
      cart = Cart.load_session(cart_hash)

      expect(cart.items.first.quantity).to be 3
      expect(cart.items.last.quantity).to be 2
    end

    private

    def cart_hash
      {
        "items" => [
          {"sku_id" => 1, "quantity" => 3},
          {"sku_id" => 3, "quantity" => 2}
        ]
      }
    end
  end

end
