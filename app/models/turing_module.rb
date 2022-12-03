class TuringModule < ApplicationRecord
  belongs_to :inning
  has_many :attendances, dependent: :destroy
  has_many :students, dependent: :destroy
  has_many :slack_members, dependent: :destroy

  validates_numericality_of :module_number, {
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 4,
    only_integer: true
  }

  validates_inclusion_of :calendar_integration, in: [true, false]

  validates_presence_of :program
  enum program: [:FE, :BE, :Combined]

  def name
    "#{self.program} Mod #{self.module_number}"
  end

  def create_students_from_participants(participants)
    participants.each do |participant|
      student = Student.find_or_create_from_participant(participant)
      if !students.exists?(student.id) #in the case that a student joins more than once
        students << student
      end
    end
  end

  def students_without_slack_ids?
    !self.students.where(slack_id: nil).empty?
  end 
end
