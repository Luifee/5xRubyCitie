class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items

  validates :receipient, :tel, :address, presence: true

  before_create :generate_order_num

  private

  def generate_order_num
    self.num = SecureRandom.hex(15) unless num
  end
end
