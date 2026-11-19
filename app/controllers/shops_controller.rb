class ShopsController < ApplicationController
  before_action :set_shop, only: %i[show edit update destroy toggle_status]

  def index
    @shops = policy_scope(Shop).order(created_at: :desc)
  end

  def show
    authorize @shop
  end

  def new
    @shop = authorize Shop.new
  end

  def create
    @shop = authorize Shop.new(shop_params)
    # 归属永远取当前登录用户，不接受表单传 user_id
    @shop.user = current_user

    if @shop.save
      redirect_to shops_path, notice: "门店「#{@shop.name}」已创建"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @shop
  end

  def update
    authorize @shop

    if @shop.update(shop_params)
      redirect_to shops_path, notice: "门店「#{@shop.name}」已更新"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @shop
    @shop.destroy
    redirect_to shops_path, notice: "门店已删除"
  end

  def toggle_status
    authorize @shop
    @shop.update!(status: !@shop.status)

    redirect_to shops_path, notice: @shop.status ? "门店已恢复营业" : "门店已停止营业"
  end

  private
    def set_shop
      @shop = Shop.find(params[:id])
    end

    def shop_params
      params.expect(shop: %i[
        name contact_phone store_code mch_id description status delivery_time
        delivery_fee_in_yuan mini_fee_in_yuan packaging_fee_in_yuan
      ])
    end
end
