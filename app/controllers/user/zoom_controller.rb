class User::ZoomController < User::BaseController

    def new 
        @module = TuringModule.find(params[:turing_module_id])
    end

end 