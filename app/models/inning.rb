class Inning < ApplicationRecord
  validates_presence_of :name, :start_date
  validate :date_within_allowed_range

  has_many :turing_modules, dependent: :destroy
  has_many :students, through: :turing_modules

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
  
  def check_presence_for_students
    check_time = Time.now
    service = SlackApiService.new
    retry_counter = 0
    students.each do |student|
      response = service.get_presence(student.slack_id)
      if response[:ok]
        student.slack_presence_checks.create(presence: response[:presence], check_time: check_time)
        retry_counter = 0
      else
        if retry_counter < 5
          retry_counter += 1
          redo
        else
          # Don't retry again if we've done 5 retries already
          retry_counter = 0
          # We want to be notified if any API call to get a user's presence fails and 5 retries are unsuccessful
          Honeybadger.notify("Slack Response: #{response.to_s}, Student Slack ID: #{student.slack_id.to_s}")
        end
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
  end

  def date_validation(current_inning_date)
    return errors.add(:start_date, "Can't be blank") if start_date.blank?
    return errors.add(:start_date, "must be at least 7 weeks after the start of the current inning") if start_date < current_inning_date + 7.weeks 
  end
end

