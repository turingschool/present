class User::AccountMatchController < ApplicationController
  def new 
    # meeting = ZoomMeeting.new(params[:zoom_meeting_id])
    # @students = current_module.students
    render locals: {
      facade: AccountMatchFacade.new(current_module, params[:zoom_meeting_id])
    }
  end 

private
  def current_module
    @current_module ||= TuringModule.find(params[:turing_module_id])
  end
end 