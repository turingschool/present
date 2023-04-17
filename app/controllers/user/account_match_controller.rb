class User::AccountMatchController < ApplicationController
  def new 
    # meeting = ZoomMeeting.new(params[:zoom_meeting_id])
    # @students = current_module.students
    render locals: {
      facade: AccountMatchFacade.new(current_module, params[:zoom_meeting_id])
    }
  end 

  def create
    if duplicate_slack_ids?
      flash[:error] = "We're sorry, something isn't quite working. Make sure you are assigning a different Slack User for each student."
      # require 'pry';binding.pry
      # render :new, locals: {
      #   facade: AccountMatchFacade.new(current_module, params[:zoom_meeting_id])
      # }
      redirect_to new_turing_module_account_match_path(current_module, zoom_meeting_id: params[:zoom_meeting_id])
    else
      current_module.attendances.destroy_all #if this is a redo
      params[:student].each do |student_id, ids|
        Student.update(student_id, {slack_id: ids[:slack_id]})
        ZoomAlias.create(name: ids[:zoom_id], student_id: student_id)
      end
      redirect_to current_module
    end
  end

private
  def current_module
    @current_module ||= TuringModule.find(params[:turing_module_id])
  end

  def duplicate_slack_ids?
    slack_id_counts = Hash.new(0)
    params[:student].each do |_, ids|
      slack_id_counts[ids[:slack_id]] += 1
      return true if slack_id_counts[ids[:slack_id]] > 1
    end
    return false
  end
end 