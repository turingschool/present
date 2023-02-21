class PopuliFacade
  include StringMatcher

  attr_reader :module
  
  def initialize(turing_module)
    @module = turing_module
    @service = PopuliService.new
  end

  def top_choice
    @top_choice ||= find_top_choice
  end

  def find_top_choice
    current_term_id = service.get_current_academic_term[:response][:termid]
    courses = service.get_courses(current_term_id)[:response][:course_instance]
    course_names = courses.map {|course| course[:abbrv]}
    match = find_jarow_match(@module.name, course_names)
    course_data = courses.find do |course|
      course[:abbrv] == match
    end
    PopuliCourse.new(course_data)
  end

  private
    def service
      @service ||= PopuliService.new
    end
end