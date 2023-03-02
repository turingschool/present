class User::AttendancesController < User::BaseController
  def new
    @module = TuringModule.find(params[:turing_module_id])
    @attendance = Attendance.new
  end

  def create
    turing_module = TuringModule.find(params[:turing_module_id])
    # meeting = Meeting.new(params[:meeting_id])
    # CreateAttendanceFacade.take_attendance(meeting, turing_module)
    if params[:attendance]
      zoom_meeting_attendance 
    elsif params[:slack_url]
      slack_meeting_attendance
    end
  end

  def slack_meeting_attendance
    slack_url = params[:slack_url]
    turing_module = TuringModule.find(params[:turing_module_id])
    attendance = CreateAttendanceFacade.take_slack_attendance(slack_url, turing_module, current_user)
    # SlackThread.from_message_link(slack_url)
    redirect_to attendance_path(attendance)
  end 

  def zoom_meeting_attendance
    turing_module = TuringModule.find(params[:turing_module_id])
    zoom_meeting = ZoomMeeting.from_meeting_details(params[:attendance][:zoom_meeting_id])
    if zoom_meeting.valid?
      attendance = CreateAttendanceFacade.take_attendance(zoom_meeting, turing_module, current_user)
      redirect_to attendance_path(attendance)
    else
      flash[:error] = "It appears you have entered an invalid Zoom Meeting ID. Please double check the Meeting ID and try again."
      redirect_to new_turing_module_attendance_path(turing_module)
    end
  end 

  def show
    @attendance_parent = Attendance.find(params[:id])
    @attendance = @attendance_parent.zoom_attendance if @attendance_parent.zoom_attendance
    @attendance = @attendance_parent.slack_attendance if @attendance_parent.slack_attendance
    @module = @attendance_parent.turing_module
  end
end
