class Student < ApplicationRecord
  belongs_to :turing_module, optional: true
  has_many :student_attendances, dependent: :destroy
  has_many :attendances, through: :student_attendances

  validates_presence_of :zoom_id
  validates_uniqueness_of :zoom_id
end
