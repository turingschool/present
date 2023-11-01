class User::AttendancesController < User::BaseController
  
  def create
    turing_module = TuringModule.find(params[:turing_module_id])
    begin
      attendance = CreateAttendanceFacade.take_attendance(params[:attendance][:meeting_url], turing_module, current_user)
      redirect_to attendance_path(attendance)
    rescue InvalidMeetingError => error
      flash[:error] = error.message
      redirect_to request.referrer
    rescue URI::InvalidURIError => error
      flash[:error] = ZoomMeeting.invalid_error
      redirect_to request.referrer
    end
  end

  def show
    @attendance = Attendance.find(params[:id])
    @module = @attendance.turing_module
  end

  def edit
    @attendance = Attendance.find(params[:id])
  end

  def update
    attendance = Attendance.find(params[:id])
    attendance.update_time(params[:attendance][:attendance_time])
    attendance.rerecord
    redirect_to attendance_path(attendance)
  end

  def update_zoom_alias
    attendance = Attendance.find(params[:attendance_id])
    student = Student.find(params[:id])
    zoom_alias = ZoomAlias.find(params[:student][:zoom_alias])
    if params[:commit] == "Undo"
      zoom_alias.update(student: nil)
    else
      zoom_alias.update(student: student)
    end
    attendance.rerecord
    redirect_to attendance_path(attendance)
  end

  def destroy
    attendance = Attendance.find(params[:id])
    module_id = attendance.turing_module.id
    attendance.destroy
    redirect_to turing_module_path(module_id)
    flash[:sucess] = "Attendance successfully deleted."
  end
end
