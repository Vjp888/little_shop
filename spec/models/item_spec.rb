require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than(0) }
    it { should validate_presence_of :description }
    it { should validate_presence_of :inventory }
    it { should validate_numericality_of(:inventory).only_integer }
    it { should validate_numericality_of(:inventory).is_greater_than_or_equal_to(0) }
  end

  describe 'relationships' do
    it { should belong_to :user }
  end

  describe 'class methods' do
    describe 'item popularity' do
      before :each do
        merchant = create(:merchant)
        @items = create_list(:item, 6, user: merchant)
        user = create(:user)

        order = create(:shipped_order, user: user)
        create(:fulfilled_order_item, order: order, item: @items[3], quantity: 7)
        create(:fulfilled_order_item, order: order, item: @items[1], quantity: 6)
        create(:fulfilled_order_item, order: order, item: @items[0], quantity: 5)
        create(:fulfilled_order_item, order: order, item: @items[2], quantity: 3)
        create(:fulfilled_order_item, order: order, item: @items[5], quantity: 2)
        create(:fulfilled_order_item, order: order, item: @items[4], quantity: 1)
      end

      it '.item_popularity' do
        expect(Item.item_popularity(4, :desc)).to eq([@items[3], @items[1], @items[0], @items[2]])
        expect(Item.item_popularity(4, :asc)).to eq([@items[4], @items[5], @items[2], @items[0]])
      end

      it '.popular_items' do
        actual = Item.popular_items(3)
        expect(actual).to eq([@items[3], @items[1], @items[0]])
        expect(actual[0].total_ordered).to eq(7)
      end

      it '.unpopular_items' do
        actual = Item.unpopular_items(3)
        expect(actual).to eq([@items[4], @items[5], @items[2]])
        expect(actual[0].total_ordered).to eq(1)
      end
    end
  end

  describe 'instance methods' do
    before :each do
      @merchant = create(:merchant)
      @item = create(:item, user: @merchant, price: 50)
      @coupon = Coupon.create(name: "coupon 1", discount_type: 0, amount_off: 50, merchant_id: @merchant.id)
      @order_item_1 = create(:fulfilled_order_item, item: @item, created_at: 4.days.ago, updated_at: 12.hours.ago)
      @order_item_2 = create(:fulfilled_order_item, item: @item, created_at: 2.days.ago, updated_at: 1.day.ago)
      @order_item_3 = create(:fulfilled_order_item, item: @item, created_at: 2.days.ago, updated_at: 1.day.ago)
      @order_item_4 = create(:order_item, item: @item, created_at: 2.days.ago, updated_at: 1.day.ago)
    end

    describe "#average_fulfillment_time" do
      it "calculates the average number of seconds between order_item creation and completion" do
        expect(@item.average_fulfillment_time).to eq(158400)
      end

      it "returns nil when there are no order_items" do
        unfulfilled_item = create(:item, user: @merchant)
        unfulfilled_order_item = create(:order_item, item: @item, created_at: 2.days.ago, updated_at: 1.day.ago)

        expect(unfulfilled_item.average_fulfillment_time).to be_falsy
      end
    end

    describe "#ordered?" do
      it "returns true if an item has been ordered" do
        expect(@item.ordered?).to be_truthy
      end

      it "returns false when the item has never been ordered" do
        unordered_item = create(:item)
        expect(unordered_item.ordered?).to be_falsy
      end
    end

    describe '#adjusted_price(coupon)' do
      it 'will return the adjusted price when a coupon is present' do
        expect(@item.adjusted_price(@coupon).to_f).to eq(25.0)
      end

      it 'will return the original price if no coupon is present' do
        expect(@item.adjusted_price.to_f).to eq(50.0)
      end
    end
  end
end
