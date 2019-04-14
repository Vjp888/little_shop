class Coupon < ApplicationRecord
  validates_uniqueness_of :name
  validates_presence_of :amount_off
  validates_presence_of :discount_type

  enum discount_type: ['percentage', 'dollar']


  belongs_to :user, foreign_key: 'merchant_id'
  has_many :orders

end
