class Printer < ApplicationRecord
  # belongs_to 自带的 presence 校验文案是英文 "must exist"，项目没有 zh-CN locale，
  # 所以同 Category / Good 的做法：关掉它自带的 required、改用自带中文文案的校验；
  # DB 层 user_id 仍是 NOT NULL
  belongs_to :user, optional: true
  validates :user, presence: { message: "必须存在" }

  # 品牌枚举键 -> 中文名牌面；表单下拉和列表展示都走它
  BRAND_LABELS = { "feie" => "飞蛾", "zhongwu" => "中午" }.freeze

  enum :brand, { feie: "feie", zhongwu: "zhongwu" }

  validates :name, presence: { message: "不能为空" },
                   length: { maximum: 20, message: "不能超过 20 个字符" },
                   uniqueness: { scope: :user_id, message: "已被使用" }
  validates :code, presence: { message: "不能为空" },
                   length: { maximum: 50, message: "不能超过 50 个字符" },
                   uniqueness: { message: "已被使用" }
  validates :key, presence: { message: "不能为空" },
                  length: { maximum: 100, message: "不能超过 100 个字符" }

  def brand_label
    BRAND_LABELS[brand]
  end
end
