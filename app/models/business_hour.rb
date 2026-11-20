class BusinessHour < ApplicationRecord
  # belongs_to 自带的 presence 校验文案是英文 "must exist"，项目没有 zh-CN locale，
  # 所以同 Category / Good 的做法：关掉它自带的 required、改用自带中文文案的校验；
  # DB 层 shop_id 仍是 NOT NULL
  belongs_to :shop, optional: true
  validates :shop, presence: { message: "必须存在" }

  validates :start_time, :end_time, presence: { message: "不能为空" }
  validate :time_range_valid
  validate :no_overlap_with_siblings

  MINUTES_PER_DAY = 24 * 60

  # 结束不早于开始就是跨天段（如 22:00 - 02:00）
  def cross_day?
    return false if start_time.blank? || end_time.blank?

    end_minutes <= start_minutes
  end

  # 列表展示用：跨天段在结束时间前标“次日”
  def label
    return "" if start_time.blank? || end_time.blank?

    "#{stamp(start_time)} - #{cross_day? ? '次日 ' : ''}#{stamp(end_time)}"
  end

  # 把时间段拆成当日分钟轴上的闭开区间集合；跨天段拆成 [start, 24:00) 和 [00:00, end) 两段
  def minute_intervals
    return [] if start_time.blank? || end_time.blank?

    finish = end_minutes
    finish += MINUTES_PER_DAY if finish <= start_minutes
    if finish > MINUTES_PER_DAY
      [ [ start_minutes, MINUTES_PER_DAY ], [ 0, finish - MINUTES_PER_DAY ] ]
    else
      [ [ start_minutes, finish ] ]
    end
  end

  private
    def start_minutes
      start_time.hour * 60 + start_time.min
    end

    def end_minutes
      end_time.hour * 60 + end_time.min
    end

    def stamp(time)
      time.strftime("%H:%M")
    end

    # 起止相同在环形分钟轴上会被当成整天，语义含糊，直接拒掉
    def time_range_valid
      return if start_time.blank? || end_time.blank?

      errors.add(:end_time, "不能与开始时间相同") if start_minutes == end_minutes
    end

    # 多个时间段在环形分钟轴上不允许相交，否则“现在是否营业”会有两个答案
    def no_overlap_with_siblings
      return if shop.nil? || minute_intervals.empty? || errors[:end_time].any?

      siblings = shop.business_hours.where.not(id: id)
      siblings.each do |other|
        overlapped = minute_intervals.any? do |mine|
          other.minute_intervals.any? { |theirs| mine[0] < theirs[1] && theirs[0] < mine[1] }
        end
        if overlapped
          errors.add(:base, "与已有时间段「#{other.label}」重叠")
          return
        end
      end
    end
end
