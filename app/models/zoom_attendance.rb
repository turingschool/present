class ZoomAttendance < ApplicationRecord 
  belongs_to :attendance
  has_one :turing_module, through: :attendance
  has_many :zoom_aliases, dependent: :destroy

  def am_or_pm
    meeting_time.in_time_zone('Mountain Time (US & Canada)').strftime('%p')
  end

  def pretty_time
    meeting_time.in_time_zone('Mountain Time (US & Canada)').strftime('%l:%M %p').strip
  end

  def find_or_create_zoom_alias(name)
    aliases = turing_module.zoom_aliases.where(name: name)
    if aliases.empty?
      ZoomAlias.create!(name: name, zoom_attendance: self)
      return nil
    else
      return aliases.first
    end
  end

  def unclaimed_aliases
    self.zoom_aliases.where(student: nil)
  end
end 