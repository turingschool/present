class User::AccountMatchController < User::BaseController
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
    current_module.reset_students
    if process_account_match_form
      flash[:success] = "#{current_module.name} is now set up. Happy attendance taking!"
      redirect_to current_module
    else
      flash[:error] = "We're sorry, something isn't quite working. Make sure you are assigning a different Slack User for each student."
      redirect_to new_turing_module_account_match_path(current_module, zoom_meeting_id: params[:zoom_meeting_id])
    end
  end

private
  def current_module
    @current_module ||= TuringModule.find(params[:turing_module_id])
  end

  def process_account_match_form
    # REFACTOR use insert_all instead
    success = true
    params[:student].each do |student_id, ids|
      begin
        student = Student.update!(student_id, {slack_id: ids[:slack_id]})
        next if ids[:zoom_id].blank?
        student.zoom_aliases.create!(name: ids[:zoom_id], turing_module: current_module)
      rescue ActiveRecord::RecordInvalid => error
        success = false
        Rails.logger.warn "Got this error: #{error.message}\nIDs: #{ids}\nstudent: #{student_id}"
      end
    end
    return success
  end
end 