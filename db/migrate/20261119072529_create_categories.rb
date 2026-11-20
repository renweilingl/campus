class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.boolean :visible, null: false, default: true
      t.boolean :must_order, null: false, default: false
      # 推荐权重：列表按它降序排，数字越大越靠前
      t.integer :recommend, null: false, default: 0
      # 分类同时挂在账号和门店上，shop_id 才是数据边界，user_id 是冗余归属
      t.references :user, null: false, foreign_key: true
      t.references :shop, null: false, foreign_key: true

      t.timestamps
    end

    # 同一门店下分类名不能重复，不同门店之间可以重名
    add_index :categories, [ :shop_id, :name ], unique: true
  end
end
