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

  # image_url 存的是阿里云 OSS 的对象路径（如 goods/1/ab12.png），不是完整链接；
  # 展示时用 image_display_url 拼访问地址。路径由上传时系统生成，表单只提交图片文件
  ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze
  IMAGE_EXTENSIONS = { "image/jpeg" => ".jpg", "image/png" => ".png",
                       "image/gif" => ".gif", "image/webp" => ".webp" }.freeze
  MAX_IMAGE_SIZE = 5.megabytes

  # 表单上传的图片文件（虚拟属性）：保存前传到 OSS，并把对象路径写进 image_url
  attr_reader :image_file

  def image_file=(file)
    @image_file = file
  end

  validates :name, presence: { message: "不能为空" },
                   length: { maximum: 20, message: "不能超过 20 个字符" },
                   uniqueness: { scope: :shop_id, message: "已被使用" }
  validates :unit, presence: { message: "不能为空" },
                   length: { maximum: 10, message: "不能超过 10 个字符" }
  validates :image_url, length: { maximum: 255, message: "不能超过 255 个字符" },
                        allow_blank: true
  validates :price, :stock, :recommend,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
                            message: "必须是不小于 0 的整数" }

  # user_id 是冗余归属，必须和门店的真实东家一致；category 也必须属于同一门店，
  # 否则会出现跨门店的脏数据；走控制器时 user / shop 都取自 current_user、
  # category 只能从本店分类里选，这条兜住 console / seed / 以后的新代码
  validate :shop_belongs_to_user
  validate :category_belongs_to_shop
  validate :image_file_acceptable

  before_save :upload_image_file

  # image_url 是 OSS 对象路径，拼上 bucket 访问域名才是浏览器能用的地址
  def image_display_url
    return if image_url.blank?

    AliyunOss.instance.path_to_url(image_url)
  end

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

    def image_file_acceptable
      return if image_file.blank?

      unless ALLOWED_IMAGE_TYPES.include?(image_file.content_type)
        errors.add(:image_file, "只能是 jpg / png / gif / webp 图片")
      end
      errors.add(:image_file, "不能超过 5MB") if image_file.size > MAX_IMAGE_SIZE
    end

    # 校验通过才上传，避免表单填错时在 OSS 上留下孤儿对象；
    # 上传失败（网络 / 凭证）记成字段错误回表单，而不是抛 500
    def upload_image_file
      return if image_file.blank?

      path = oss_object_path
      AliyunOss.instance.put(path, image_file.tempfile, content_type: image_file.content_type)
      self.image_url = path
    rescue StandardError => e
      # 表单只给通用文案，真实原因（凭证缺失 / 网络 / 域名错）进日志才能查
      Rails.logger.warn("OSS 上传失败：#{e.class}: #{e.message}")
      errors.add(:image_file, "上传失败，请重试")
      throw(:abort)
    end

    # 随机文件名：菜品名可改可重名（跨门店），不能进对象路径
    def oss_object_path
      "goods/#{shop_id}/#{SecureRandom.hex(8)}#{IMAGE_EXTENSIONS[image_file.content_type]}"
    end
end
