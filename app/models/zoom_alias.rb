class ZoomAlias < ApplicationRecord
  belongs_to :student, optional: true
  belongs_to :zoom_attendance, optional: true
end