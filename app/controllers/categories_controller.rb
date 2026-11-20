class CategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy]

  def index
    # recommend 是推荐权重，同权重时按 id 保证顺序稳定
    @categories = policy_scope(Category).order(recommend: :desc, id: :asc)
  end

  def new
    @category = authorize Category.new
  end

  def create
    @category = authorize Category.new(category_params)
    # 归属永远取当前登录用户和他自己的门店，不接受表单传 user_id / shop_id
    @category.user = current_user
    @category.shop = current_user.shop

    if @category.save
      redirect_to categories_path, notice: "分类「#{@category.name}」已创建"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @category
  end

  def update
    authorize @category

    if @category.update(category_params)
      redirect_to categories_path, notice: "分类「#{@category.name}」已更新"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @category
    @category.destroy
    redirect_to categories_path, notice: "分类已删除"
  end

  private
    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.expect(category: %i[name visible must_order recommend])
    end
end
