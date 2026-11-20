class FlavorGroupsController < ApplicationController
  # 口味分组是菜品的从属数据：能不能管分组等价于能不能改这道菜，
  # 所以统一用 GoodPolicy#update?（本店菜品）授权，不另开策略类
  before_action :set_good
  before_action :set_group, only: %i[edit update destroy]

  def index
    # set_good 里已经按 GoodPolicy#update? 授权过本店菜品，分组只从这道菜下取，天然不越权
    @groups = @good.flavor_groups.order(recommend: :desc, id: :asc)
  end

  def new
    @group = @good.flavor_groups.new
  end

  def create
    @group = @good.flavor_groups.new(group_params)

    if @group.save
      redirect_to good_flavor_groups_path(@good), notice: "口味分组「#{@group.name}」已创建"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @group.update(group_params)
      redirect_to good_flavor_groups_path(@good), notice: "口味分组「#{@group.name}」已更新"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    redirect_to good_flavor_groups_path(@good), notice: "口味分组已删除"
  end

  private
    def set_good
      @good = Good.find(params[:good_id])
      authorize @good, :update?
    end

    # 从本菜品的分组里找，别店的 id 直接 404，越权读不到
    def set_group
      @group = @good.flavor_groups.find(params[:id])
    end

    def group_params
      params.expect(flavor_group: %i[name multi_select min_select max_select recommend])
    end
end
