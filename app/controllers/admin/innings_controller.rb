class Admin::InningsController < Admin::BaseController
  before_action :find_inning, only: [:edit, :update]
  
  def edit
  end
  
  def update
  end

  private

  def find_inning
    @inning = Inning.find(params[:id])
  end
end
