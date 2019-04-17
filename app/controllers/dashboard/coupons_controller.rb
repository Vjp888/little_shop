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

  def edit
    @coupon = Coupon.find(params[:id])
  end

  def update
    @coupon = Coupon.find(params[:id])
    @coupon.update(coupon_params)
    if @coupon.save
      flash[:update] = "Coupon Updated"
      redirect_to dashboard_coupons_path
    else
      render :edit
    end
  end

  def disable
    coupon = Coupon.find(params[:id])
    coupon.toggle :enabled
    coupon.save
    redirect_to dashboard_coupons_path
  end

  def enable
    coupon = Coupon.find(params[:id])
    coupon.toggle :enabled
    coupon.save
    redirect_to dashboard_coupons_path
  end

  def destroy
    coupon = Coupon.find(params[:id])
    coupon.delete
    redirect_to dashboard_coupons_path
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :discount_type, :amount_off)
  end
end
