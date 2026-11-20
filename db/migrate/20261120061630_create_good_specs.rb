class CreateGoodSpecs < ActiveRecord::Migration[8.1]
  def change
    create_table :good_specs do |t|
      t.string :name, null: false
      # 规格单价以“分”存储，表单与列表统一走 price_in_yuan 读写
      t.integer :price, null: false, default: 0
      # 排序权重：列表按它降序排，数字越大越靠前
      t.integer :recommend, null: false, default: 0
      t.references :good, null: false, foreign_key: true

      t.timestamps
    end

    # 同一菜品下规格名不能重复（如“大份”只会有一个）
    add_index :good_specs, [ :good_id, :name ], unique: true
  end
end
