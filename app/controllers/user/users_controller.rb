class User::UsersController < User::BaseController
  def update
    current_user.update(user_params)
    redirect_to current_inning
  end

  private
  def user_params
    params.permit(:turing_module_id)
  end
end
