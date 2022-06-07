class User::UsersController < User::BaseController
  def update
    current_user.update(user_params)
    redirect_to turing_module_path(current_user.my_module)
  end

  private
  def user_params
    params.permit(:turing_module_id)
  end
end
