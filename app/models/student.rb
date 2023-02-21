class Student < ApplicationRecord
  include StringMatcher
  
  belongs_to :turing_module, optional: true
  has_many :student_attendances, dependent: :destroy
  has_many :attendances, through: :student_attendances

  validates_presence_of :zoom_id
  validates_uniqueness_of :zoom_id

  def self.find_or_create_from_participant(participant)
    student = Student.find_by(zoom_id: participant[:id])
    return student if student
    Student.create(zoom_id: participant[:id], name: participant[:name])
  end
end
