require 'rails_helper'

RSpec.describe 'as a user or visitor', type: :feature do
  describe 'When a visitor goes to their cart' do
    before :each do
      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)
      @item_1 = create(:item, merchant_id: @merchant_1.id, price: 500)
      @item_2 = create(:item, merchant_id: @merchant_2.id, price: 40)
      @item_3 = create(:item, merchant_id: @merchant_2.id, price: 500)
      @coupon_1 = Coupon.create(name: "coupon 1", discount_type: 0, amount_off: 50, merchant_id: @merchant_1.id)
      @coupon_2 = Coupon.create(name: "coupon 2", discount_type: 1, amount_off: 50, merchant_id: @merchant_2.id)
    end

    it 'shows a field to enter coupon codes' do
      visit item_path(@item_1)

      click_button "Add to Cart"

      visit cart_path

      within '#coupon-code' do
        expect(page).to have_content("Have a coupon code?")
        expect(page).to have_content("Enter here")
      end
    end

    it 'will check accept a coupon code and set it to the cart' do

      visit item_path(@item_1)

      click_button "Add to Cart"

      visit cart_path

      fill_in :coupon_code, with: "coupon 1"
      click_button "submit"

      expect(page).to have_content("You have applied #{@coupon_1.name} to your cart")
    end

    it 'will not accept a coupon that does not exist' do
      visit item_path(@item_1)

      click_button "Add to Cart"

      visit cart_path

      fill_in :coupon_code, with: "bad coupon"
      click_button "submit"

      expect(page).to have_content("bad coupon is not a valid coupon")
    end

    it 'will adjust the price by percentage of the cart when a coupon is applied' do
      visit item_path(@item_1)

      click_button "Add to Cart"

      visit cart_path

      expect(page).to have_content("Total: $500.00")

      fill_in :coupon_code, with: 'coupon 1'
      click_button 'submit'

      expect(page).to have_content("Total: $250.00")
    end

    it 'will adjust dollar value of the cart when a coupon is applied' do
      visit item_path(@item_3)

      click_button "Add to Cart"

      visit cart_path

      expect(page).to have_content("Total: $500.00")

      fill_in :coupon_code, with: 'coupon 2'
      click_button 'submit'

      expect(page).to have_content("Total: $450.00")
    end

    it 'will show a total of zero if the coupon exceed the dollar value of the items' do
      visit item_path(@item_2)

      click_button "Add to Cart"

      visit cart_path

      expect(page).to have_content("Total: $40.00")

      fill_in :coupon_code, with: 'coupon 2'
      click_button 'submit'

      expect(page).to have_content("Total: $0.00")
    end

    it 'discounts keeps the price when an order is created' do
      user = create(:user)
      login_as(user)
      visit item_path(@item_2)

      click_button "Add to Cart"

      visit cart_path

      expect(page).to have_content("Total: $40.00")

      fill_in :coupon_code, with: 'coupon 2'
      click_button 'submit'

      expect(page).to have_content("Total: $0.00")

      click_button "Check Out"

      expect(Order.last.total_cost).to eq(0)
    end
  end
end
