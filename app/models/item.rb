class Item < ApplicationRecord
  belongs_to :user, foreign_key: 'merchant_id'
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items

  validates_presence_of :name, :description

  validates :price, presence: true, numericality: {
    only_integer: false,
    greater_than: 0
  }

  validates :inventory, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  def self.popular_items(limit)
    item_popularity(limit, :desc)
  end

  def self.unpopular_items(limit)
    item_popularity(limit, :asc)
  end

  def self.item_popularity(limit, order)
    Item.joins(:order_items)
      .select('items.*, sum(quantity) as total_ordered')
      .group(:id)
      .order("total_ordered #{order}")
      .limit(limit)
  end

  def convert_datetime_to_seconds(datetime)
    days_and_hours = datetime.split(":").first
    days = days_and_hours.split.first.to_i
    hours = days_and_hours.split.last.to_i
    hours += days * 24
    hours * 60 * 60
  end

  def average_fulfillment_time
    average_time = order_items.where(fulfilled: true).pluck("avg(order_items.updated_at - order_items.created_at)").first
    return nil unless average_time
    convert_datetime_to_seconds(average_time)
  end

  def ordered?
    order_items.count > 0
  end

  def adjusted_price(coupon = nil)
    if coupon == nil
      self.price
    elsif coupon.merchant_id == self.merchant_id
      case coupon.discount_type
      when "percentage"
        self.price * coupon.amount_off.to_f / 100
      when "dollar"
        cost = self.price - coupon.amount_off
        if cost > 0
          cost
        else
          0
        end
      end
    end
  end
end
