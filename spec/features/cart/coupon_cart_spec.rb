require 'rails_helper'

RSpec.describe 'as a user or visitor', type: :feature do
  describe 'When a visitor goes to their cart' do
    before :each do
      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)
      @item_1 = create(:item, merchant_id: @merchant_1.id)
      @item_2 = create(:item, merchant_id: @merchant_2.id)
      @coupon_1 = Coupon.create(name: "coupon 1", discount_type: 0, amount_off: 50, merchant_id: @merchant_1.id)
      @coupon_2 = Coupon.create(name: "coupon 1", discount_type: 1, amount_off: 50, merchant_id: @merchant_2.id)
    end
    it 'shows a field to enter coupon codes' do
      visit item_path(@item_1)

      click_button "Add to Cart"

      visit cart_path

      within '#coupon-code' do
        expect(page).to have_content("Have a coupon code?")
        expect(page).to have_content("Enter Here:")
      end
    end
  end
end
