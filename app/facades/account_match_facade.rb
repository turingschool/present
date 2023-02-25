class AccountMatchFacade
  include StringMatcher

  attr_reader :module

  def initialize(turing_module, zoom_meeting_id)
    @module = turing_module
    @participants = ZoomMeeting.new(zoom_meeting_id).participants
    @participants = clean_participant_data
  end

  def slack_options
    @slack_options ||= slack_channel_members.map do |member|
      [member[:attributes][:name], member[:attributes][:slack_user_id]]
    end.push(["Not In Channel", nil])
  end

  def best_matching_slacker(student)
    slack_member_names = slack_channel_members.map {|member| member[:attributes][:name]}
    match = find_jarow_match(student.name, slack_member_names)
    slack_options.find do |slack_name, _|
      slack_name == match
    end.last
  end

  def slack_channel_members
    @slack_channel_members ||= SlackService.get_channel_members(self.module.slack_channel_id)[:data]
  end

  def zoom_options
    @zoom_options ||= participants.map do |participant|
      [participant.name, participant.id]
    end.push(["Not Present", nil])
  end

  def best_matching_zoomer(student)
    zoom_names = zoom_options.map {|option, value| option}
    match = find_jarow_match(student.name, zoom_names.uniq)
    zoom_options.find do |zoom_name, _|
      zoom_name == match
    end.last
  end

private
  attr_reader :participants

  def clean_participant_data
    participants.reject do |participant|
      participant.id.empty?
    end.uniq do |participant|
      participant.name
    end.sort_by do |participant|
      participant.name
    end
  end
end