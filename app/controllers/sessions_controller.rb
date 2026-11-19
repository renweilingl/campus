class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
  end

  def create
    credentials = login_params
    @phone = credentials[:phone]

    failure_reason = nil
    user = login(credentials[:phone], credentials[:password]) do |_candidate, reason|
      failure_reason = reason
    end

    if user
      redirect_to_before_login_path(root_path, notice: "登录成功")
    else
      flash.now[:alert] = failure_reason == :inactive ? "账号已被禁用，请联系管理员" : "手机号或密码错误"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to login_path, notice: "已退出登录"
  end

  private
    def login_params
      params.expect(session: %i[phone password])
    end
end
