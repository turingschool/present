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
      student.slack_presence_checks.create(presence: response[:presence], check_time: Time.now)
      HoneyBadger.notify(response.to_s) unless response[:ok]
    end
  end
end
