class GoodPolicy < ApplicationPolicy
  # 没有门店的账号也能进列表（看到空状态提示），增删改才需要门店
  def index?
    true
  end

  # record 是还没归属的新记录，所以这里只看当前账号有没有门店
  def create?
    user.shop.present?
  end

  def update?
    own_shop?
  end

  def destroy?
    own_shop?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      shop = user.shop
      return scope.none if shop.nil?

      scope.where(shop_id: shop.id)
    end
  end

  private
    # 菜品和菜品分类一样是门店自己的经营数据：管理员没有特权，只能管自己门店的
    def own_shop?
      shop = user.shop
      shop.present? && record.shop_id == shop.id
    end
end
