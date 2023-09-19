class Admin::DashboardController < Admin::BaseController
  def show
    @innings = Inning.current_and_future
  end
end
