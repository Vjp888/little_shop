class CartController < ApplicationController
  before_action :visitor_or_user

  def show
    if session[:coupon]
      cart.add_coupon(session[:coupon])
    end
  end

  def increment
    item = Item.find(params[:id])
    if item.inventory <= cart.count_of(item.id)
      flash[:danger] = "The Merchant does not have enough inventory."
    else
      cart.add_item(item.id)
      session[:cart] = cart.contents
      flash[:success] = "#{item.name} has been added to your cart!"
    end
    redirect_to cart_path
  end

  def decrement
    item = Item.find(params[:id])
    cart.remove_item(item.id)
    session[:cart] = cart.contents
    flash[:success] = "#{item.name} has been removed from your cart."
    redirect_to cart_path
  end

  def destroy
    session.delete(:cart)
    redirect_to cart_path
  end

  def remove_item
    item = Item.find(params[:id])
    session[:cart].delete(item.id.to_s)
    flash[:success] = "#{item.name} has been removed from your cart."
    redirect_to cart_path
  end

  def coupon_check
    if coupon = Coupon.find_by(name: params[:coupon_code])
      if current_user == nil
        session[:coupon] = coupon.id
        flash[:notice] = "You have applied #{coupon.name} to your cart"
        redirect_to cart_path
      elsif current_user.used?(coupon) == false
        session[:coupon] = coupon.id
        flash[:notice] = "You have applied #{coupon.name} to your cart"
        redirect_to cart_path
      else
        flash[:error] = "#{coupon.name} can only be used once per customer"
        redirect_to cart_path
      end
    else
      flash[:error] = "#{params[:coupon_code]} is not a valid coupon"
      redirect_to cart_path
    end
  end
end
