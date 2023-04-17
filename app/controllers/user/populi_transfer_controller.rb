class User::PopuliTransferController < User::BaseController
  def new
    @attendance = Attendance.find(params[:attendance_id])
  end

  def create
    @attendance = Attendance.find(params[:attendance_id])
    @attendance.transfer_to_populi!
    flash[:success] = "Success! Student Attendances have been transferred to Populi. Please double check that the attendance in Populi is accurate."
    redirect_to @attendance
  end
end