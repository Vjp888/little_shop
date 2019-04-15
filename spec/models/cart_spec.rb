require 'rails_helper'

RSpec.describe Cart do
  describe "Cart with existing contents" do
    before :each do
      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)
      @coupon_1 = Coupon.create(name: "coupon 1", discount_type: 0, amount_off: 50, merchant_id: @merchant_1.id)
      @coupon_2 = Coupon.create(name: "coupon 2", discount_type: 1, amount_off: 50, merchant_id: @merchant_2.id)
      @coupon_3 = Coupon.create(name: "coupon 3", discount_type: 1, amount_off: 400, merchant_id: @merchant_2.id)
      @item_1 = create(:item, id: 1, merchant_id: @merchant_1.id, price: 500)
      @item_4 = create(:item, id: 4, merchant_id: @merchant_2.id, price: 300)
      @cart = Cart.new({"1" => 3, "4" => 2})
      @cart_2 = Cart.new({"4" => 1})
    end

    describe '#add_coupon' do
      it 'Adds a coupon to the cart variable' do
        @cart.add_coupon(@coupon_1.id)
        expect(@cart.coupon).to eq(@coupon_1.id)
      end
    end

    describe 'helper methods' do
      describe '#cart_sum' do
        it 'will calculate totals with a percentage based coupon is present' do
          @cart.add_coupon(@coupon_1.id)
          expect((@cart.total.to_f)).to eq(1350.0)
        end
        it 'will calculate totals with a dollar based coupon is present' do
          @cart.add_coupon(@coupon_2.id)
          expect((@cart.total.to_f)).to eq(2000.0)
        end
        it 'will return 0 if the coupon exceed the dollar amount of the items in the cart' do
          @cart_2.add_coupon(@coupon_3.id)
          expect((@cart_2.total.to_f)).to eq(0)
        end
      end
    end

    describe "#total_item_count" do
      it "returns the total item count" do
        expect(@cart.total_item_count).to eq(5)
      end
    end

    describe "#contents" do
      it "returns the contents" do
        expect(@cart.contents).to eq({"1" => 3, "4" => 2})
      end
    end

    describe "#count_of" do
      it "counts a particular item" do
        expect(@cart.count_of(1)).to eq(3)
      end
    end

    describe "#add_item" do
      it "increments an existing item" do
        @cart.add_item(1)
        expect(@cart.count_of(1)).to eq(4)
      end

      it "can increment an item not in the cart yet" do
        @cart.add_item(2)
        expect(@cart.count_of(2)).to eq(1)
      end
    end

    describe "#remove_item" do
      it "decrements an existing item" do
        @cart.remove_item(1)
        expect(@cart.count_of(1)).to eq(2)
      end

      it "deletes an item when count goes to zero" do
        @cart.remove_item(1)
        @cart.remove_item(1)
        @cart.remove_item(1)
        expect(@cart.contents.keys).to_not include("1")
      end
    end

    describe "#items" do
      it "can map item_ids to objects" do

        expect(@cart.items).to eq({@item_1 => 3, @item_4 => 2})
      end
    end

    describe "#total" do
      it "can calculate the total of all items in the cart" do
        expect(@cart.total).to eq(@item_1.price * 3 + @item_4.price * 2)
      end
    end

    describe "#subtotal" do
      it "calculates the total for a single item" do
        expect(@cart.subtotal(@item_1)).to eq(@cart.count_of(@item_1.id) * @item_1.price)
      end
    end
  end

  describe "Cart with empty contents" do
    before :each do
      @cart = Cart.new(nil)
    end

    describe "#total_item_count" do
      it "returns 0 when there are no contents" do
        expect(@cart.total_item_count).to eq(0)
      end
    end

    describe "#contents" do
      it "returns empty contents" do
        expect(@cart.contents).to eq({})
      end
    end

    describe "#count_of" do
      it "counts non existent items as zero" do
        expect(@cart.count_of(1)).to eq(0)
      end
    end

    describe "#add_item" do
      it "increments the item's count" do
        @cart.add_item(2)
        expect(@cart.count_of(2)).to eq(1)
      end
    end
  end
end
