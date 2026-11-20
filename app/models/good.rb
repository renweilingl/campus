class Good < ApplicationRecord
  # belongs_to 自带的 presence 校验文案是英文 "must exist"，项目没有 zh-CN locale，
  # 所以同 Category 的做法：关掉它自带的 required、改用自带中文文案的校验；
  # DB 层 user_id / shop_id / category_id 仍是 NOT NULL
  belongs_to :user, optional: true
  belongs_to :shop, optional: true
  belongs_to :category, optional: true
  validates :user, presence: { message: "必须存在" }
  validates :shop, presence: { message: "必须存在" }
  validates :category, presence: { message: "必须存在" }

  # 金额字段以“分”存储；表单与列表统一走 *_in_yuan 读写，避免各处手写 / 100.0
  MONEY_ATTRIBUTES = %i[price].freeze

  IMAGE_URL_FORMAT = %r{\Ahttps?://\S+\z}i

  validates :name, presence: { message: "不能为空" },
                   length: { maximum: 20, message: "不能超过 20 个字符" },
                   uniqueness: { scope: :shop_id, message: "已被使用" }
  validates :unit, presence: { message: "不能为空" },
                   length: { maximum: 10, message: "不能超过 10 个字符" }
  validates :image_url, length: { maximum: 255, message: "不能超过 255 个字符" },
                        format: { with: IMAGE_URL_FORMAT, message: "需为 http(s) 开头的链接" },
                        allow_blank: true
  validates :price, :stock, :recommend,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
                            message: "必须是不小于 0 的整数" }

  # user_id 是冗余归属，必须和门店的真实东家一致；category 也必须属于同一门店，
  # 否则会出现跨门店的脏数据；走控制器时 user / shop 都取自 current_user、
  # category 只能从本店分类里选，这条兜住 console / seed / 以后的新代码
  validate :shop_belongs_to_user
  validate :category_belongs_to_shop

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

  private
    def shop_belongs_to_user
      return if shop.nil? || user.nil?

      errors.add(:shop, "不属于该账号") unless shop.user_id == user.id
    end

    def category_belongs_to_shop
      return if category.nil? || shop.nil?

      errors.add(:category, "不属于该门店") unless category.shop_id == shop.id
    end
end
