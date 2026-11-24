class PrinterPolicy < ApplicationPolicy
  # 打印机是账号自己的设备：登录即可看列表（没有时看空状态）和新增，
  # 改删只能对本人名下的；管理员没有特权（同 Category 的哲学）
  def index?
    true
  end

  def create?
    true
  end

  def update?
    record.user_id == user.id
  end

  def destroy?
    record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end
end
