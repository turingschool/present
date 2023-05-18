class Inning < ApplicationRecord
  validates_presence_of :name

  has_many :turing_modules, dependent: :destroy
  has_many :students, through: :turing_modules

  def make_current_inning
    self.update(current: true)
    Inning.where.not(id: self.id).update_all(current: false)
  end

  def self.order_by_name
    order(name: :desc)
  end

  def check_presence_for_students
    students.each do |student|
      response = SlackApiService.get_presence(student.slack_id)
      if response[:ok]
        student.slack_presence_checks.create(presence: response[:presence], check_time: Time.now)
      else
        # We want to be notified if any API call to get a user's presence fails for any reason
        Honeybadger.notify("Slack Response: #{response.to_s}, Student Slack ID: #{student.slack_id.to_s}")
      end 
    end
  end
end
