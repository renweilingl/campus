class FlavorGroup < ApplicationRecord
  # belongs_to 自带的 presence 校验文案是英文 "must exist"，项目没有 zh-CN locale，
  # 所以同 Category / Good 的做法：关掉它自带的 required、改用自带中文文案的校验；
  # DB 层 good_id 仍是 NOT NULL
  belongs_to :good, optional: true
  validates :good, presence: { message: "必须存在" }

  # 删分组要连带删口味，否则 flavors.flavor_group_id 的外键会挡住删除
  has_many :flavors, dependent: :destroy

  validates :name, presence: { message: "不能为空" },
                   length: { maximum: 20, message: "不能超过 20 个字符" },
                   uniqueness: { scope: :good_id, message: "已被使用" }
  validates :min_select, :max_select, :recommend,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
                            message: "必须是不小于 0 的整数" }
  validate :select_limits

  # 单选就是必选且仅一项：最少最多强制 1/1，表单上也不显示这两项
  before_validation :apply_single_select_limits

  # 多选时最多为 0 表示不限，列表展示用
  def max_select_unlimited?
    multi_select? && !max_select.positive?
  end

  private
    def apply_single_select_limits
      return if multi_select

      self.min_select = 1
      self.max_select = 1
    end

    def select_limits
      return unless multi_select

      errors.add(:min_select, "不能小于 1") if min_select.to_i < 1
      if max_select.to_i.positive? && min_select.to_i > max_select.to_i
        errors.add(:max_select, "不能小于最少选择项数")
      end
    end
end
