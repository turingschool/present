class User::SlackController < ApplicationController 
    def import_students
        slack_channel_id = params[:slack_channel_id]
        turing_module = TuringModule.find(params[:turing_module_id])
        channel_members = SlackFacade.get_and_create_slack_members(slack_channel_id, turing_module)
        flash[:success] = "#{turing_module.slack_members.count} members from Cohort have been imported"
        redirect_to turing_module_path(turing_module)
    end 

    def new 
        @module = TuringModule.find(params[:turing_module_id])
    end 

    def add_slack_id_to_users 
        require 'pry';binding.pry
    end 

end 