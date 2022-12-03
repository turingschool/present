module ApplicationHelper
    def slack_members(turing_module)
            a = turing_module.slack_members.sort_by {|x| x.name}.map do |slack_member|
                [slack_member.name,slack_member.slack_user_id]
            end
            # binding.pry
        # [
        #   ['Air Nomads', 'air+nomads'],
        #   ['Earth Kingdom', 'earth+kingdom'],
        #   ['Fire Nation', 'fire+nation'],
        #   ['Water Tribes', 'water+tribes'],
        # ]
      end
end
