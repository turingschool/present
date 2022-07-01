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
    if student.update(student_params)
      flash[:success] = 'Your changes have been saved.'
      if request.referer.include? 'attendances'
        redirect_to request.referer
      else
        redirect_to student_path(student)
      end
    else
      flash[:error] = student.errors.full_messages.to_sentence
      redirect_to request.referer
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
    if params[:student]
     params.require(:student).permit(:name, :zoom_email, :zoom_id)
    else 
      params.permit(:name, :zoom_email, :zoom_id, :turing_module_id)
    end 
  end
end
