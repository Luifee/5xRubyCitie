class Product < ApplicationRecord
  acts_as_paranoid
  belongs_to :vendor
  validates :name, presence: true
end
