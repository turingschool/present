class User::AccountMatchController < ApplicationController
  def new 
    # meeting = ZoomMeeting.new(params[:zoom_meeting_id])
    # @students = current_module.students
    render locals: {
      facade: AccountMatchFacade.new(current_module, params[:zoom_meeting_id])
    }
  end 

  def create
    current_module.attendances.destroy_all #if this is a redo
    params[:student].each do |student_id, ids|
      Student.update(student_id, {slack_id: ids[:slack_id]})
      ZoomAlias.create(name: ids[:zoom_id], student_id: student_id)
    end
    redirect_to current_module
  end

private
  def current_module
    @current_module ||= TuringModule.find(params[:turing_module_id])
  end
end 