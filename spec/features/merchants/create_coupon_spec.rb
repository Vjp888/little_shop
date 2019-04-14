require 'rails_helper'

RSpec.describe 'Merchat Creating A Coupon', type: :feature do
  before :each do
    @merchant = create(:merchant)
    login_as(@merchant)
  end

  it 'shows a link to manage coupons' do
    visit dashboard_path

    expect(page).to have_link("Manage Coupons")
  end

  it 'it will redirect to the coupon management page' do
    visit dashboard_path

    click_link "Manage Coupons"

    expect(current_path).to eq(dashboard_coupons_path)
  end

  it 'lets shows all coupons that the merchant current has' do
    coupon_1 = Coupon.create(name: "coupon 1", discount_type: 0, amount_off: 50, merchant_id: @merchant.id)
    coupon_2 = Coupon.create(name: "coupon 2", discount_type: 1, amount_off: 50, merchant_id: @merchant.id)
    coupon_3 = Coupon.create(name: "coupon 3", discount_type: 1, amount_off: 50, merchant_id: @merchant.id)
    coupon_4 = Coupon.create(name: "coupon 4", discount_type: 0, amount_off: 50, merchant_id: @merchant.id)

    visit dashboard_coupons_path

    expect(page).to have_content("Number of Coupons: 4/5")
    expect(page).to have_link("Create Coupon")

    within "#coupon-#{coupon_1.id}" do
      expect(page).to have_content("Code: #{coupon_1.name}")
      expect(page).to have_content("Type: #{coupon_1.discount_type}")
      expect(page).to have_content("Amount Off: #{coupon_1.amount_off}")
    end

    within "#coupon-#{coupon_2.id}" do
      expect(page).to have_content("Code: #{coupon_2.name}")
      expect(page).to have_content("Type: #{coupon_2.discount_type}")
      expect(page).to have_content("Amount Off: #{coupon_2.amount_off}")
    end

    within "#coupon-#{coupon_3.id}" do
      expect(page).to have_content("Code: #{coupon_3.name}")
      expect(page).to have_content("Type: #{coupon_3.discount_type}")
      expect(page).to have_content("Amount Off: #{coupon_3.amount_off}")
    end

    within "#coupon-#{coupon_4.id}" do
      expect(page).to have_content("Code: #{coupon_4.name}")
      expect(page).to have_content("Type: #{coupon_4.discount_type}")
      expect(page).to have_content("Amount Off: #{coupon_4.amount_off}")
    end
  end

  it 'It allows a merchant to create a coupon' do
    visit dashboard_coupons_path

    expect(page).to have_content("You have no coupons, create on now!")

    click_link "Create Coupon"

    fill_in "Name", with: "1234"
    fill_in "Discount Type", with: "percentage"
    fill_in "Amount Off", with: "10"

    click_button "Create Coupon"
    coupon = Coupon.first

    expect(current_path).to eq(dashboard_coupons_path)

    within "#coupon-#{coupon.id}" do
      expect(page).to have_content("Code: #{coupon.name}")
    end
  end
end
