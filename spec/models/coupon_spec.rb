require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe 'validations' do
    it {should validate_uniqueness_of :name}
    it {should define_enum_for :discount_type}
    it {should validate_presence_of :amount_off}
  end

  describe 'relationships' do
    it {should belong_to :user}
    it {should have_many :orders}
  end
end
