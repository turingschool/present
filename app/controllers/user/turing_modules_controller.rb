class User::TuringModulesController < User::BaseController
  def show
    @module = TuringModule.find(params[:id])
  end
end
