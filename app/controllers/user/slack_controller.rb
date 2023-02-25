class User::SlackController < ApplicationController 

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