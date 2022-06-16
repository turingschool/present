class Attendance < ApplicationRecord
  belongs_to :turing_module
  belongs_to :user
  has_many :student_attendances
  has_many :students, through: :student_attendances

  validates_presence_of :zoom_meeting_id
  validates_uniqueness_of :zoom_meeting_id

  def am_or_pm
    meeting_time.in_time_zone('Mountain Time (US & Canada)').strftime('%p')
  end

  def pretty_time
    meeting_time.in_time_zone('Mountain Time (US & Canada)').strftime('%l:%M %p').strip
  end
  
  def create_visiting_students(participants)
    participants.each do |participant|
      new_student = students.create(name: participant[:name], zoom_email: participant[:user_email], zoom_id:  participant[:id])
      new_student_attendance = student_attendances.where(student_id: new_student.id)
      new_student_attendance.update(status: participant[:status], join_time:  participant[:join_time])
    end 
  end
end
