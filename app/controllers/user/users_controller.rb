class User::UsersController < User::BaseController
  def update
    current_user.update(user_params)
    turing_module = TuringModule.find(params[:turing_module_id])
    current_user.update(turing_module: turing_module)
    flash[:success] = "Success! #{turing_module.name} is now set as your Module."
    redirect_to turing_module_path(turing_module)
  end

  private
  def user_params
    params.permit(:turing_module_id)
  end
end
