class CreateBusinessHours < ActiveRecord::Migration[8.1]
  def change
    create_table :business_hours do |t|
      # 营业时间段：end 早于 start 表示跨天（如 22:00 - 次日 02:00），不另加布尔列
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.references :shop, null: false, foreign_key: true

      t.timestamps
    end
  end
end
