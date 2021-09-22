class InningsController < ApplicationController 
    def show 
        @inning = Inning.find(params[:id])
    end 

    def create 
        new_inning = Inning.create(inning_params)
        redirect_to inning_path(new_inning)
    end 

    private 

    def inning_params
        params.permit(:name)
    end 
end 