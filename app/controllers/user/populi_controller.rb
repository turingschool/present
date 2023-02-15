class User::PopuliController < User::BaseController
    def new
        @module = TuringModule.find(params[:turing_module_id])
        service = PopuliService.new
        current_term_id = service.get_current_academic_term[:response][:termid]
        @courses = service.get_courses(current_term_id)[:response][:course_instance]
    end
end