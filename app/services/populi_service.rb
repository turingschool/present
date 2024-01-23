class PopuliService
  extend Limiter::Mixin
  # Rate limit update_student_attendance api call to 50 requests per minute
  limit_method :update_student_attendance, rate: 50 

  def initialize
    check_env_vars
    PopuliAPI.connect(
        url: ENV["POPULI_API_URL"],  
        access_key: ENV["POPULI_API_ACCESS_KEY"]
    )
  end

  def get_person(id)
    response = conn.get("people/#{id}")
    parse_response(response)
  end

  def get_current_academic_term
      response = conn.get("academicterms/current")
      parse_response(response)
  end

  def get_students(course_offering_id)
    enrollments = get_enrollments(course_offering_id)
    student_ids = enrollments[:data].map { |enrollment| enrollment[:student_id] }
    students = Hash.new
    students[:body] = student_ids.map { |id| get_person(id) }
    students
  end

  def get_enrollments(course_offering_id)
    parse_response(conn.get("courseofferings/#{course_offering_id}/students"))
  end

  def get_terms
    PopuliAPI.get_academic_terms
  end

  def get_term_courses(term_id)
    PopuliAPI.get_term_course_instances(term_id: term_id)
  end

  def update_student_attendance(instance_id, meeting_id, person_id, status)
    PopuliAPI.update_student_attendance(instanceID: instance_id, meetingID: meeting_id, personID: person_id, status: status.upcase)
  end

  def course_meetings(course_id)
    PopuliAPI.get_course_instance_meetings(instanceID: course_id)
  end

private
  def check_env_vars
    if ENV["POPULI_API_URL"] == FAKE_POPULI_URL || ENV["POPULI_API2_URL"] == FAKE_POPULI_URL
      Rails.logger.warn("WARNING: POPULI_API_URL environment variable is not set. Using a fake url. This may cause issues with features that utilize the Populi API")
    end
    if ENV["POPULI_API_ACCESS_KEY"] == FAKE_POPULI_ACCESS_KEY || ENV["POPULI_API2_ACCESS_KEY"] == FAKE_POPULI_ACCESS_KEY
      Rails.logger.warn("WARNING: POPULI_API_ACCESS_KEY environment variable is not set. Using a fake access key. This may cause issues with features that utilize the Populi API")
    end
  end

  def conn
    Faraday.new(
      url: ENV["POPULI_API2_URL"],
      headers: {
        'Authorization' => "Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}"
      }
    )
  end

  def parse_response(response)
    JSON.parse(response.body, symbolize_names: true)
  end
end