class GoodsController < ApplicationController
  before_action :set_good, only: %i[edit update destroy]
  before_action :require_category, only: %i[new create]
  before_action :load_categories, only: %i[new create edit update]

  def index
    # recommend 是推荐指数，同指数时按 id 保证顺序稳定
    @goods = policy_scope(Good).order(recommend: :desc, id: :asc)
  end

  def new
    @good = authorize Good.new
  end

  def create
    @good = authorize Good.new(good_params)
    # 归属永远取当前登录用户和他自己的门店，不接受表单传 user_id / shop_id
    @good.user = current_user
    @good.shop = current_user.shop

    if @good.save
      redirect_to goods_path, notice: "菜品「#{@good.name}」已创建"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @good
  end

  def update
    authorize @good

    if @good.update(good_params)
      redirect_to goods_path, notice: "菜品「#{@good.name}」已更新"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @good
    @good.destroy
    redirect_to goods_path, notice: "菜品已删除"
  end

  private
    def set_good
      @good = Good.find(params[:id])
    end

    # 菜品必须挂在分类下；本店还没有分类时表单必然校验失败，
    # 所以直接引去创建分类，而不是摆一个选不出分类的表单
    def require_category
      return if current_user.shop&.categories&.exists?

      redirect_to categories_path, alert: "请先创建菜品分类，再新增菜品"
    end

    def load_categories
      @categories = policy_scope(Category).order(recommend: :desc, id: :asc)
    end

    def good_params
      # image_url 由上传回调写 OSS 路径生成，不收表单值；表单只提交图片文件 image_file
      params.expect(good: %i[name category_id price_in_yuan unit stock recommend on_sale must_order image_file])
    end
end
