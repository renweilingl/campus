class UserPolicy < ApplicationPolicy
  # 用户管理是管理员专属管理台：列表、增删改、启禁全部仅管理员
  def index?
    user.admin?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def toggle_status?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user.admin?

      scope.none
    end
  end
end
