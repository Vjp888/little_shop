class Cart
  attr_reader :contents

  def initialize(initial_contents)
    @contents = initial_contents || Hash.new(0)
    @contents.default = 0
  end

  def total_item_count
    @contents.values.sum
  end

  def add_item(item_id)
    @contents[item_id.to_s] += 1
  end

  def remove_item(item_id)
    @contents[item_id.to_s] -= 1
    @contents.delete(item_id.to_s) if count_of(item_id) == 0
  end

  def count_of(item_id)
    @contents[item_id.to_s]
  end

  def items
    @items ||= load_items
  end

  def load_items
    @contents.map do |item_id, quantity|
      item = Item.find(item_id)
      [item, quantity]
    end.to_h
  end

  def total #possible entry point? create helper to check for coupon and adjust #price.
    items.sum do |item, quantity|
      item.price * quantity
    end
  end

  def subtotal(item)
    count_of(item.id) * item.price
  end
end
