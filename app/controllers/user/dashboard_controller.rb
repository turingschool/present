class User::DashboardController < User::BaseController
  def show
    @my_module = current_user.my_module
  end
end
