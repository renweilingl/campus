class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_login

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden

  private
    # sorcery 在未登录时回调这里（config.sorcery.not_authenticated_action 的默认值）
    def not_authenticated
      redirect_to login_path, alert: "请先登录"
    end

    def render_forbidden
      render "errors/forbidden", status: :forbidden
    end
end
