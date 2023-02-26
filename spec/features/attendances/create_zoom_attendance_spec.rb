require 'rails_helper'

RSpec.describe 'Creating an Attendance' do
  before(:each) do
    @user = mock_login
  end

  it 'links back to module and inning' do
    mod = create(:turing_module)
    inning = mod.inning
    visit new_turing_module_attendance_path(mod)
    expect(page).to have_link(mod.name, href: turing_module_path(mod))
    expect(page).to have_link(inning.name, href: inning_path(inning))
  end

  context 'with valid meeting ids' do
    before(:each) do
      @test_zoom_meeting_id = 95490216907

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom_meeting_participant_report.json'))

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom_meeting_details.json'))

      @test_module = create(:turing_module)
    end

    it 'creates a new attendance by filling in a past zoom meeting' do
      @test_module = create(:turing_module)
      create_list(:student, expected_students.length, turing_module: @test_module )
      
      visit turing_module_path(@test_module)
      click_link('Take Attendance')

      expect(current_path).to eq("/modules/#{@test_module.id}/attendances/new")
      expect(page).to have_content(@test_module.name)
      expect(page).to have_content(@test_module.inning.name)
      expect(page).to have_content('Take Attendance for a Zoom Meeting')
      fill_in :attendance_zoom_meeting_id, with: @test_zoom_meeting_id
      click_button 'Take Zoom Attendance'

      new_attendance = Attendance.last
      expect(current_path).to eq(attendance_path(new_attendance))
      expect(page).to have_content(@test_zoom_meeting_id)
    end

    xit 'can populate the module with students from the Zoom meeting' do
      test_module = create(:turing_module)
      @test_zoom_meeting_id = 95490216907

      visit turing_module_path(test_module)
      expect(page).to have_link('Students (0)')
      click_link('Take Attendance')

      check(:attendance_populate_students)
      fill_in :attendance_zoom_meeting_id, with: @test_zoom_meeting_id
      click_button 'Take Zoom Attendance'

      visit turing_module_path(test_module)
      click_link("Students (#{expected_students.length})")

      expect(page).to have_css('.student', count: expected_students.length)
      expected_students.each do |student|
        expect(page).to have_content(student.name)
        expect(page).to have_content(student.zoom_id)
      end
    end

    xit 'can prompt user to add a new user if zoom attendee is not in student list' do
      new_student = expected_students.pop
      @test_module.students = expected_students
      
      visit turing_module_path(@test_module)
      click_link('Take Attendance')

      fill_in :attendance_zoom_meeting_id, with: @test_zoom_meeting_id
      click_button 'Take Zoom Attendance'

      visit "/attendances/#{Attendance.last.id}"

      expect(@test_module.students.count).to eq(42)
      expect(page).to have_button("Add New Student")

      click_button "Add New Student"

      expect(current_path).to eq(attendance_path(Attendance.last))

      expect(@test_module.students.count).to eq(43)
      expect(@test_module.students.exists?(name: new_student.name)).to be(true)

      visit turing_module_students_path(@test_module)

      expect(page).to have_link(new_student.name)

      visit "/attendances/#{Attendance.last.id}"

      expect(page).to_not have_button("Add New Student")
    end

    it 'can add students to the module even if they are associated with another module' do
      new_student = expected_students.pop
      other_mod = create(:turing_module)
      new_student.update(turing_module: other_mod)
      @test_module.students = expected_students

      visit turing_module_path(@test_module)
      click_link('Take Attendance')
      fill_in :attendance_zoom_meeting_id, with: @test_zoom_meeting_id
      click_button 'Take Zoom Attendance'

      visit "/attendances/#{Attendance.last.id}"

      expect(@test_module.students.count).to eq(42)
      expect(page).to have_button("Add New Student")

      click_button "Add New Student"

      visit turing_module_students_path(@test_module)

      expect(page).to have_link(new_student.name)

      visit turing_module_students_path(other_mod)

      expect(page).to_not have_link(new_student.name)
    end

    it 'creates students attendances' do
      @test_module.students = expected_students
      absent_student = @test_module.students.create(zoom_id: "234sdfsdf-A8zjQjKq9mogfJkvvA", name: "AN ABSENT STUDENT")
      @test_zoom_meeting_id = 95490216907

      stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
      .to_return(body: File.read('spec/fixtures/zoom_meeting_participant_report.json'))

      stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
      .to_return(body: File.read('spec/fixtures/zoom_meeting_details.json'))

      visit turing_module_path(@test_module)
      click_link('Take Attendance')

      fill_in :attendance_zoom_meeting_id, with: @test_zoom_meeting_id
      click_button 'Take Zoom Attendance'

      visit "/attendances/#{Attendance.last.id}"

      expect(Attendance.last.student_attendances.count).to eq(expected_students.length + 1)

      Attendance.last.student_attendances.each do |student_attendance|
        student = student_attendance.student
        expect(find("#student-attendances")).to have_table_row("Student" => student.name, "Status" => student_attendance.status, "Zoom ID" => student.zoom_id)
      end
      expect(find("#student-attendances")).to have_table_row("Student" => absent_student.name, "Status" => 'absent', "Zoom ID" => absent_student.zoom_id)
    end

    it 'shows a message if an invalid meeting id is entered' do
      invalid_zoom_id = 'InvalidID'
      stub_request(:get, "https://api.zoom.us/v2/meetings/#{invalid_zoom_id}") \
      .to_return(body: File.read('spec/fixtures/zoom_meeting_details_invalid.json'))

      test_module = create(:turing_module)
      visit new_turing_module_attendance_path(test_module)

      fill_in :attendance_zoom_meeting_id, with: invalid_zoom_id
      click_button 'Take Zoom Attendance'

      expect(current_path).to eq(new_turing_module_attendance_path(test_module))
      expect(page).to have_content("It appears you have entered an invalid Zoom Meeting ID. Please double check the Meeting ID and try again.")
    end
  end

  let(:expected_students){
    [
      Student.new(zoom_id: "E0WPTrXCQAGkMsvF9rQgQA", name: "Ryan Teske (He/Him)", slack_id: "E0WPTrXCQAGkMsvF9rQgQA"),
      Student.new(zoom_id: "lJjq3OXDSKiG5McSVavgpA", name: "Isika P (she/her# BE)", slack_id: "lJjq3OXDSKiG5McSVavgpA"),
      Student.new(zoom_id: "wkjK882US_Wn6jcDHRKPyA", name: "Natalia ZV (she/her)# FE", slack_id: "wkjK882US_Wn6jcDHRKPyA"),
      Student.new(zoom_id: "Z-b5rLp9QmCAmx1rECjPUA", name: "Jamie P (she/her)# BE", slack_id: "fasdfasdfZ"),
      Student.new(zoom_id: "kSW_EwppRtSw98z4sF71gQ", name: "Tanner D (he/him)# BE", slack_id: "kSW_EwppRtSw98z4sF71gQ"),
      Student.new(zoom_id: "o6yw7uMXQYW4CdkoYNTsnA", name: "Kevin (he/him)", slack_id: "o6yw7uMXQYW4CdkoYNTsnA"),
      Student.new(zoom_id: "u4A9XHYwQxqP7zr_mzla3g", name: "Weston E# (He/Him)# BE", slack_id: "u4A9XHYwQxqP7zr_mzla3g"),
      Student.new(zoom_id: "QMqKE40eToSF18y0uHFEWQ", name: "Carlos G { he: him } FE", slack_id: "QMqKE40eToSF18y0uHFEWQ"),
      Student.new(zoom_id: "_Yw6s2HCT0StdKHiOXaXCA", name: "Anna J (she/her)# FE", slack_id: "_Yw6s2HCT0StdKHiOXaXCA"),
      Student.new(zoom_id: "MUdeK6K_RBOoTu54_xLuNA", name: "Robbie Jaeger (he/him)", slack_id: "MUdeK6K_RBOoTu54_xLuNA"),
      Student.new(zoom_id: "NSqExcyyT7-RFwiheD986w", name: "Erin Q (she/her)# BE", slack_id: "NSqExcyyT7"),
      Student.new(zoom_id: "ks0Yw-mxR6yeT2Zi6b11Zw", name: "Henry S (he/him)# BE", slack_id: "ks0Yw"),
      Student.new(zoom_id: "6KerLiMKTIO9O330dBhceg", name: "Ozzie O (he# him) BE", slack_id: "6KerLiMKTIO9O330dBhceg"),
      Student.new(zoom_id: "N80FSgQ4RWebc79dQY0H9g", name: "Nadia N (she/her)", slack_id: "N80FSgQ4RWebc79dQY0H9g"),
      Student.new(zoom_id: "G3C5pxuTQDm3NgKDQ-F4_w", name: "☘️Nolan C.", slack_id: "G3C5pxuTQDm3NgKDQ"),
      Student.new(zoom_id: "6l6egQjWTgqGzLkNysXciQ", name: "Brian Zanti (he/him)", slack_id: "6l6egQjWTgqGzLkNysXciQ"),
      Student.new(zoom_id: "tuW0wxLdSsSEY8UMxwvZfQ", name: "Eric S (he/him)# FE", slack_id: "tuW0wxLdSsSEY8UMxwvZfQ"),
      Student.new(zoom_id: "VBE5V_n_RXWmOazbAZ-LOQ", name: "Joshua H (he/him)# FE", slack_id: "VBE5V_n_RXWmOazbAZ"),
      Student.new(zoom_id: "AXJsN3EqRKamQeQpWjz3kA", name: "Renee S-Z (She/Her)# FE", slack_id: "AXJsN3EqRKamQeQpWjz3kA"),
      Student.new(zoom_id: "TNpZEJq2TxKhbqoYl4j01g", name: "Ryan F (he/him)", slack_id: "TNpZEJq2TxKhbqoYl4j01g"),
      Student.new(zoom_id: "nh9R9Fe_Qt2u1DwwwiA0Dw", name: "kevinn", slack_id: "nh9R9Fe_Qt2u1DwwwiA0Dw"),
      Student.new(zoom_id: "KEanb73YQgihvPuS9Tfp1w", name: "Logan V (he/him)", slack_id: "KEanb73YQgihvPuS9Tfp1w"),
      Student.new(zoom_id: "y2sNdVGPSUKa0hG8hOfw0Q", name: "Ezze (He/Him)# BE", slack_id: "y2sNdVGPSUKa0hG8hOfw0Q"),
      Student.new(zoom_id: "w2MBydrFTLaZna8wH3FZiQ", name: "Khoi N (he/him) BE", slack_id: "w2MBydrFTLaZna8wH3FZiQ"),
      Student.new(zoom_id: "sTvg885jQfeUPBCiLefv8Q", name: "Travis Rollins (he/him)", slack_id: "sTvg885jQfeUPBCiLefv8Q"),
      Student.new(zoom_id: "yCdFUkVWSZO2KN5rt1_Evw", name: "Dane Brophy (he/they)# BE", slack_id: "yCdFUkVWSZO2KN5rt1_Evw"),
      Student.new(zoom_id: "I-PHK5qRSD27I5lqPzhGTw", name: "Paul C", slack_id: "Isdfsfsasdfasdfasdf"),
      Student.new(zoom_id: "dHyEMayjSNGVx1yxNMtiNA", name: "Kelsey T (she/her# BE)", slack_id: "dHyEMayjSNGVx1yxNMtiNA"),
      Student.new(zoom_id: "OnceRVu1Qn-4vnyeTqBSHA", name: "Anthony I# FE", slack_id: "OnceRVu1Qasdfadsfn"),
      Student.new(zoom_id: "ySviBS6iR5qTVwXJ_LDWIg", name: "Nate Sheridan (he/him)", slack_id: "ySviBS6iR5qTVwXJ_LDWIg"),
      Student.new(zoom_id: "J5g-w7z2SfK6s_qVuz0gdQ", name: "Raquel H (she/her) FE", slack_id: "J5asdfasdfasdfg"),
      Student.new(zoom_id: "sA0MNPjDTYKkJ6plhGqH7g", name: "Ida O (she/her)# BE", slack_id: "sA0MNPjDTYKkJ6plhGqH7g"),
      Student.new(zoom_id: "islYw3qxRGiCg3rhoee2gw", name: "Sami Peterson", slack_id: "islYw3qxRGiCg3rhoee2gw"),
      Student.new(zoom_id: "GVQVBmKXQTmHwXFg2AvbxA", name: "Jacq W. (they/them)", slack_id: "GVQVBmKXQTmHwXFg2AvbxA"),
      Student.new(zoom_id: "4gwWaH-CS7i4oUwXymUNdA", name: "Erika K. (she/her) BE", slack_id: "4gwWaasdfasdfH"),
      Student.new(zoom_id: "_Or_fpVCTJ2jrcLLAqvZtQ", name: "Jes Jones (she/her) BE", slack_id: "_Or_fpVCTJ2jrcLLAqvZtQ"),
      Student.new(zoom_id: "oQH87Yp7T2CP2QvwDFE9yQ", name: "Rowan (they/them)", slack_id: "oQH87Yp7T2CP2QvwDFE9yQ"),
      Student.new(zoom_id: "qixZcwkKR3qLF8eIhJQB6g", name: "Phil T (he/him)# FE", slack_id: "qixZcwkKR3qLF8eIhJQB6g"),
      Student.new(zoom_id: "I_HbqYdbR7mTSN98awLUVg", name: "Sarah Rudy (she/her)# FE", slack_id: "I_HbqYdbR7mTSN98awLUVg"),
      Student.new(zoom_id: "fNJX-t1hQgSlQKSSYLGXOA", name: "Bei Z (she/her) FE", slack_id: "fNJasdfadsfasdfX"),
      Student.new(zoom_id: "8oidz5nrSpqDbMofdV1jkw", name: "Logan V. (he/him) FE", slack_id: "8oidz5nrSpqDbMofdV1jkw"),
      Student.new(zoom_id: "CudREtxyR_e6J0TTPI0pGg", name: "Laura C (she/her)# BE", slack_id: "CudREtxyR_e6J0TTPI0pGg"),
      Student.new(zoom_id: "qhy-A8zjQjKq9mogfJkvvA", name: "Raquel Hill", slack_id: "qhfdasdfasdfy")
    ]
  }
end
