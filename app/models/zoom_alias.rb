class ZoomAlias < ApplicationRecord
  belongs_to :student, optional: true
  belongs_to :zoom_meeting

  validates_presence_of :name
end