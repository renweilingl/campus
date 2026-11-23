Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#show"

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  resources :shops do
    member do
      patch :toggle_status
    end
  end

  # 分类只有 4 个字段，列表页已经全都展示了，所以不做详情页
  resources :categories, except: :show

  # 菜品的字段列表页也全展示了（图片以缩略图呈现），同样不做详情页
  resources :goods, except: :show do
    # 规格从属于菜品，挂在菜品路由下；列表页全字段展示，不做详情页
    resources :specs, controller: "good_specs", except: :show
    # 口味分组从属于菜品、口味从属于分组，两级嵌套；列表页全字段展示，不做详情页
    resources :flavor_groups, except: :show do
      resources :flavors, except: :show
    end
  end

  # 我的店铺：店主自助改自己门店的基础信息；营业时间段也在这里自助设置，
  # URL 不带 shop_id，记录一律取自 current_user.shop
  resource :my_shop, controller: "my_shops", only: %i[edit update] do
    resources :business_hours, except: :show
  end

  namespace :admin do
    root to: "dashboard#show"

    # 用户管理仅管理员；列表页已展示全部字段，不做详情页
    resources :users, except: :show do
      member do
        patch :toggle_status
      end
    end
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
