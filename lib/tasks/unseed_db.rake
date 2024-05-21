namespace :db do
  desc 'Unseed the database'
  task unseed: :environment do
    ZoomAlias.destroy_all
    ZoomMeeting.destroy_all
    Inning.destroy_all
    TuringModule.destroy_all
    Student.destroy_all
    Attendance.destroy_all
    StudentAttendance.destroy_all

    puts "Database unseeded!"
  end
end