class PopuliTransferJob
  include Sidekiq::Job

  def perform(attendance_id)
    Attendance.find(attendance_id).transfer_to_populi!
  end
end
