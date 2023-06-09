class User::StudentsController < User::BaseController
  def index
    @module = TuringModule.find(params[:turing_module_id])
  end

  def show
    @student = Student.find(params[:id])
    @module = @student.turing_module
  end

  def update
    student = Student.find(params[:id])
    student.update(student_params)
    redirect_to student
  end

private
  def student_params
    params.require(:student).permit(:turing_module_id)
  end
end
