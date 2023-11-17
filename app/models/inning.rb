class Inning < ApplicationRecord
  validates_presence_of :name, :start_date
  validate :date_within_allowed_range

  has_many :turing_modules, dependent: :destroy
  has_many :students, through: :turing_modules
  has_many :attendances, through: :turing_modules

  def date_within_allowed_range
    if Inning.none?
      # Execute as normal without triggering validation error
    else current_inning_date = Inning.find_by_current(true).start_date
      date_validation(current_inning_date)
    end
  end

  def make_current_inning
    self.update(current: true)
    Inning.where.not(id: self.id).update_all(current: false)
  end

  def self.order_by_name
    order(name: :desc)
  end

  def self.current_and_future
    where(["current = ? or start_date >= ?", true, Date.today]).order(:start_date)
  end

  def process_presence_data_for_slack_attendances!
    SlackThread.joins(:inning).where(inning: {id: self.id}, presence_check_complete: false).each do |slack_thread|
      begin
        slack_thread.record_duration_from_presence_checks!
      rescue => e
        Honeybadger.notify("Error recording presence data for Slack Thread #{slack_thread.message_link}: #{e.message}")
      end
    end
  end

  def create_turing_modules
    turing_modules.create!(program: 'Combined', module_number: 4)
    3.times do |i|
      turing_modules.create!(program: 'FE', module_number: i + 1)
    end
    3.times do |i|
      turing_modules.create!(program: 'BE', module_number: i + 1)
    end
    6.times do |i|
      turing_modules.create!(program: 'Launch', module_number: i + 1)
    end
  end

  def date_validation(current_inning_date)
    return errors.add(:start_date, "Can't be blank") if start_date.blank?
    return errors.add(:start_date, "must be at least 7 weeks after the start of the current inning") if start_date < current_inning_date + 7.weeks 
  end
end

