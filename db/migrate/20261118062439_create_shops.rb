class CreateShops < ActiveRecord::Migration[8.1]
  def change
    create_table :shops do |t|
      t.string :name, null: false
      t.string :contact_phone, null: false
      # 三个金额字段统一以“分”为单位存储，见 Shop#MONEY_ATTRIBUTES
      t.integer :delivery_fee, null: false, default: 0
      t.integer :delivery_time, null: false, default: 0
      t.string :description
      t.integer :mini_fee, null: false, default: 0
      t.integer :packaging_fee, null: false, default: 0
      t.boolean :status, null: false, default: true
      t.string :store_code, null: false
      t.string :mch_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :shops, :store_code, unique: true
  end
end
