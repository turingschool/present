class User::StudentsController < User::BaseController
  def index
    @module = TuringModule.find(params[:turing_module_id])
  end
end
