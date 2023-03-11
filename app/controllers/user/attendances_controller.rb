class User::AttendancesController < User::BaseController
  def new
    @module = TuringModule.find(params[:turing_module_id])
    @attendance = Attendance.new
  end

  def create
    turing_module = TuringModule.find(params[:turing_module_id])
    begin
      attendance = CreateAttendanceFacade.take_attendance(params[:attendance][:meeting_id], turing_module, current_user)
      redirect_to attendance_path(attendance)
      # REFACTOR: I'm a little nervous about catching all runtime errors here. Maybe make a custom error object?
    rescue InvalidMeetingError => error
      flash[:error] = error.message
      redirect_to new_turing_module_attendance_path(turing_module)
    end
  end

  def show
    @attendance_parent = Attendance.find(params[:id])
    if @attendance_parent.zoom_attendance
      @attendance = @attendance_parent.zoom_attendance 
      # REFACTOR figure out where to put the code for account matching now that we need it in two places
      @unclaimed_aliases = @attendance.zoom_aliases.where(student: nil).order(:name).map(&:name)
      @temp_facade = AccountMatchFacade.new(@module, @attendance.zoom_meeting_id)
    elsif @attendance_parent.slack_attendance
      @attendance = @attendance_parent.slack_attendance 
    end
    @module = @attendance_parent.turing_module
  end
end
