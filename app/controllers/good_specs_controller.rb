class GoodSpecsController < ApplicationController
  # 规格是菜品自己的从属数据：能不能管规格等价于能不能改这道菜，
  # 所以统一用 GoodPolicy#update?（本店菜品）授权，不另开策略类
  before_action :set_good
  before_action :set_spec, only: %i[edit update destroy]

  def index
    # set_good 里已经按 GoodPolicy#update? 授权过本店菜品，规格只从这道菜下取，天然不越权
    @specs = @good.specs.order(recommend: :desc, id: :asc)
  end

  def new
    @spec = @good.specs.new
  end

  def create
    @spec = @good.specs.new(spec_params)

    if @spec.save
      redirect_to good_specs_path(@good), notice: "规格「#{@spec.name}」已创建"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @spec.update(spec_params)
      redirect_to good_specs_path(@good), notice: "规格「#{@spec.name}」已更新"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @spec.destroy
    redirect_to good_specs_path(@good), notice: "规格已删除"
  end

  private
    def set_good
      @good = Good.find(params[:good_id])
      authorize @good, :update?
    end

    # 从本菜品的规格里找，别店的 id 直接 404，越权读不到
    def set_spec
      @spec = @good.specs.find(params[:id])
    end

    def spec_params
      params.expect(good_spec: %i[name price_in_yuan recommend])
    end
end
