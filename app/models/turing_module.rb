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

  def check_presence_for_students!(retry_limit: 0)
    check_time = Time.now
    service = SlackApiService.new
    retry_counter = 0
    presence_checks = []
    students.each do |student|
      response = service.get_presence(student.slack_id)
      if response[:ok]
        presence_checks << { student_id: student.id, presence: response[:presence], check_time: check_time }
        retry_counter = 0
      else
        if retry_counter < retry_limit
          retry_counter += 1
          redo
        else
          # Don't retry again if we've reached the retry limit
          retry_counter = 0
          # We want to be notified if any API call to get a user's presence fails and 5 retries are unsuccessful
          Honeybadger.notify("Slack Response: #{response.to_s}, Student Slack ID: #{student.slack_id.to_s}, Student: #{student.id}: #{student.name}")
        end
      end 
    end
    SlackPresenceCheck.insert_all(presence_checks) unless presence_checks.empty?
  end

  def unclaimed_aliases
    ZoomAlias.where(turing_module_id: self.id).where(student_id: nil)
  end

  def name
    if self.Launch?
      "C#.NET Mod #{self.module_number}"  
    else
      "#{self.program} Mod #{self.module_number}"
    end
  end

  def account_match_complete 
    self.students.have_slack_ids
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
