class User::InningsController < User::BaseController
  def show
    @inning = Inning.find(params[:id])
  end
end
