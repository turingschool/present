module ApplicationHelper
    def slack_members(turing_module)
            a = turing_module.slack_members.sort_by {|x| x.name}.map do |slack_member|
                [slack_member.name,slack_member.slack_user_id]
            end
            a << ["Not Yet Assigned", ""]
      end

    def find_closest_match(student)
        first_name = student.name.split(" ").first
        members_from_slack = slack_members(student.turing_module)
        match = members_from_slack.find do |name_and_slack_id|
            name_and_slack_id.first.include?(first_name)
        end 
       return match[1] if match 
       return "" 
    end 
end