class User::StudentsController < User::BaseController
  def index
    @module = TuringModule.find(params[:turing_module_id])
  end

  def show
    @student = Student.find(params[:id])
    @module = @student.turing_module
  end

  def destroy
    Student.destroy(params[:id])
    redirect_to turing_module_students_path(params[:turing_module_id])
  end
end
