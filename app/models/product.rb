class Product < ApplicationRecord
  include CodeGenerator
  has_rich_text :description
  acts_as_paranoid

  belongs_to :vendor

  validates :name, presence: true
  validates :list_price, :sell_price, numericality: { greater_than: 0, allow_nil: true }
  validates :sell_price, numericality: { less_than_or_equal_to: :list_price }
  validates :code, uniqueness: true

end
