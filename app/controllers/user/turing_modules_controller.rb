class User::TuringModulesController < User::BaseController
  def show
    @module = TuringModule.find(params[:id])
  end

  def create
    inning = Inning.find(params[:inning_id])
    new_module = inning.turing_modules.create(turing_module_params)
    redirect_to inning_path(inning)
  end

  private

  def turing_module_params
    params.require(:turing_module).permit(:program, :module_number)
  end
end
