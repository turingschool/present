class User::PopuliTransferController < User::BaseController
  def new
    @attendance = Attendance.find(params[:attendance_id])
  end
end