class User::PopuliTransferController < User::BaseController
  def new
    attendance = Attendance.find(params[:attendance_id])
    render locals: {
      facade: PopuliTransferFacade.new(attendance)
    }
  end

  def create
    attendance = Attendance.find(params[:attendance_id])
    PopuliTransferJob.perform_async(attendance.id, params[:populi_meeting_id])
    flash[:success] = "Transferring attendance to Populi. Please confirm in Populi that #{populi_attendance_link(attendance)} is accurate."
    redirect_to attendance
  end

private
  def populi_attendance_link(attendance)
    "<a href='#{attendance.populi_url}'>this attendance</a>"
  end
end