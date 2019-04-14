class Dashboard::CouponsController < Dashboard::BaseController

  def index
    @coupons = current_user.coupons
    @coupon_count = @coupons.count
  end

  def new
    if current_user.coupons.count == 5
      flash[:alert] = "You can not make anymore coupons"
      redirect_to dashboard_coupons_path
    else
      @coupon = Coupon.new
    end
  end

  def create
    merchant = current_user
    @coupon = merchant.coupons.create(coupon_params)
    if @coupon.save
      redirect_to dashboard_coupons_path
    else
      render :new
    end
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :discount_type, :amount_off)
  end
end
