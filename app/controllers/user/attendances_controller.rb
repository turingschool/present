class User::AttendancesController < User::BaseController
  def new
    @module = TuringModule.find(params[:turing_module_id])
    @attendance = Attendance.new
  end

  def create
    turing_module = TuringModule.find(params[:turing_module_id])
    begin
      attendance = CreateAttendanceFacade.take_attendance(params[:attendance][:meeting_id], turing_module, current_user)
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

  def update
    attendance = Attendance.find(params[:attendance_id])
    student = Student.find(params[:id])
    zoom_alias = ZoomAlias.find(params[:student][:zoom_alias])
    zoom_alias.update(student: student)

    attendance.retake_zoom_attendance
    redirect_to attendance_path(attendance)
  end
end
