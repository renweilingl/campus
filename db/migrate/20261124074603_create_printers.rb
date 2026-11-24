class CreatePrinters < ActiveRecord::Migration[8.1]
  def change
    create_table :printers do |t|
      # 品牌存枚举键（feie / zhongwu），中文名牌面由 Printer::BRAND_LABELS 映射
      t.string :brand, null: false
      t.string :name, null: false
      # 打印机编码是设备 SN，天然全局唯一：同一台设备被两个人登记就是配错了
      t.string :code, null: false
      # 打印机密钥：厂商下发的调用密钥，只在表单里读写，列表不展示
      t.string :key, null: false
      t.boolean :enabled, null: false, default: true
      # 打印机是账号自己的设备，归属只到 user
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    # 同一账号下打印机名不能重复
    add_index :printers, [ :user_id, :name ], unique: true
    add_index :printers, :code, unique: true
  end
end
