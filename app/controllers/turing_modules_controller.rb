class TuringModulesController < ApplicationController
  def show
    @module = TuringModule.find(params[:id])
    @attendances = @module.attendances.order(created_at: :desc)
  end

  def create
    inning = Inning.find(params[:inning_id])
    new_module = inning.turing_modules.create(turing_module_params)
    redirect_to inning_path(inning)
  end 

  private

  def turing_module_params
    params[:google_spreadsheet_id] = params[:google_spreadsheet_link].split('/')[5]
    # binding.pry
    params.permit(:name, :google_spreadsheet_id, :google_sheet_name)
  end 
end
