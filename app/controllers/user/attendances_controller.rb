class User::AttendancesController < User::BaseController
  def new
    @module = TuringModule.find(params[:turing_module_id])
    @attendance = Attendance.new
  end

  def create
    turing_module = TuringModule.find(params[:turing_module_id])
    begin
      attendance = CreateAttendanceFacade.take_attendance(params[:attendance][:meeting_url], turing_module, current_user)
      redirect_to attendance_path(attendance)
    rescue InvalidMeetingError => error
      flash[:error] = error.message
      redirect_to new_turing_module_attendance_path(turing_module)
    end
  end

  def show
    @attendance = Attendance.find(params[:id])
    @facade = AttendanceShowFacade.new(@attendance.child)
    @module = @attendance.turing_module
  end

  def edit
    @attendance = Attendance.find(params[:id])
  end

  def update
    @attendance = Attendance.find(params[:id])
    @attendance.update(attendance_params)
    CreateAttendanceFacade.retake_attendance(@attendance)
    redirect_to attendance_path(@attendance)
  end

  def save_zoom_alias
    student = Student.find(params[:id])
    zoom_alias = ZoomAlias.find(params[:student][:zoom_alias])
    zoom_alias.update(student: student)
    attendance = Attendance.find(params[:attendance_id])
    retake_zoom_attendance(attendance)
    redirect_to attendance_path(attendance)
  end

  def retake_zoom_attendance(attendance)
    turing_module = attendance.turing_module
    zoom_link = attendance.zoom_attendance.zoom_meeting_id
    attendance.student_attendances.destroy_all
    CreateAttendanceFacade.take_attendance(zoom_link, turing_module, current_user)
  end

private
  def attendance_params
    params.require(:attendance).permit(:attendance_time)
  end
end
