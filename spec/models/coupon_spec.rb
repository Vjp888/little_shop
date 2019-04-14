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

  describe 'instance methods' do
    describe '#used?' do
      it 'checks to see if a coupon has been used on an order' do
        merchant = create(:merchant)
        coupon_1 = Coupon.create(name: "coupon 1", discount_type: 0, amount_off: 50, merchant_id: merchant.id)
        coupon_2 = Coupon.create(name: "coupon 2", discount_type: 1, amount_off: 50, merchant_id: merchant.id)
        create(:order, coupon_id: coupon_1.id)

        expect(coupon_1.used?).to eq(true)
        expect(coupon_2.used?).to eq(false)
      end
    end
  end
end
