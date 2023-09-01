class Admin::InningsController < Admin::BaseController
  def update
    @inning = Inning.find(params[:id])
  end
end
