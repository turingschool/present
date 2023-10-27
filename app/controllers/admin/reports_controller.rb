class Admin::ReportsController < Admin::BaseController
  def index
    require 'csv'
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Name"]
      Student.all.each do |student|
        csv << [student.name]
      end
    end

    send_data csv_data, 
              type: 'text/csv; charset=utf-8; header=present', 
              filename: "student-test.csv"
  end
end