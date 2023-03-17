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
      # @unclaimed_aliases = @attendance.zoom_aliases.where(student: nil).order(:name).map(&:name)
      @facade = AttendanceShowFacade.new(@attendance)
    elsif @attendance_parent.slack_attendance
      @attendance = @attendance_parent.slack_attendance 
    end
    @module = @attendance_parent.turing_module
  end

  def update
    attendance = Attendance.find(params[:attendance_id])
    student = Student.find(params[:id])
    zoom_alias = ZoomAlias.find(params[:student][:zoom_alias])
    zoom_alias.update(student: student)
      require 'pry';binding.pry

    attendance.retake
    # if params[:student][:zoom_alias]
    #   ZoomAlias.update(params[:student][:zoom_alias], student: student)
    # end
  end
end
