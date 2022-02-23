class User::InningsController < User::BaseController 
    def show 
        @inning = Inning.find(params[:id])
    end 

    def create 
        new_inning = Inning.create(inning_params)
        redirect_to user_inning_path(new_inning)
    end 

    def index 
        @innings = Inning.order(name: :desc)
    end 

    def update 
        inning = Inning.find(params[:id])
        inning.update_current_status_for_all_other_innings
        redirect_to request.referer
    end 

    private 

    def inning_params
        params.permit(:name)
    end 
end 