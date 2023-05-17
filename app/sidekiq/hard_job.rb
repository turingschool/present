class HardJob
  include Sidekiq::Job

  def perform(*args)
    puts "LOOK MA, I'M DOING IT!"
  end
end
