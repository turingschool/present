class TuringModule < ApplicationRecord
  belongs_to :inning
  has_many :attendances, dependent: :destroy
  has_many :students, dependent: :destroy

  validates_numericality_of :module_number, {
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 6,
    only_integer: true
  }

  validates_inclusion_of :calendar_integration, in: [true, false]

  validates_presence_of :program
  enum program: [:FE, :BE, :Combined, :Launch]

  def unclaimed_aliases
    ZoomAlias.where(turing_module_id: self.id).where(student_id: nil)
  end

  def name
    "#{self.program} Mod #{self.module_number}"
  end

  def account_match_complete 
    self.students.have_slack_ids# && self.students.have_zoom_aliases?
    # checking to make sure some students have slack ids and some have zoom aliases. 
    # if some students have both slack/zoom aliases, that tells us that a user went through the match process
  end 

  def attendances_by_time
    attendances.order(attendance_time: :desc)
  end
  
  def reset_students
    self.students.update_all(slack_id: nil)
    zoom_alias_ids = self.students.joins(:zoom_aliases).pluck(Arel.sql("zoom_aliases.id"))
    ZoomAlias.destroy(zoom_alias_ids)
  end
end
