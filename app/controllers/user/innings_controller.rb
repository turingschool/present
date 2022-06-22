class User::InningsController < User::BaseController
    def show
        @inning = Inning.find(params[:id])
    end

    def create
        new_inning = Inning.create(inning_params)
        redirect_to inning_path(new_inning)
    end

    def index
        @innings = Inning.order_by_name
    end

    def update
        inning = Inning.find(params[:id])
        inning.make_current_inning
        redirect_to request.referer
    end

    private

    def inning_params
        params.require(:inning).permit(:name)
    end
end
