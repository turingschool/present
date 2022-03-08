class Student < ApplicationRecord
  belongs_to :turing_module
  has_many :student_attendances
  has_many :attendances, through: :student_attendances

  # validates_presence_of :zoom_id, :zoom_email, :name
end