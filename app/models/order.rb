class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items

  validates :receipient, :tel, :address, presence: true
end
