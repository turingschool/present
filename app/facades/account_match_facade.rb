class AccountMatchFacade
  include StringMatcher

  attr_reader :module

  def initialize(turing_module, zoom_meeting_id)
    @module = turing_module
    @zoom_meeting_id = zoom_meeting_id
  end

  def slack_options(student)
    slack_members_by_match(student).map do |member|
      [member.name, member.id]
    end.push(["Not In Channel", nil])
  end

  def best_matching_slacker(student)
    slack_members_by_match(student).first.id
  end

  def zoom_options(student)
    participants_by_match(student).map do |participant|
      participant.id
    end.push(["Not Present", nil])
  end

  def best_matching_zoomer(student)
    participants_by_match(student).first.id
  end

private
  def slack_channel_members
    @slack_channel_members ||= SlackService.get_channel_members(self.module.slack_channel_id)[:data].map do |slack_member_data|
      Slacker.from_channel(slack_member_data)
    end
  end

  def slack_members_by_match(student)
    slack_channel_members.sort_by do |member|
      string_distance(student.name, member.name)
    end.reverse
  end

  def participants
    @participants ||= retrieve_participant_data
  end

  def retrieve_participant_data
    # REFACTOR Move this code in to Zoom meeting so that all meetings have uniq particiants
    participants = ZoomMeeting.from_meeting_details(@zoom_meeting_id).participants
    participants.uniq do |participant|
      participant.id
    end
  end

  def participants_by_match(student)
    participants.sort_by do |participant|
      # REFACTOR don't like that we have to call participant.id to get their name. Not very semantic
      string_distance(student.name, participant.id)
    end.reverse
  end
end