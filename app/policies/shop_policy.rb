class ShopPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    owner_or_admin?
  end

  def create?
    true
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
