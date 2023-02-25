class TuringModule < ApplicationRecord
  belongs_to :inning
  has_many :attendances, dependent: :destroy
  has_many :students, dependent: :destroy

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

  def account_match_complete 
    self.students.have_slack_ids && self.students.have_zoom_ids
    # checking to make sure some students have slack ids and some have zoom ids. 
    # if some students have both slack/zoom ids, that tells us that a user went through the match process
  end 
end
