class Student < ApplicationRecord
  belongs_to :turing_module, optional: true
  has_many :student_attendances, dependent: :destroy
  has_many :attendances, through: :student_attendances
  has_many :student_attendance_hours, through: :student_attendances
  has_many :zoom_aliases
  has_many :slack_presence_checks

  validates_presence_of :name

  validates_uniqueness_of :slack_id, scope: :turing_module_id, allow_blank: true

  validates_uniqueness_of :populi_id, allow_blank: true

  def self.have_slack_ids 
    Student.where.not(slack_id: nil).any?
  end 

  def latest_zoom_alias
    zoom_aliases.order(created_at: :DESC).limit(1).first
  end

  def zoom_name
    latest_zoom_alias.name if latest_zoom_alias
  end

  def zoom_alias_names
    zoom_aliases.pluck(:name)
  end
end
