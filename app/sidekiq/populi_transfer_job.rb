class PopuliTransferJob
  include Sidekiq::Job

  def perform(attendance_id, populi_meeting_id)
    Attendance.find(attendance_id).transfer_to_populi!(populi_meeting_id)
  end
end
