class Student < ApplicationRecord
  belongs_to :turing_module, optional: true
  has_many :student_attendances, dependent: :destroy
  has_many :attendances, through: :student_attendances
  has_many :zoom_aliases

  validates_uniqueness_of :zoom_id, allow_blank: true

  def self.find_or_create_from_participant(participant)
    student = Student.find_by(zoom_id: participant.id)
    return student if student
    Student.create(zoom_id: participant.id, name: participant.name)
  end

  def self.have_slack_ids
    !Student.where.not(slack_id: nil).empty?
  end 

  def latest_zoom_alias
    zoom_aliases.order(created_at: :DESC).first
  end
end
