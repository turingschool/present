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
    flash[:success] = "Transferring attendance to Populi. This could take up to 5 minutes. Please confirm in Populi that the transfer was successful."
    redirect_to turing_module_path(attendance.turing_module)
  end
end