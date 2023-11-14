
class Admin::ReportsController < Admin::BaseController
  include ApplicationHelper
  require 'csv'

  def index
    @students = Inning.find_by(current: true).students
  end

  def student
    @student = Student.find(params[:student_id])
    if params[:start_date] && params[:end_date]
      @student_attendance_hours = @student.report(params[:start_date], params[:end_date])
    end

    respond_to do |format|
      format.html
      format.csv do
        send_data student_csv_report(@student_attendance_hours), 
            type: 'text/csv; charset=utf-8; header=present', 
            filename: "#{@student.name}-#{params[:start_date]}-to-#{params[:end_date]}.csv"
      end
    end
  end

  private 
  def student_csv_report(attendance_hours)
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Status","Potential Minutes", "Active Minutes","Date","Start","End","Type","Check Method"]
      attendance_hours.each do |hour|
        csv << [hour.status, hour.potential_minutes, hour.duration, "#{short_date(hour.start)}",  "#{pretty_time(hour.start)}", "#{pretty_time(hour.end_time)}", hour.attendance_type, hour.check_method]
      end
    end
    return csv_data
  end
end