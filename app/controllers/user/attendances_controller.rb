class User::AttendancesController < User::BaseController
  def new
    @module = TuringModule.find(params[:turing_module_id])
    @attendance = Attendance.new
  end

  def create
    @module = TuringModule.find(params[:turing_module_id])
    attendance = @module.attendances.create(attendance_params)
    # AttendanceTaker.take_attendance(attendance, user)
    CreateAttendanceFacade.run(attendance, current_user, populate_students?)
    redirect_to turing_module_path(@module)
  end

  def show
    @module = TuringModule.find(params[:turing_module_id])
    @attendance = Attendance.find(params[:id])
  end

  private
  def attendance_params
    params.require(:attendance).permit(:zoom_meeting_id).merge(user: current_user)
  end

  def populate_students?
    populate_students = params.require(:attendance)[:populate_students]
    populate_students == "1" ? true : false
  end
end
