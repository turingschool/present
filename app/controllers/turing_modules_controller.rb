class TuringModulesController < ApplicationController
  def show
    @module = TuringModule.find(params[:id])
    @attendances = @module.attendances.order(created_at: :desc)
  end
end
