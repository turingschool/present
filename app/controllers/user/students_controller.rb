class User::StudentsController < User::BaseController
  def index
    @module = TuringModule.find(params[:turing_module_id])
  end

  def show
    @student = Student.find(params[:id])
    @module = @student.turing_module
  end

  def destroy
    student = Student.find(params[:id])
    student.destroy
    redirect_to turing_module_students_path(student.turing_module)
  end

  def edit
    @student = Student.find(params[:id])
  end

  def update
    student = Student.find(params[:id])
    if student.update(student_params) && student.add_zoom_alias(params[:student][:zoom_name])
      flash[:success] = 'Your changes have been saved.'
      redirect_to student_path(student)
    else
      flash[:error] = student.errors.full_messages.to_sentence
      redirect_to edit_student_path(student)
    end
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
    params.require(:student).permit(:name, :turing_module_id, :slack_id)
  end
end
