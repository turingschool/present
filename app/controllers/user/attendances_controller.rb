class User::AttendancesController < User::BaseController
  def new
    @module = TuringModule.find(params[:turing_module_id])
    @attendance = Attendance.new
  end

  def create
    @module = TuringModule.find(params[:turing_module_id])
    attendance = @module.attendances.create(attendance_params)
    AttendanceTaker.take_attendance(attendance, current_user)
    redirect_to user_turing_module_path(@module)
  end

  private
  def attendance_params
    params.require(:attendance).permit(:zoom_meeting_id).merge(user: current_user)
  end
end
