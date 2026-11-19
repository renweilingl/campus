# 初始账号。开发/测试环境使用演示账号；生产环境必须通过 SEED_ADMIN_PHONE / SEED_ADMIN_PASSWORD
# 显式提供，绝不会写入下面这个演示密码。
DEMO_PASSWORD = "campus123456"

def seed_user(phone:, password:, nickname:, role:, status: "enabled")
  user = User.find_or_initialize_by(phone: phone)
  created = user.new_record?

  user.nickname = nickname
  user.role = role
  user.status = status

  # 已存在的账号不重置密码，否则每次 db:seed 都会把线上密码改掉
  if created
    user.password = password
    user.password_confirmation = password
  end

  user.save!
  [ user, created ]
end

admin_phone = ENV["SEED_ADMIN_PHONE"]
admin_password = ENV["SEED_ADMIN_PASSWORD"]

unless Rails.env.production?
  admin_phone ||= "13800000000"
  admin_password ||= DEMO_PASSWORD
end

if admin_phone && admin_password
  admin, created = seed_user(phone: admin_phone, password: admin_password, nickname: "管理员", role: "admin")
  puts "#{created ? '已创建' : '已存在'}管理员账号：#{admin.phone}"
  warn "管理员使用的是演示默认密码，请尽快修改" if created && ENV["SEED_ADMIN_PASSWORD"].nil?
else
  warn "跳过管理员账号：生产环境需要设置 SEED_ADMIN_PHONE 和 SEED_ADMIN_PASSWORD"
end

unless Rails.env.production?
  member, = seed_user(phone: "13800000001", password: DEMO_PASSWORD, nickname: "普通用户", role: "user")
  disabled, = seed_user(phone: "13800000002", password: DEMO_PASSWORD, nickname: "已禁用账号",
                        role: "user", status: "disabled")

  puts "演示账号：#{member.phone} / #{DEMO_PASSWORD}（普通用户）"
  puts "演示账号：#{disabled.phone} / #{DEMO_PASSWORD}（已禁用，用于验证登录拦截）"
end
