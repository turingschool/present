class Attendance < ApplicationRecord
  belongs_to :turing_module
  belongs_to :user

  validates_presence_of :zoom_meeting_id
end
