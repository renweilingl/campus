class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :phone, null: false
      t.string :crypted_password
      t.string :salt
      t.string :nickname
      t.string :role, null: false, default: "user"
      t.string :status, null: false, default: "enabled"

      t.timestamps null: false
    end

    add_index :users, :phone, unique: true
  end
end
