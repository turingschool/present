class AccountMatchFacade
  include StringMatcher

  attr_reader :module

  def initialize(turing_module, zoom_meeting_id)
    @module = turing_module
    @participant_report = ZoomMeeting.new(zoom_meeting_id).participant_report
  end

  def slack_options
    @slack_options ||= slack_channel_members.map do |member|
      [member[:attributes][:name], member[:attributes][:slack_user_id]]
    end 
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
    x1=@participants ||= participant_report.reject do |participant|
      participant[:id].empty?
    end
    x1.uniq do |participant|
      [participant[:name], participant[:id]]
    end.map do |participant|
      [participant[:name], participant[:id]]
    end
  end

  def best_matching_zoomer(student)
    zoom_names = zoom_options.map {|option, value| option}
    match = find_jarow_match(student.name, zoom_names.uniq)
    zoom_options.find do |zoom_name, _|
      zoom_name == match
    end.last
  end

private
  attr_reader :participant_report
end