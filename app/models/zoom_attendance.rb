class ZoomAttendance < ApplicationRecord 
  belongs_to :attendance
  has_one :turing_module, through: :attendance
  has_many :zoom_aliases

  def am_or_pm
    meeting_time.in_time_zone('Mountain Time (US & Canada)').strftime('%p')
  end

  def pretty_time
    meeting_time.in_time_zone('Mountain Time (US & Canada)').strftime('%l:%M %p').strip
  end

  def find_student_from_zoom_participant(participant)
    #  = zoom_aliases.where(name: participant.id)
    aliases = ZoomAlias.joins(:student).where(zoom_aliases: {name: participant.id}).where(students: {turing_module_id: attendance.turing_module.id})
    if aliases.empty?
      ZoomAlias.create!(name: participant.id, zoom_attendance: self)
      return nil
    else
      return aliases.first.student
    end
  end
end 