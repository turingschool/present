class ZoomAlias < ApplicationRecord
  belongs_to :student, optional: true
  belongs_to :zoom_meeting, optional: true
  belongs_to :turing_module

  validates_presence_of :name
  validates :name, uniqueness: {scope: :turing_module_id}
end