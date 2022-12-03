class SlackFacade 
   def self.get_and_create_slack_members(channel_id, turing_module) 
        channel_members = SlackService.get_channel_members(channel_id)[:data]
        channel_members.each do |member|
            turing_module.slack_members.create(member[:attributes]) if !turing_module.slack_members.exists?(slack_user_id: member[:attributes][:slack_user_id])
        end 
   end 
end 