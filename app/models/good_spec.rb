class GoodSpec < ApplicationRecord
  # belongs_to 自带的 presence 校验文案是英文 "must exist"，项目没有 zh-CN locale，
  # 所以同 Category / Good 的做法：关掉它自带的 required、改用自带中文文案的校验；
  # DB 层 good_id 仍是 NOT NULL
  belongs_to :good, optional: true
  validates :good, presence: { message: "必须存在" }

  # 金额字段以“分”存储；表单与列表统一走 *_in_yuan 读写，避免各处手写 / 100.0
  MONEY_ATTRIBUTES = %i[price].freeze

  validates :name, presence: { message: "不能为空" },
                   length: { maximum: 20, message: "不能超过 20 个字符" },
                   uniqueness: { scope: :good_id, message: "已被使用" }
  validates :price, :recommend,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
                            message: "必须是不小于 0 的整数" }

  MONEY_ATTRIBUTES.each do |attribute|
    define_method(:"#{attribute}_in_yuan") do
      value = self[attribute]
      value && format("%.2f", value / 100.0)
    end

    # 表单以“元”提交；非法输入置 nil 交给 numericality 校验报错，而不是让 BigDecimal 抛异常 500
    define_method(:"#{attribute}_in_yuan=") do |yuan|
      yuan = yuan.to_s.strip
      self[attribute] = yuan.empty? ? 0 : (BigDecimal(yuan) * 100).round
    rescue ArgumentError
      self[attribute] = nil
    end
  end
end
