class Profile::OrdersController < ApplicationController
  before_action :require_reguser

  def index
    @user = current_user
    @orders = current_user.orders
  end

  def show
    @order = Order.find(params[:id])
    unless @order.coupon_id == nil
      @coupon = Coupon.find(@order.coupon_id)
    end
  end

  def destroy
    @order = Order.find(params[:id])
    if @order.user == current_user
      @order.order_items.where(fulfilled: true).each do |oi|
        item = Item.find(oi.item_id)
        item.inventory += oi.quantity
        item.save
        oi.fulfilled = false
        oi.save
      end

      @order.status = :cancelled
      @order.save

      redirect_to profile_orders_path
    else
      render file: 'public/404', status: 404
    end
  end

  def create
    coupon = Coupon.find(session[:coupon]) if session[:coupon]
    if coupon
      order = Order.create(user: current_user, status: :pending, coupon_id: coupon.id)
    else
      order = Order.create(user: current_user, status: :pending)
    end
    cart.items.each do |item, quantity|
      order.order_items.create(item: item, quantity: quantity, price: item.adjusted_price(coupon))
    end
    session.delete(:cart)
    session.delete(:coupon)
    flash[:success] = "Your order has been created!"
    redirect_to profile_orders_path
  end
end
