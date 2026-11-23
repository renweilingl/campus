module ApplicationHelper
  # 顶栏左侧的栏目名，对齐设计图里白顶栏左边的标题（如“团购活动”）。
  # 按 controller_path 映射到栏目，而不是直接用页面 title，
  # 这样“编辑门店”“新增门店”等子页面顶栏仍然显示所属栏目“门店”。
  SECTION_TITLES = {
    "dashboard" => "控制台",
    "shops" => "门店管理",
    "business_hours" => "营业时间",
    "categories" => "菜品分类",
    "goods" => "菜品管理",
    "good_specs" => "规格设置",
    "flavor_groups" => "口味分组",
    "flavors" => "口味",
    "my_shops" => "我的店铺",
    "admin/dashboard" => "管理后台",
    "admin/users" => "用户管理",
    "sessions" => "登录"
  }.freeze

  def current_section_title
    SECTION_TITLES.fetch(controller_path) { content_for(:title).presence || "Campus" }
  end
end
