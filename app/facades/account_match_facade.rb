class AccountMatchFacade
  include StringMatcher

  attr_reader :module

  def initialize(turing_module)
    @module = turing_module
  end

  def slack_options(student)
    slack_members_by_match(student).map do |member|
      [member.name, member.id]
    end.unshift(["Not In Channel", nil])
  end

  def best_matching_slacker(student)
    slack_members_by_match(student).first.id
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
end