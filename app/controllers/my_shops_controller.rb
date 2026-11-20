class MyShopsController < ApplicationController
  # 自助只收基础信息：营业状态走门店列表的开关按钮、收款商户号属支付配置，
  # 都不在自助范围；store_code 系统生成且不可改，表单上只读展示。
  # 字段子集刻意比 ShopsController::SHOP_FIELDS 窄，改这里时不要顺手放宽
  MY_SHOP_FIELDS = %i[
    name contact_phone description delivery_time
    delivery_fee_in_yuan mini_fee_in_yuan packaging_fee_in_yuan
  ].freeze

  before_action :set_shop

  def edit
  end

  def update
    if @shop.update(my_shop_params)
      redirect_to edit_my_shop_path, notice: "门店「#{@shop.name}」已更新"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_shop
      @shop = current_user.shop
      if @shop.nil?
        redirect_to root_path, alert: "还没有门店，请联系管理员开通后再管理门店信息。"
        return
      end

      # 记录永远是 current_user.shop；/shops 已收为管理员专属，店主自助用仅店主的 update_own?
      authorize @shop, :update_own?
    end

    def my_shop_params
      params.expect(shop: MY_SHOP_FIELDS)
    end
end
