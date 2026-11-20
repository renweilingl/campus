class Category < ApplicationRecord
  # belongs_to 自带的 presence 校验文案是英文 "must exist"，项目没有 zh-CN locale，
  # 所以同 Shop 的做法：关掉它自带的 required、改用自带中文文案的校验；
  # DB 层 user_id / shop_id 仍是 NOT NULL
  belongs_to :user, optional: true
  belongs_to :shop, optional: true
  validates :user, presence: { message: "必须存在" }
  validates :shop, presence: { message: "必须存在" }

  validates :name, presence: { message: "不能为空" },
                   length: { maximum: 20, message: "不能超过 20 个字符" },
                   uniqueness: { scope: :shop_id, message: "已被使用" }
  validates :recommend, numericality: { only_integer: true, greater_than_or_equal_to: 0,
                                        message: "必须是不小于 0 的整数" }

  # user_id 是冗余归属，必须和门店的真实东家一致，否则会出现跨门店的脏数据；
  # 走控制器时两个 id 都取自 current_user，这条兜住 console / seed / 以后的新代码
  validate :shop_belongs_to_user

  private
    def shop_belongs_to_user
      return if shop.nil? || user.nil?

      errors.add(:shop, "不属于该账号") unless shop.user_id == user.id
    end
end
