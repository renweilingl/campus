class User < ApplicationRecord
  authenticates_with_sorcery!

  # shops.user_id 是唯一索引，所以一个账号最多一家门店；
  # user_id 是 NOT NULL，删账号时只能连带删门店，不能置空
  has_one :shop, dependent: :destroy
  # 菜品分类也直接挂在账号上（冗余归属）。必须声明在 has_one :shop 之后：
  # 先删门店会连带删掉分类，轮到这条时关联查询只剩空集合
  has_many :categories, dependent: :destroy
  # 菜品同样直接挂在账号上（冗余归属），理由和顺序同上
  has_many :goods, dependent: :destroy

  PHONE_FORMAT = /\A1[3-9]\d{9}\z/
  ROLES = %w[user admin].freeze
  STATUSES = %w[disabled enabled].freeze

  enum :role, ROLES.index_by(&:to_sym), default: "user"
  enum :status, STATUSES.index_by(&:to_sym), default: "enabled"

  # 一人一店：能被指派为门店归属的账号，见 ShopsController#owner_candidates
  scope :without_shop, -> { enabled.where.missing(:shop) }

  validates :phone, presence: true,
                    format: { with: PHONE_FORMAT, message: "手机号格式不正确" },
                    uniqueness: true
  validates :nickname, length: { maximum: 30 }, allow_blank: true

  # sorcery 的 encrypt_password 是 before_validation 回调，所以这里直接看 password 有没有被赋值：
  # 新建必填；更新时只有传了新密码才校验，否则改个昵称也会被要求填密码
  validates :password, presence: true, length: { minimum: 6, maximum: 72 }, confirmation: true,
                       if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  # sorcery 的 authenticate 会检查这个钩子，返回 false 时登录失败并给出 :inactive 原因
  def active_for_authentication?
    enabled?
  end

  def display_name
    nickname.presence || phone
  end

  # 归属下拉里同昵称的账号会撞名，所以额外带上手机号
  def option_label
    nickname.presence ? "#{nickname}（#{phone}）" : phone
  end

  private
    def password_required?
      new_record? || password.present?
    end
end
