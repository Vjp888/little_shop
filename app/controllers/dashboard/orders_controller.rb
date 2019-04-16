class Dashboard::OrdersController < Dashboard::BaseController

  def show
    @merchant = current_user
    @order = Order.find(params[:id])
    @user = @order.user
    @order_items = @order.order_items_for_merchant(@merchant.id)
    @coupon = @order.coupon
  end

  def fulfill
    oi = OrderItem.find(params[:order_item_id])
    oi.fulfill
    if oi.order.order_items.where(fulfilled: false).empty?
      oi.order.status = :packaged
      oi.order.save
    end
    flash[:success] = "You have successfully fulfilled an item"
    if current_admin?
      redirect_to admin_merchant_path(oi.item.user)
    else
      redirect_to dashboard_order_path(oi.order)
    end
  end
end
