class User::StudentsController < User::BaseController
  def index
    @module = TuringModule.find(params[:turing_module_id])
  end

  def new
    @module = TuringModule.find(params[:turing_module_id])
    @student = Student.new
  end

  def create
    turing_module = TuringModule.find(params[:turing_module_id])
    turing_module.students.create(student_params)
    redirect_to turing_module_students_path(turing_module)
  end

private
  def student_params
    params.require(:student).permit(:name, :zoom_email, :zoom_id)
  end
end
