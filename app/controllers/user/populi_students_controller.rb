class User::PopuliStudentsController < User::BaseController
    def new
      @module = TuringModule.find(params[:turing_module_id])
      @populi_students = PopuliService.new.get_students(params[:course_instance_id])[:response][:courseinstance_student].map do |student|
        ["#{student[:first]} #{"(#{(student[:preferred])}) " if student[:preferred]}#{student[:last]}", student[:personid]]
      end
    end

    def create
      @module = TuringModule.find(params[:turing_module_id])
      params[:populi_students].each do |student_id, populi_id|
        Student.update(student_id, {populi_id: populi_id})
      end
      redirect_to turing_module_path(@module)
    end
end