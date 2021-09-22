class Attendance < ApplicationRecord
  belongs_to :turing_module

  validates_presence_of :zoom_meeting_id
end
