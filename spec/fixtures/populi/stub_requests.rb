def stub_call_requests_for_persons
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

def stub_call_requests_for_course_offerings
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

def stub_call_requests_for_academic_terms
  stub_request(:get, "https://turing-validation.populi.co/api2/academicterms").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/get_academic_terms.json'))
end

def stub_call_requests_for_current_academic_term
  stub_request(:get, "https://turing-validation.populi.co/api2/academicterms/current").
    with(
      headers: {
    'Authorization'=>"Bearer #{ENV["POPULI_API2_ACCESS_KEY"]}",
      }).
    to_return(status: 200, body: File.read('spec/fixtures/populi/current_academic_term.json')) 
end

def stub_call_requests_for_course_offerings_by_term
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
