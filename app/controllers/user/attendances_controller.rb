class User::AttendancesController < User::BaseController
  def new
    @module = TuringModule.find(params[:turing_module_id])
    @attendance = Attendance.new
  end

  def create
    @module = TuringModule.find(params[:turing_module_id])
    attendance = @module.attendances.create(attendance_params)
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
    ActiveModel::Type::Boolean.new.cast(params[:attendance][:populate_students])
  end
end
