class User::PopuliTransferController < User::BaseController
  def new
    attendance = Attendance.find(params[:attendance_id])
    render locals: {
      facade: PopuliTransferFacade.new(attendance)
    }
  end

  def time_select
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
      flash[:info] = "Transferring attendance to Populi. This will take a little while. Please wait a couple of minutes before confirming in Populi that #{populi_attendance_link(attendance)} is accurate."
      redirect_to attendance
    end
  end

private
  def populi_attendance_link(attendance)
    "<a href='#{attendance.populi_url}'>this attendance</a>"
  end
end