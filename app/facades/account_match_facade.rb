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
      [participant.name, participant.id]
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
    @participants = retrieve_participant_data
  end

  def retrieve_participant_data
    participants = ZoomMeeting.from_meeting_details(@zoom_meeting_id).participants
    participants.reject do |participant|
      participant.id.empty?
    end.uniq do |participant|
      participant.name
    end.sort_by do |participant|
      participant.name
    end
  end

  def participants_by_match(student)
    participants.sort_by do |participant|
      string_distance(student.name, participant.name)
    end.reverse
  end
end