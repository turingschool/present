def stub_persons
  personId_1 = "24490130"
  personId_2 = "24490140"
  personId_3 = "24490100"
  personId_4 = "24490062"
  personId_5 = "24490161"
  personId_6 = "24490123"
  personId_7 = "24490150"


  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_1}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_person/get_person_1.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_2}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_person/get_person_2.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_3}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_person/get_person_3.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_4}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_person/get_person_4.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_5}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_person/get_person_5.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_6}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_person/get_person_6.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_7}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_person/get_person_7.json'))
end

def stub_get_enrollments
  course_offering_1 = "10547831"
  course_offering_2 = "10547876"
  course_offering_3 = "10547836"
  course_offering_4 = "10547812"

  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_1}/students").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_enrollments/get_enrollments.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_2}/students").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_enrollments/get_enrollments.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_3}/students").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_enrollments/get_enrollments.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_4}/students").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_enrollments/get_enrollments.json'))
end

def stub_academic_terms
  stub_request(:get, "https://turing-validation.populi.co/api2/academicterms").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_terms/get_academic_terms.json'))
end

def stub_current_academic_term
  stub_request(:get, "https://turing-validation.populi.co/api2/academicterms/current").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_current_academic_term/current_academic_term.json')) 
end

def stub_course_offerings_by_term
  term_1 = "295946"
  term_2 = "295898"
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings").
    with(
      body: {"{\"academic_term_id\":\"295946\"}"=>nil},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_courseofferings_by_term/get_courseofferings_by_term_1.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings").
    with(
      body: {"academic_term_id":295946}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_courseofferings_by_term/get_courseofferings_by_term_1.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings").
    with(
      body: {"{\"academic_term_id\":\"295898\"}"=>nil},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_courseofferings_by_term/get_courseofferings_by_term_2.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings").
    with(
      body: {"academic_term_id":295898}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_courseofferings_by_term/get_courseofferings_by_term_2.json'))
end

def stub_successful_update_student_attendance
  course_offering_id = "10547831"
  course_offering_id_1 = "10547884"
  enrollment_id = "76297621"
  enrollment_id_1 = "76297621"
  enrollment_id_2 = "76296027"
  enrollment_id_3 = "76296028"
  enrollment_id_4 = "76296029"
  enrollment_id_5 = "76296030"
  enrollment_id_6 = "76296031"
  status_present = "present"
  status_absent = "absent"
  status_tardy = "tardy"
  course_meeting_id_1 = "1962"
  course_meeting_id_2 = "1963"
  course_meeting_id = "5314"
  
  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_1}/students/#{enrollment_id}/attendance/update").
  with(
    body: {course_meeting_id: course_meeting_id, status: status_present},
    headers: {
  'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
    }).
  to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_1.json'))

  @update_attendance_stub1 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_1}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_present},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_1.json'))
  
  @update_attendance_stub2 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_2}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_present},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_2.json'))
  
  @update_attendance_stub3 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_3}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_absent},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_3.json'))
  
  @update_attendance_stub4 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_4}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_absent},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_4.json'))
  
  @update_attendance_stub5 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_5}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_tardy},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_5.json'))
  
  @update_attendance_stub6 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_6}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_tardy},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_6.json'))

    @update_attendance_stub7 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_1}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status_present},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_1.json'))
  
  @update_attendance_stub8 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_2}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status_present},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_2.json'))
  
  @update_attendance_stub9 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_3}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status_absent},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_3.json'))
  
  @update_attendance_stub10 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_4}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status_absent},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_4.json'))
  
  @update_attendance_stub11 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_5}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status_tardy},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_5.json'))
  
  @update_attendance_stub12 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_6}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status_tardy},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_6.json'))
end

def stub_failed_update_student_attendance
  status = "PRESENT"
  
  # course meeting does not exist
  course_offering_id_1 = "10547884"
  enrollment_id_1 = "76297621"
  course_meeting_id_1 = "531"

  # course offering not found
  course_offering_id_2 = "105478"
  enrollment_id_2 = "76297621"
  course_meeting_id_2 = "5314"

  # enrollment does not exist
  course_offering_id_3 = "10547884"
  enrollment_id_3 = "762976"
  course_meeting_id_3 = "5314"

  # finalized enrollment error
  course_offering_id_4 = "10547884"
  enrollment_id_4 = "76297620"
  course_meeting_id_4 = "5314"

  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_1}/students/#{enrollment_id_1}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/error/update_student_attendance_course_meeting_does_not_exist.json'))

  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_2}/students/#{enrollment_id_2}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/error/update_student_attendance_course_offering_not_found.json'))

  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_3}/students/#{enrollment_id_3}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_3, status: status},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/error/update_student_attendance_enrollment_does_not_exist.json'))

  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_4}/students/#{enrollment_id_4}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_4, status: status},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/error/update_student_attendance_finalized_enrollment_error.json'))
end

def stub_course_meetings
  course_offering_id = "10547831"

  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/coursemeetings").
  with(
    headers: {
  'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
    }).
  to_return(status: 200, body: File.read('spec/fixtures/populi/get_course_meetings/get_course_meetings.json'))
end

def stub_course_meetings_for_duration
  course_offering_id = "10547831"

  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/coursemeetings").
  with(
    headers: {
  'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
    }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_course_meetings/get_course_meetings_for_duration.json'))
end

def stub_course_meetings_for_half_hours
  course_offering_id = "10547831"

  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/coursemeetings").
  with(
    headers: {
  'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
    }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_course_meetings/get_course_meetings_for_half_hours.json'))
end

def stub_course_meetings_nil
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings//coursemeetings").
  with(
    headers: {
  'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
    }).
  to_return(status: 200, body: File.read('spec/fixtures/populi/get_course_meetings/get_course_meetings.json'))
end