class Dashboard::CouponsController < Dashboard::BaseController

  def index
    @coupons = current_user.coupons
  end
end
