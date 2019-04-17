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

    expect(page).to have_content("You have no coupons, create one now!")

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

  it 'does not let a merchant create more than five coupons with url or clickable link' do
    Coupon.create(name: "coupon 1", discount_type: 0, amount_off: 50, merchant_id: @merchant.id)
    Coupon.create(name: "coupon 2", discount_type: 1, amount_off: 50, merchant_id: @merchant.id)
    Coupon.create(name: "coupon 3", discount_type: 1, amount_off: 50, merchant_id: @merchant.id)
    Coupon.create(name: "coupon 4", discount_type: 0, amount_off: 50, merchant_id: @merchant.id)
    Coupon.create(name: "coupon 5", discount_type: 0, amount_off: 50, merchant_id: @merchant.id)

    visit new_dashboard_coupon_path

    expect(page).to have_content("You can not make anymore coupons")

    visit dashboard_coupons_path

    expect(page).to have_content("Number of Coupons: 5/5")

    expect(page).to_not have_link("Create Coupon")
  end

  it 'does not let a merchant create a coupon with the same name as another coupon' do
    Coupon.create(name: "coupon 1", discount_type: 0, amount_off: 50, merchant_id: @merchant.id)

    visit dashboard_coupons_path

    click_link "Create Coupon"

    fill_in "Name", with: "coupon 1"
    fill_in "Discount Type", with: "percentage"
    fill_in "Amount Off", with: "10"

    click_button "Create Coupon"

    expect(page).to have_content("Name has already been taken")
  end

  it 'a coupon can be disabled or disabled' do
    coupon_1 = Coupon.create(name: "coupon 1", discount_type: 0, amount_off: 50, merchant_id: @merchant.id)
    coupon_2 = Coupon.create(name: "coupon 2", discount_type: 1, amount_off: 50, merchant_id: @merchant.id, enabled: false)


    visit dashboard_coupons_path

    within "#coupon-#{coupon_1.id}" do
      expect(page).to_not have_button("Enable")
      expect(page).to have_button("Disable")
      click_button "Disable"
    end
    within "#coupon-#{coupon_1.id}" do
      expect(page).to have_button("Enable")
    end

    within "#coupon-#{coupon_2.id}" do
      expect(page).to_not have_button("Disable")
      expect(page).to have_button("Enable")
      click_button "Enable"
    end
    within "#coupon-#{coupon_2.id}" do
      expect(page).to have_button("Disable")
    end

    expect(Coupon.last.enabled?).to eq(true)
    expect(Coupon.first.enabled?).to eq(false)
  end

  it 'allows a merchant to delete a coupon if it has not been used' do
    coupon_1 = Coupon.create(name: "coupon 1", discount_type: 0, amount_off: 50, merchant_id: @merchant.id)
    coupon_2 = Coupon.create(name: "coupon 2", discount_type: 1, amount_off: 50, merchant_id: @merchant.id)
    create(:order, coupon_id: coupon_1.id)

    visit dashboard_coupons_path

    within "#coupon-#{coupon_1.id}" do
      expect(page).to_not have_button("Delete Coupon")
    end

    within "#coupon-#{coupon_2.id}" do
      expect(page).to have_button("Delete Coupon")
      click_button "Delete Coupon"
    end

    expect(current_path).to eq(dashboard_coupons_path)
    expect(page).to_not have_content("coupon 2")
    expect(page).to have_content("coupon 1")
  end

  it 'lets a merchant change the information for their coupon if it has not been used' do
    coupon_1 = Coupon.create(name: "coupon 1", discount_type: 0, amount_off: 50, merchant_id: @merchant.id)
    coupon_2 = Coupon.create(name: "coupon 2", discount_type: 1, amount_off: 50, merchant_id: @merchant.id, enabled: false)
    create(:order, coupon_id: coupon_1.id)

    visit dashboard_coupons_path

    within "#coupon-#{coupon_1.id}" do
      expect(page).to_not have_button("Edit Coupon")
    end

    within "#coupon-#{coupon_2.id}" do
      expect(page).to have_button("Edit Coupon")
      click_button "Edit Coupon"
    end

    fill_in "Name", with: "coupon 3"
    fill_in "Discount Type", with: "dollar"
    fill_in "Amount Off", with: "10"

    click_button "Update Coupon"

    expect(page).to have_content("Coupon Updated")
    within "#coupon-#{coupon_2.id}" do
      expect(page).to have_content("Code: coupon 3")
      expect(page).to have_content("Type: dollar")
      expect(page).to have_content("Amount Off: 10")
    end
  end

  it 'will not update if bad info is given' do
    coupon_1 = Coupon.create(name: "coupon 1", discount_type: 0, amount_off: 50, merchant_id: @merchant.id)
    coupon_2 = Coupon.create(name: "coupon 2", discount_type: 1, amount_off: 50, merchant_id: @merchant.id, enabled: false)
    create(:order, coupon_id: coupon_1.id)

    visit dashboard_coupons_path

    within "#coupon-#{coupon_2.id}" do
      expect(page).to have_button("Edit Coupon")
      click_button "Edit Coupon"
    end

    fill_in "Name", with: "coupon 1"
    fill_in "Discount Type", with: "dollar"
    fill_in "Amount Off", with: "10"
    click_button "Update Coupon"

    expect(page).to have_content("Name has already been taken")
  end
end
