class CreateFlavors < ActiveRecord::Migration[8.1]
  def change
    create_table :flavors do |t|
      t.string :name, null: false
      # 加价以“分”存储，默认 0 元；表单与列表统一走 price_in_yuan 读写
      t.integer :price, null: false, default: 0
      # 排序权重：列表按它降序排，数字越大越靠前
      t.integer :recommend, null: false, default: 0
      t.references :flavor_group, null: false, foreign_key: true

      t.timestamps
    end

    # 同一分组下口味名不能重复
    add_index :flavors, [ :flavor_group_id, :name ], unique: true
  end
end
