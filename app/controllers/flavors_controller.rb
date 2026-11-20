class FlavorsController < ApplicationController
  # 口味是口味分组的从属数据、分组又是菜品的从属数据：
  # 授权仍然落在菜品上（GoodPolicy#update?，本店菜品），两级都从父记录里找，越权 id 直接 404
  before_action :set_good
  before_action :set_group
  before_action :set_flavor, only: %i[edit update destroy]

  def index
    @flavors = @group.flavors.order(recommend: :desc, id: :asc)
  end

  def new
    @flavor = @group.flavors.new
  end

  def create
    @flavor = @group.flavors.new(flavor_params)

    if @flavor.save
      redirect_to good_flavor_group_flavors_path(@good, @group), notice: "口味「#{@flavor.name}」已创建"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @flavor.update(flavor_params)
      redirect_to good_flavor_group_flavors_path(@good, @group), notice: "口味「#{@flavor.name}」已更新"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @flavor.destroy
    redirect_to good_flavor_group_flavors_path(@good, @group), notice: "口味已删除"
  end

  private
    def set_good
      @good = Good.find(params[:good_id])
      authorize @good, :update?
    end

    def set_group
      @group = @good.flavor_groups.find(params[:flavor_group_id])
    end

    def set_flavor
      @flavor = @group.flavors.find(params[:id])
    end

    def flavor_params
      params.expect(flavor: %i[name price_in_yuan recommend])
    end
end
