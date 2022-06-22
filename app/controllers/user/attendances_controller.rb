class User::AttendancesController < User::BaseController
  def new
    @module = TuringModule.find(params[:turing_module_id])
    @attendance = Attendance.new
  end

  def create
    turing_module = TuringModule.find(params[:turing_module_id])
    zoom_meeting = ZoomMeeting.new(params[:attendance][:zoom_meeting_id])
    if zoom_meeting.valid_id?
      attendance = CreateAttendanceFacade.take_attendance(zoom_meeting, turing_module, current_user, populate_students?)
      redirect_to attendance_path(attendance)
    else
      flash[:error] = "It appears you have entered an invalid Zoom Meeting ID. Please double check the Meeting ID and try again."
      redirect_to new_turing_module_attendance_path(turing_module)
    end
  end

  def show
    @attendance = Attendance.find(params[:id])
    @module = @attendance.turing_module
  end

private
  def populate_students?
    ActiveModel::Type::Boolean.new.cast(params[:attendance][:populate_students])
  end
end
