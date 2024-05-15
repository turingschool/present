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
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/person/person_1.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_2}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/person/person_2.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_3}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/person/person_3.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_4}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/person/person_4.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_5}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/person/person_5.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_6}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/person/person_6.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/people/#{personId_7}").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/person/person_7.json'))
end

def stub_enrollments
  course_offering_1 = "10547831"
  course_offering_2 = "10547876"
  course_offering_3 = "10547836"
  course_offering_4 = "10547812"
  course_offering_5 = "10548007"

  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_1}/students").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/enrollments/enrollments.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_2}/students").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/enrollments/enrollments.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_3}/students").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/enrollments/enrollments.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_4}/students").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/enrollments/enrollments.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_5}/students").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/enrollments/enrollments_2.json'))
end

def stub_academic_terms
  stub_request(:get, "https://turing-validation.populi.co/api2/academicterms").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/terms/academic_terms.json'))
end

def stub_current_academic_term
  stub_request(:get, "https://turing-validation.populi.co/api2/academicterms/current").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/current_academic_term/current_academic_term.json')) 
end

def stub_course_offerings_by_term
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings").
    with(
      body: {"{\"academic_term_id\":\"295946\"}"=>nil},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/courseofferings_by_term/courseofferings_by_term_1.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings").
    with(
      body: {"academic_term_id":295946}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/courseofferings_by_term/courseofferings_by_term_1.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings").
    with(
      body: {"{\"academic_term_id\":\"295898\"}"=>nil},
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/courseofferings_by_term/courseofferings_by_term_2.json'))

  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings").
    with(
      body: {"academic_term_id":295898}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/courseofferings_by_term/courseofferings_by_term_2.json'))
end

def stub_successful_update_student_attendance
  course_offering_id = "10547831"
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
  
  @update_attendance_stub1 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_1}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_present}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_1.json'))
  
  @update_attendance_stub2 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_2}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_present}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_2.json'))
  
  @update_attendance_stub3 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_3}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_absent}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_3.json'))
  
  @update_attendance_stub4 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_4}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_absent}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_4.json'))
  
  @update_attendance_stub5 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_5}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_tardy}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_5.json'))
  
  @update_attendance_stub6 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_6}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_tardy}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_6.json'))

    @update_attendance_stub7 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_1}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status_present}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_1.json'))
  
  @update_attendance_stub8 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_2}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status_present}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_2.json'))
  
  @update_attendance_stub9 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_3}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status_absent}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_3.json'))
  
  @update_attendance_stub10 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_4}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status_absent}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_4.json'))
  
  @update_attendance_stub11 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_5}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status_tardy}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_5.json'))
  
  @update_attendance_stub12 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_6}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_2, status: status_tardy}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_6.json'))
end

def stub_create_student_attendance
  course_offering_id = "10548007"
  enrollment_id_1 = "76298082"
  start_time = "2024-05-13T15:30:00.000+00:00".to_time.to_s

  course_offering_id_2 = "10547831"
  enrollment_id_2 = "76297621"
  start_time_2 = "2023-01-10T15:45:22.000+00:00".to_time.to_s
  
  start_time_3 = "2022-11-30T20:00:59.999+00:00".to_time.to_s
  start_time_4 = "2023-08-23T15:30:00.000+00:00".to_time.to_s
  start_time_5 = "2022-11-28T16:00:00.000+00:00".to_time.to_s
  start_time_6 = "2023-01-21T16:00:00.000+00:00".to_time.to_s

  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_1}/attendance/update").
    with(
      body: {start_time: start_time, status: "excused"}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/create_student_attendances/create_student_attendances_success_1.json'), headers: {})

  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_2}/students/#{enrollment_id_2}/attendance/update").
    with(
      body: {start_time: start_time_2, status: "excused"}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/create_student_attendances/create_student_attendances_success_1.json'), headers: {})
  
  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_2}/students/#{enrollment_id_2}/attendance/update").
    with(
      body: {start_time: start_time_3, status: "excused"}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/create_student_attendances/create_student_attendances_success_1.json'), headers: {})
  
  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_2}/students/#{enrollment_id_2}/attendance/update").
    with(
      body: {start_time: start_time_4, status: "excused"}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/create_student_attendances/create_student_attendances_success_1.json'), headers: {})
  
  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_2}/students/#{enrollment_id_2}/attendance/update").
    with(
      body: {start_time: start_time_5, status: "excused"}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/create_student_attendances/create_student_attendances_success_1.json'), headers: {})
  
  stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_2}/students/#{enrollment_id_2}/attendance/update").
    with(
      body: {start_time: start_time_6, status: "excused"}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/create_student_attendances/create_student_attendances_success_1.json'), headers: {})
end

def stub_single_failure_update_student_attendance_no_coursestudent
  course_offering_id = "10547831"
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

  @update_attendance_stub1 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_1}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_present}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_1.json'))
  
  @update_attendance_stub2 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_2}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_present}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_2.json'))
  
  @update_attendance_stub3 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_3}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_absent}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_3.json'))
  
  @update_attendance_stub4 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_4}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_absent}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/error/update_student_attendance_not_found.json'))
  
  @update_attendance_stub5 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_5}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_tardy}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_5.json'))
  
  @update_attendance_stub6 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_6}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_tardy}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_6.json'))
end

def stub_single_failure_update_student_attendance
  course_offering_id = "10547831"
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

  @update_attendance_stub1 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_1}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_present}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_1.json'))
  
  @update_attendance_stub2 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_2}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_present}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_2.json'))
  
  @update_attendance_stub3 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_3}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_absent}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_3.json'))
  
  @update_attendance_stub4 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_4}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_absent}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/error/update_student_attendance_no_course_meeting.json'))
  
  @update_attendance_stub5 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_5}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_tardy}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_5.json'))
  
  @update_attendance_stub6 = stub_request(:put, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/students/#{enrollment_id_6}/attendance/update").
    with(
      body: {course_meeting_id: course_meeting_id_1, status: status_tardy}.to_json,
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/update_student_attendance/success/update_student_attendance_success_6.json'))
end

def stub_course_meetings
  course_offering_id = "10547831"
  course_offering_id_2 = "10548007"
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/coursemeetings").
  with(
    headers: {
  'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
  }).
  to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings/course_meetings.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_2}/coursemeetings").
  with(
    headers: {
  'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
    }).
  to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings/course_meetings_2.json'))
end
        
def stub_no_course_meetings
  course_offering_id_1 = "10548007"
  course_offering_id_2 = "10547831"
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_1}/coursemeetings").
  with(
    headers: {
  'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
    }).
  to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings/no_course_meetings.json'))
  
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id_2}/coursemeetings").
  with(
    headers: {
  'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
    }).
  to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings/no_course_meetings.json'))
end

def stub_course_meetings_for_duration
  course_offering_id = "10547831"

  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/coursemeetings").
  with(
    headers: {
  'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
    }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings/course_meetings_for_duration.json'))
end

def stub_course_meetings_for_half_hours
  course_offering_id = "10547831"

  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings/#{course_offering_id}/coursemeetings").
  with(
    headers: {
  'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
    }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings/course_meetings_for_half_hours.json'))
end

def stub_course_meetings_nil
  stub_request(:get, "https://turing-validation.populi.co/api2/courseofferings//coursemeetings").
  with(
    headers: {
  'Authorization'=>"Bearer #{ENV["POPULI_API_ACCESS_KEY"]}",
    }).
  to_return(status: 200, body: File.read('spec/fixtures/populi/course_meetings/course_meetings.json'))
end