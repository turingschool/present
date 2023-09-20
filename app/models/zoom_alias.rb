class ZoomAlias < ApplicationRecord
  belongs_to :student, optional: true
  belongs_to :zoom_meeting
  belongs_to :turing_module

  validates_presence_of :name
end