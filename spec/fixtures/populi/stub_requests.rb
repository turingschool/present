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
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_person_1.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_2}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_person_2.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_3}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_person_3.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_4}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_person_4.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_5}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_person_5.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_6}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_person_6.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_7}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_person_7.json'))
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
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_enrollments.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_2}/students").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_enrollments.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_3}/students").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_enrollments.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_4}/students").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_enrollments.json'))
end

def stub_academic_terms
  stub_request(:get, "https://turing-validation.populi.co/api2/academicterms").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_academic_terms.json'))
end

def stub_current_academic_term
  stub_request(:get, "https://turing-validation.populi.co/api2/academicterms/current").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/current_academic_term.json')) 
end

def stub_course_offerings_by_term
  term_1 = '295946'
  term_2 = '295898'
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings").
    with(
      body: {academic_term_id: term_1},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_courseofferings_by_term_1.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings").
    with(
      body: {academic_term_id: term_2},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_courseofferings_by_term_2.json'))
end

def stub_successful_update_student_attendance
  course_offering_id = "10547884"
  course_offering_id_2 = '10547831'
  enrollment_id_1 = "76297621"
  enrollment_id_2 = "76296027"
  enrollment_id_3 = "76296028"
  enrollment_id_4 = "76296029"
  enrollment_id_5 = "76296030"
  enrollment_id_6 = "76296031"
  status_present = "PRESENT"
  status_absent = "ABSENT"
  status_tardy = "TARDY"
  status_excused = "EXCUSED"
  course_meeting_id_1 = "5314"
  course_meeting_id_2 = '1962'

  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_2}/students/#{enrollment_id_2}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status_present},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance_success_1.json'))

  # update_response = File.read('spec/fixtures/populi/update_student_attendance_success.json')

  @update_attendance_stub1 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_1}/attendance/update").         
    with(
      body: {course_meeting_id: course_meeting_id_1, status: "PRESENT"},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance_success.json')) 
  
  @update_attendance_stub2 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_2}/attendance/update").         
    with(
      body: {course_meeting_id: course_meeting_id_1, status: "PRESENT"},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance_success.json')) 
  # Absent
  
  @update_attendance_stub3 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_3}/attendance/update").         
    with(
      body: {course_meeting_id: course_meeting_id_1, status: "ABSENT"},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance_success.json')) 
  # Absent due to tardiness
  
  @update_attendance_stub4 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_4}/attendance/update").         
    with(
      body: {course_meeting_id: course_meeting_id_1, status: "ABSENT"},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance_success.json')) 
  
  @update_attendance_stub5 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_5}/attendance/update").         
    with(
      body: {course_meeting_id: course_meeting_id_1, status: "TARDY"},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance_success.json')) 
  
  @update_attendance_stub6 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_6}/attendance/update").         
    with(
      body: {course_meeting_id: course_meeting_id_1, status: "TARDY"},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance_success.json')) 
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
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance_course_meeting_does_not_exist.json'))

  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_2}/students/#{enrollment_id_2}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance_course_offering_not_found.json'))

  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_3}/students/#{enrollment_id_3}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_3, status: status},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance_enrollment_does_not_exist.json'))

  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_4}/students/#{enrollment_id_4}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_4, status: status},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance_finalized_enrollment_error.json'))
end
