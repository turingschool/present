class Admin::ReportsController < Admin::BaseController
  def index
    @students = Inning.find_by(current: true).students
    # require 'csv'
    # csv_data = CSV.generate(headers: true) do |csv|
    #   csv << ["Name"]
    #   Student.all.each do |student|
    #     csv << [student.name]
    #   end
    # end

    # send_data csv_data, 
    #           type: 'text/csv; charset=utf-8; header=present', 
    #           filename: "student-test.csv"
  end

  def student
    @student = Student.find(params[:student_id])
    if params[:start_date] && params[:end_date]
      @student_attendance_hours = @student.report(params[:start_date], params[:end_date])
    end
  end
end