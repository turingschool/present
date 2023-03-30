class ZoomMeeting < ApplicationRecord
  has_many :zoom_aliases
  has_one :attendance, as: :meeting
end