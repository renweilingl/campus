module Admin
  class DashboardController < ApplicationController
    def show
      authorize [ :admin, :dashboard ], :show?

      @user = current_user
      @user_count = User.count
    end
  end
end
