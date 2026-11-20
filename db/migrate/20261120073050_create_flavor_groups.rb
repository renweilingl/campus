class CreateFlavorGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :flavor_groups do |t|
      t.string :name, null: false
      # 添加方式：false 单选 / true 多选；单选时最少最多由模型强制为 1/1
      t.boolean :multi_select, null: false, default: false
      # 最少/最多选择几项；多选时最多为 0 表示不限
      t.integer :min_select, null: false, default: 1
      t.integer :max_select, null: false, default: 1
      # 排序权重：列表按它降序排，数字越大越靠前
      t.integer :recommend, null: false, default: 0
      t.references :good, null: false, foreign_key: true

      t.timestamps
    end

    # 同一菜品下口味分组名不能重复
    add_index :flavor_groups, [ :good_id, :name ], unique: true
  end
end
