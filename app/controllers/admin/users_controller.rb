module Admin
  class UsersController < ApplicationController
    before_action :set_user, only: %i[edit update destroy toggle_status]

    def index
      # 仅管理员：policy_scope 对非管理员只收窄成空集、并不拒绝访问，必须显式 authorize
      authorize User
      @users = policy_scope(User).order(created_at: :desc)
    end

    def new
      @user = authorize User.new
    end

    def create
      @user = authorize User.new(create_params)

      if @user.save
        redirect_to admin_users_path, notice: "用户「#{@user.phone}」已创建"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @user
    end

    def update
      authorize @user

      if @user.update(update_params)
        redirect_to admin_users_path, notice: "用户「#{@user.phone}」已更新"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @user
      if @user.id == current_user.id
        redirect_to admin_users_path, alert: "不能删除自己当前登录的账号"
        return
      end
      # 有门店的账号删了会连带删店和店内数据，口径是只能禁用
      if @user.shop.present?
        redirect_to admin_users_path, alert: "用户「#{@user.phone}」名下有门店，只能禁用，不能删除"
        return
      end

      @user.destroy
      redirect_to admin_users_path, notice: "用户已删除"
    end

    def toggle_status
      authorize @user
      if @user.id == current_user.id
        redirect_to admin_users_path, alert: "不能禁用自己当前登录的账号"
        return
      end

      @user.update!(status: @user.disabled? ? :enabled : :disabled)
      redirect_to admin_users_path, notice: @user.enabled? ? "用户已启用" : "用户已禁用"
    end

    private
      def set_user
        @user = User.find(params[:id])
      end

      # 手机号是登录凭据：创建时指定，编辑页只读展示、params 也不收
      def create_params
        params.expect(user: %i[phone nickname role password password_confirmation])
      end

      def update_params
        params.expect(user: %i[nickname role password password_confirmation])
      end
  end
end
