class User::AttendancesController < User::BaseController
  before_action :find_attendance_by_id, only: [:show, :edit, :update, :destroy]
  before_action :find_attendance_by_attendance_id, only: [:update_zoom_alias, :update_zoom_alias_as_an_instructor, :retake]

  def create
    @turing_module = TuringModule.find(params[:turing_module_id])
    begin
      attendance = CreateAttendanceFacade.take_attendance(params[:attendance][:meeting_url], @turing_module, current_user)
      redirect_to attendance_path(attendance)
    rescue InvalidMeetingError => error
      flash[:error] = error.message
      if error.message == "Populi meeting was not created successfully."
        render "shared/_populi_transfer_error_instructions"
      else
        redirect_to request.referrer
      end
    rescue URI::InvalidURIError => error
      flash[:error] = ZoomMeeting.invalid_error
      redirect_to request.referrer
    end
  end

  def show
    @module = @attendance.turing_module
  end

  def edit
  end

  def update
    @attendance.update_time(params[:attendance][:attendance_time])
    @attendance.rerecord
    redirect_to attendance_path(@attendance)
  end

  def update_zoom_alias_as_an_instructor
    if params[:commit] == "Remove"
      zoom_alias = ZoomAlias.find(params[:zoom_alias])
      zoom_alias.update(student: nil)
    else 
      instructor = Student.find_or_create_by(name: "Instructor", turing_module_id: params[:turing_module_id])
      zoom_alias = ZoomAlias.find_by(name: "#{params[:attendance][:zoom_alias]}")
      zoom_alias.update(student: instructor)
    end
    @attendance.rerecord
    redirect_to attendance_path(@attendance)
  end

  def update_zoom_alias
    student = Student.find(params[:id])
    zoom_alias = ZoomAlias.find(params[:student][:zoom_alias])
    if params[:commit] == "Undo"
      zoom_alias.update(student: nil)
    else
      zoom_alias.update(student: student)
    end
    @attendance.rerecord
    redirect_to attendance_path(@attendance)
  end

  def destroy
    module_id = @attendance.turing_module.id  
    attendance_details = {
      id: @attendance.id,
      turing_module_id: @attendance.turing_module_id,
      user_id: @attendance.user_id,
      meeting_type: @attendance.meeting_type,
      meeting_id: @attendance.meeting_id,
      end_time: @attendance.end_time
    }
    if @attendance.destroy
      logger.info("Attendance #{@attendance.id} deleted by user #{current_user.email}. Deleted Attendance Details: #{attendance_details.inspect}")
    end
    redirect_to turing_module_path(module_id)
    flash[:success] = "Attendance successfully deleted."
  end

  def retake
    @attendance.rerecord
    redirect_to attendance_path(@attendance)
  end

  private

  def find_attendance_by_id
    @attendance = Attendance.find(params[:id])
  end

  def find_attendance_by_attendance_id
    @attendance = Attendance.find(params[:attendance_id])
  end
end
