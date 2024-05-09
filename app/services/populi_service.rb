class PopuliService
  extend Limiter::Mixin
  # Rate limit update_student_attendance api call to 50 requests per minute
  limit_method :update_student_attendance, rate: 50 
  limit_method :person, rate: 50 

  def initialize
    check_env_vars
  end

  def person(id)
    response = conn.get("people/#{id}")
    parse_response(response)
  end

  def current_academic_term
    response = conn.get("academicterms/current")
    parse_response(response)
  end

  def enrollments(course_offering_id)
    # enrollment objects contain student_id, catalog_course_id and status
    response = conn.get("courseofferings/#{course_offering_id}/students")
    parse_response(response)
  end

  def terms
    response = conn.get("academicterms")
    parse_response(response)
  end

  def courseofferings_by_term(term_id)
    response = conn.get("courseofferings") do |req|
      req.body = {academic_term_id: term_id}.to_json
    end
    parse_response(response)
  end

  def update_student_attendance(course_offering_id, enrollment_id, course_meeting_id, status)
    response = conn.put("courseofferings/#{course_offering_id}/students/#{enrollment_id}/attendance/update") do |req|
      req.body = {course_meeting_id: course_meeting_id, status: status}.to_json
    end
    parse_response(response)
  end
  
  def create_student_attendance(course_offering_id, enrollment_id, start_time)
    response = conn.put("courseofferings/#{course_offering_id}/students/#{enrollment_id}/attendance/update") do |req|
      req.body = {start_time: start_time, status: "excused"}.to_json
    end
    parse_response(response)
  end

  def course_meetings(course_offering_id)
    response = conn.get("courseofferings/#{course_offering_id}/coursemeetings")
    parse_response(response)
  end

private
  def check_env_vars
    if ENV["POPULI_API_URL"] == FAKE_POPULI_URL
      Rails.logger.warn("WARNING: POPULI_API_URL environment variable is not set. Using a fake url. This may cause issues with features that utilize the Populi API")
    end
    if ENV["POPULI_API_ACCESS_KEY"] == FAKE_POPULI_ACCESS_KEY
      Rails.logger.warn("WARNING: POPULI_API_ACCESS_KEY environment variable is not set. Using a fake access key. This may cause issues with features that utilize the Populi API")
    end
  end

  def conn
    Faraday.new(
      url: ENV["POPULI_API_URL"],
      headers: {
        'Authorization' => "Bearer #{ENV["POPULI_API_ACCESS_KEY"]}"
      }
    )
  end

  def parse_response(response)
    JSON.parse(response.body, symbolize_names: true)
  end
end