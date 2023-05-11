class User::PopuliTransferController < User::BaseController
  def new
    @attendance = Attendance.find(params[:attendance_id])
  end

  def create
    @attendance = Attendance.find(params[:attendance_id])
    PopuliTransferJob.perform_async(@attendance.id)
    flash[:success] = "Transfering attendance to Populi. Please confirm in Populi that attendance is accurate."
    redirect_to @attendance
  end
end