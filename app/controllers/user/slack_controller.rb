class User::SlackController < ApplicationController 
    def import_students
        slack_channel_id = params[:slack_channel_id]
        turing_module = TuringModule.find(params[:turing_module_id])
        channel_members = SlackFacade.get_and_create_slack_members(slack_channel_id, turing_module)
        if channel_members
            flash[:success] = "#{turing_module.slack_members.count} members from Cohort have been imported"
        else
            flash[:error] = "Please provide a valid channel id."
        end
        redirect_to turing_module_slack_channel_import_path(turing_module)
    end 

    def new 
        @module = TuringModule.find(params[:turing_module_id])
    end 

    def connect_accounts
        params[:students].each do |student_id, slack_id| 
            Student.update(student_id, :slack_id => slack_id)
        end
        flash[:success] = "Successfully connected Slack accounts."
        redirect_to turing_module_students_path(params[:turing_module_id])
    end 

    def create 
        @module = TuringModule.find(params[:turing_module_id])
        if !params[:slack_channel_id].empty?
            @module.update(slack_channel_id: params[:slack_channel_id])
            flash[:success] = "Successfully uploaded Channel #{params[:slack_channel_id]}"
            redirect_to turing_module_zoom_integration_path(@module)
        else
            flash[:error] = "Please provide a Channel ID"
            render :new
        end 
    end 

end 