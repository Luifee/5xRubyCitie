class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :sku

  def product
    Product.joins(:skus).find_by(skus: { id: sku_id })
  end

  def sku
    Sku.find_by(skus: { id: sku_id })
  end

  def name
    product.name + "(" + sku.subtype + ")"
  end

  def price
    quantity * product.sell_price
  end

end
