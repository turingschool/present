class User::DashboardController < User::BaseController
  def show
    @current_inning = Inning.find_by(current: true)
  end
end
