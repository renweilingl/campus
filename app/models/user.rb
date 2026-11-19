class User < ApplicationRecord
  authenticates_with_sorcery!

  PHONE_FORMAT = /\A1[3-9]\d{9}\z/
  ROLES = %w[user admin].freeze
  STATUSES = %w[disabled enabled].freeze

  enum :role, ROLES.index_by(&:to_sym), default: "user"
  enum :status, STATUSES.index_by(&:to_sym), default: "enabled"

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

  private
    def password_required?
      new_record? || password.present?
    end
end
