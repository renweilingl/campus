class CreateGoods < ActiveRecord::Migration[8.1]
  def change
    create_table :goods do |t|
      t.string :name, null: false
      # 单价以“分”存储，表单与列表统一走 price_in_yuan 读写
      t.integer :price, null: false, default: 0
      # 推荐指数：列表按它降序排，数字越大越靠前
      t.integer :recommend, null: false, default: 0
      t.string :unit, null: false
      t.integer :stock, null: false, default: 0
      # 销售状态：在售 / 停售
      t.boolean :on_sale, null: false, default: true
      t.boolean :must_order, null: false, default: false
      t.string :image_url
      # 菜品同时挂在账号、门店和分类上，shop_id 才是数据边界，user_id 是冗余归属
      t.references :user, null: false, foreign_key: true
      t.references :shop, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    # 同一门店下菜品名不能重复，不同门店之间可以重名
    add_index :goods, [ :shop_id, :name ], unique: true
  end
end
