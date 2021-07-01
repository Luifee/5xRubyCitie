class Product < ApplicationRecord
  include CodeGenerator
  has_rich_text :description
  has_one_attached :cover_image
  acts_as_paranoid

  belongs_to :vendor
  belongs_to :category, optional: true
  has_many :skus
  accepts_nested_attributes_for :skus, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true
  validates :list_price, :sell_price, numericality: { greater_than: 0, allow_nil: true }
  validates :sell_price, numericality: { less_than_or_equal_to: :list_price }
  validates :code, uniqueness: true

end
