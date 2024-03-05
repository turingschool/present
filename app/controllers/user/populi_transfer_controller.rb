class User::PopuliTransferController < User::BaseController
  def new
    attendance = Attendance.find(params[:attendance_id])
    render locals: {
      facade: PopuliTransferFacade.new(attendance)
    }
  end

  def create
    attendance = Attendance.find(params[:attendance_id])
    if params[:populi_meeting_id].blank?
      flash[:error] = "It looks like that Attendance hasn't been created in Populi yet. Please make sure you are following the directions below to create the Attendance record in Populi before proceeding"
      redirect_to new_attendance_populi_transfer_path(attendance)
    else
      PopuliTransferJob.perform_async(attendance.id, params[:populi_meeting_id])
      flash[:success] = "Transferring attendance to Populi. This could take up to 5 minutes. Please confirm in Populi that the transfer was successful."
      redirect_to attendance
    end
  end
end