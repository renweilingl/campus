class BusinessHoursController < ApplicationController
  # 营业时间挂在“我的店铺”下、店主自助：记录永远取自 current_user.shop，
  # URL 里没有 shop_id，天然碰不到别店；授权仍显式走 ShopPolicy#manage_business_hours?（仅店主）
  before_action :set_shop
  before_action :set_hour, only: %i[edit update destroy]

  def index
    @hours = @shop.business_hours.order(:start_time, :id)
  end

  def new
    @hour = @shop.business_hours.new
  end

  def create
    @hour = @shop.business_hours.new(hour_params)

    if @hour.save
      redirect_to my_shop_business_hours_path, notice: "营业时间「#{@hour.label}」已创建"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @hour.update(hour_params)
      redirect_to my_shop_business_hours_path, notice: "营业时间「#{@hour.label}」已更新"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @hour.destroy
    redirect_to my_shop_business_hours_path, notice: "营业时间已删除"
  end

  private
    def set_shop
      @shop = current_user.shop
      if @shop.nil?
        redirect_to root_path, alert: "还没有门店，请联系管理员开通后再设置营业时间。"
        return
      end

      authorize @shop, :manage_business_hours?
    end

    # 只从自己门店的时间段里找，假 id 直接 404
    def set_hour
      @hour = @shop.business_hours.find(params[:id])
    end

    def hour_params
      params.expect(business_hour: %i[start_time end_time])
    end
end
