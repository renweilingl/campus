class ShopPolicy < ApplicationPolicy
  # /shops 是管理员的管理台：列表、详情、增删改、营业开关全部仅管理员；
  # 店主自助走 /my_shop（update_own?）和营业时间（manage_business_hours?），不进这个模块
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  # 门店只能由管理员代建，归属账号在创建表单里指定；
  # 管理员自己名下有没有门店都不影响代建，一人一店限制的是被指派的那个账号
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

  # 我的店铺：店主改自己门店的基础信息，管理员不通过这个入口代改
  def update_own?
    record.user_id == user.id
  end

  # 营业时间由店主自己设置，管理员不代管——和上面的管理员口径刻意不同，
  # 改这条前先确认产品口径没变
  def manage_business_hours?
    record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user.admin?

      scope.where(user_id: user.id)
    end
  end
end
