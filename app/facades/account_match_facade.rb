class AccountMatchFacade
  include StringMatcher

  attr_reader :module, :zoom_meeting

  def initialize(turing_module, zoom_meeting_id)
    @module = turing_module
    @zoom_meeting = ZoomMeeting.from_meeting_details(zoom_meeting_id)
  end

  def slack_options(student)
    slack_members_by_match(student).map do |member|
      [member.name, member.id]
    end.unshift(["Not In Channel", nil])
  end

  def best_matching_slacker(student)
    slack_members_by_match(student).first.id
  end

  def zoom_options(student)
   zoom_participants_by_match(student).map do |participant|
      participant.name
    end.unshift(["Not Present", nil])
  end

  def best_matching_zoomer(student)
    zoom_participants_by_match(student).first.name
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

  def zoom_participants_by_match(student)
    @zoom_meeting.participants.sort_by do |participant|
      string_distance(student.name, participant.name)
    end.reverse
  end
end