class User::AccountMatchController < ApplicationController
  def new 
    begin
      render locals: {
        facade: AccountMatchFacade.new(current_module, params[:zoom_meeting_id])
      }
    rescue InvalidMeetingError => error
      flash[:error] = error.message
      redirect_to turing_module_zoom_integration_path
    end
  end 

  def create
    current_module.attendances.destroy_all #if this is a redo
    begin
      params[:student].each do |student_id, ids|
        Student.update!(student_id, {slack_id: ids[:slack_id]})
        ZoomAlias.create(name: ids[:zoom_id], student_id: student_id)
      end
      flash[:success] = "#{current_module.name} is now set up. Happy attendance taking!"
      redirect_to current_module
    rescue ActiveRecord::RecordInvalid => error
      flash[:error] = "We're sorry, something isn't quite working. Make sure you are assigning a different Slack User for each student."
      redirect_to new_turing_module_account_match_path(current_module, zoom_meeting_id: params[:zoom_meeting_id])
    end
  end

private
  def current_module
    @current_module ||= TuringModule.find(params[:turing_module_id])
  end
end 