class ShopsController < ApplicationController
  before_action :set_shop, only: %i[show edit update destroy toggle_status]

  # 编辑表单里没有归属字段，user_id 只在 create 时另外收，见 shop_params_with_owner；
  # store_code 由系统生成且不可修改，所以两个动作都不收，见 Shop#assign_store_code
  SHOP_FIELDS = %i[
    name contact_phone mch_id description status delivery_time
    delivery_fee_in_yuan mini_fee_in_yuan packaging_fee_in_yuan
  ].freeze

  def index
    @shops = policy_scope(Shop).order(created_at: :desc)
  end

  def show
    authorize @shop
  end

  def new
    @shop = authorize Shop.new
    @owner_candidates = owner_candidates
  end

  def create
    @shop = authorize Shop.new(shop_params_with_owner)

    if @shop.save
      redirect_to shops_path, notice: "门店「#{@shop.name}」已创建"
    else
      # 表单要重画归属下拉，候选列表得再取一次
      @owner_candidates = owner_candidates
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
      params.expect(shop: SHOP_FIELDS)
    end

    # 归属由管理员在创建表单里选定，不再默认挂到当前登录用户
    def shop_params_with_owner
      params.expect(shop: SHOP_FIELDS + [ :user_id ])
    end

    # 一人一店：只列启用且名下还没有门店的账号
    def owner_candidates
      User.without_shop.order(:phone)
    end
end
