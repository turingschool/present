class AccountMatchFacade
  include StringMatcher

  attr_reader :module

  def initialize(turing_module, zoom_meeting_id)
    @module = turing_module
    @zoom_meeting = ZoomMeeting.new(zoom_meeting_id)
  end

  def slack_options
    @slack_options ||= slack_channel_members.map do |member|
      [member[:attributes][:name], member[:attributes][:slack_user_id]]
    end 
  end

  def best_matching_slacker(student)
    slack_member_names = slack_channel_members.map {|member| member[:attributes][:name]}
    match = find_jarow_match(student.name, slack_member_names)
    slack_options.find do |slacker|
      slacker[0] == match
    end[1]
  end

  def slack_channel_members
    @slack_channel_members ||= SlackService.get_channel_members(self.module.slack_channel_id)[:data]
  end
end