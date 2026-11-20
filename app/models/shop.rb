class Shop < ApplicationRecord
  # belongs_to 自带的 presence 校验文案是英文 "must exist"，项目没有 zh-CN locale，
  # 所以关掉它自带的 required、改用自带中文文案的校验；DB 层 user_id 仍是 NOT NULL
  belongs_to :user, optional: true
  # 删门店要连带删分类，否则 categories.shop_id 的外键会挡住删除
  has_many :categories, dependent: :destroy
  validates :user, presence: { message: "必须存在" }
  # 一个账号只能开一家门店；DB 层 shops.user_id 也是唯一索引，见
  # 20261119062340_add_unique_index_to_shops_user_id，这里负责给出中文文案
  validates :user_id, uniqueness: { message: "该账号已拥有门店" }

  CONTACT_PHONE_FORMAT = /\A1[3-9]\d{9}\z/
  # 金额字段以“分”存储；表单与列表统一走 *_in_yuan 读写，避免各处手写 / 100.0
  MONEY_ATTRIBUTES = %i[delivery_fee mini_fee packaging_fee].freeze
  # 店铺编码由系统生成：10 位随机数字、首位不为 0，创建后不可修改。
  # 所以 store_code 既不在 shop_params 里，表单上也是 disabled 的只读框
  STORE_CODE_RANGE = (1_000_000_000..9_999_999_999)

  validates :name, presence: { message: "不能为空" },
                   length: { maximum: 50, message: "不能超过 50 个字符" }
  validates :contact_phone, presence: { message: "不能为空" },
                            format: { with: CONTACT_PHONE_FORMAT, message: "手机号格式不正确" }
  validates :store_code, presence: { message: "不能为空" },
                         uniqueness: { message: "已被使用" },
                         length: { maximum: 32, message: "不能超过 32 个字符" }
  validates :mch_id, length: { maximum: 32, message: "不能超过 32 个字符" }, allow_blank: true
  validates :description, length: { maximum: 255, message: "不能超过 255 个字符" }, allow_blank: true
  validates :delivery_fee, :mini_fee, :packaging_fee, :delivery_time,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
                            message: "必须是不小于 0 的整数" }

  before_validation :assign_store_code, on: :create
  validate :store_code_immutable, on: :update

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
    # 无条件覆盖：即使有人绕过表单塞进一个 store_code，也以系统生成的为准
    def assign_store_code
      self.store_code = SecureRandom.random_number(STORE_CODE_RANGE).to_s
    end

    # params 里已经收不到 store_code，这条兜住代码里的误改
    def store_code_immutable
      errors.add(:store_code, "生成后不可修改") if store_code_changed?
    end
end
