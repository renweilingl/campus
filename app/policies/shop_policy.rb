class ShopPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    owner_or_admin?
  end

  # 门店只能由管理员代建，归属账号在创建表单里指定；
  # 管理员自己名下有没有门店都不影响代建，一人一店限制的是被指派的那个账号
  def create?
    user.admin?
  end

  def update?
    owner_or_admin?
  end

  def destroy?
    owner_or_admin?
  end

  def toggle_status?
    owner_or_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user.admin?

      scope.where(user_id: user.id)
    end
  end

  private
    def owner_or_admin?
      user.admin? || record.user_id == user.id
    end
end
