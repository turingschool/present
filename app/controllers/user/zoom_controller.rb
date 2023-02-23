class User::ZoomController < ApplicationController 

    def new 
        @module = TuringModule.find(params[:turing_module_id])
    end 
    
    def create 
    end 

end 