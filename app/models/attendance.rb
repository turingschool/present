class Attendance < ApplicationRecord
  belongs_to :turing_module
  belongs_to :user
  has_one :slack_attendance
  has_one :zoom_attendance
  
  has_many :student_attendances, dependent: :destroy
  has_many :students, through: :student_attendances

  # validates_presence_of :zoom_meeting_id
  # validates_uniqueness_of :zoom_meeting_id

  def am_or_pm
    meeting_time.in_time_zone('Mountain Time (US & Canada)').strftime('%p')
  end

  def pretty_time
    meeting_time.in_time_zone('Mountain Time (US & Canada)').strftime('%l:%M %p').strip
  end
end
