class AddUniqueIndexToShopsUserId < ActiveRecord::Migration[8.1]
  def up
    remove_extra_shops

    # user_id 上有外键，MySQL 不允许单独删掉外键依赖的索引（错误 1553），
    # 只能在同一条 ALTER 里同时换掉；单条 ALTER 在 MySQL 8+ 是原子 DDL
    execute <<~SQL
      ALTER TABLE shops
        DROP INDEX index_shops_on_user_id,
        ADD UNIQUE INDEX index_shops_on_user_id (user_id)
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE shops
        DROP INDEX index_shops_on_user_id,
        ADD INDEX index_shops_on_user_id (user_id)
    SQL
  end

  private
    # 加唯一索引前先把存量的一人多店收敛掉：同一账号只保留 created_at 最早
    # （并列时 id 最小）的一家。这里用裸 SQL，迁移不能依赖可能已改名的应用模型；
    # 删除不可逆，down 只还原索引、不会恢复被删掉的门店。
    def remove_extra_shops
      extra_ids = select_values(<<~SQL).map(&:to_i)
        SELECT id FROM (
          SELECT id, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at, id) AS rn
          FROM shops
        ) AS ranked WHERE ranked.rn > 1
      SQL
      return if extra_ids.empty?

      say "清理一人多店：删除门店 id #{extra_ids.join(", ")}，每个账号只保留最早创建的一家"
      execute("DELETE FROM shops WHERE id IN (#{extra_ids.join(", ")})")
    end
end
