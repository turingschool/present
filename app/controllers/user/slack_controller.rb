class User::SlackController < User::BaseController

    def new 
        @module = TuringModule.find(params[:turing_module_id])
    end 

    def create 
        @module = TuringModule.find(params[:turing_module_id])
        if !params[:slack_channel_id].empty?
            @module.update(slack_channel_id: params[:slack_channel_id])
            redirect_to new_turing_module_account_match_path(@module)
        else
            flash[:error] = "Please provide a Channel ID"
            render :new
        end 
    end 

end 