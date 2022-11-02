require 'rails_helper'

RSpec.describe CreateAttendanceFacade do
  let(:roster){
    #Matches students in the participant report spec/fixtures/zoom_meeting_participant_report.json
    [
      Student.new(zoom_id: "E0WPTrXCQAGkMsvF9rQgQA", name: "Ryan Teske (He/Him)"),
      Student.new(zoom_id: "lJjq3OXDSKiG5McSVavgpA", name: "Isika P (she/her# BE)"),
      Student.new(zoom_id: "wkjK882US_Wn6jcDHRKPyA", name: "Natalia ZV (she/her)# FE"),
      Student.new(zoom_id: "Z-b5rLp9QmCAmx1rECjPUA", name: "Jamie P (she/her)# BE"),
      Student.new(zoom_id: "kSW_EwppRtSw98z4sF71gQ", name: "Tanner D (he/him)# BE"),
      Student.new(zoom_id: "o6yw7uMXQYW4CdkoYNTsnA", name: "Kevin (he/him)"),
      Student.new(zoom_id: "u4A9XHYwQxqP7zr_mzla3g", name: "Weston E# (He/Him)# BE"),
      Student.new(zoom_id: "QMqKE40eToSF18y0uHFEWQ", name: "Carlos G { he: him } FE"),
      Student.new(zoom_id: "_Yw6s2HCT0StdKHiOXaXCA", name: "Anna J (she/her)# FE"),
      Student.new(zoom_id: "MUdeK6K_RBOoTu54_xLuNA", name: "Robbie Jaeger (he/him)"),
      Student.new(zoom_id: "NSqExcyyT7-RFwiheD986w", name: "Erin Q (she/her)# BE"),
      Student.new(zoom_id: "ks0Yw-mxR6yeT2Zi6b11Zw", name: "Henry S (he/him)# BE"),
      Student.new(zoom_id: "6KerLiMKTIO9O330dBhceg", name: "Ozzie O (he# him) BE"),
      Student.new(zoom_id: "N80FSgQ4RWebc79dQY0H9g", name: "Nadia N (she/her)"),
      Student.new(zoom_id: "G3C5pxuTQDm3NgKDQ-F4_w", name: "☘️Nolan C."),
      Student.new(zoom_id: "6l6egQjWTgqGzLkNysXciQ", name: "Brian Zanti (he/him)"),
      Student.new(zoom_id: "tuW0wxLdSsSEY8UMxwvZfQ", name: "Eric S (he/him)# FE"),
      Student.new(zoom_id: "VBE5V_n_RXWmOazbAZ-LOQ", name: "Joshua H (he/him)# FE"),
      Student.new(zoom_id: "AXJsN3EqRKamQeQpWjz3kA", name: "Renee S-Z (She/Her)# FE"),
      Student.new(zoom_id: "TNpZEJq2TxKhbqoYl4j01g", name: "Ryan F (he/him)"),
      Student.new(zoom_id: "nh9R9Fe_Qt2u1DwwwiA0Dw", name: "kevinn"),
      Student.new(zoom_id: "KEanb73YQgihvPuS9Tfp1w", name: "Logan V (he/him)"),
      Student.new(zoom_id: "y2sNdVGPSUKa0hG8hOfw0Q", name: "Ezze (He/Him)# BE"),
      Student.new(zoom_id: "w2MBydrFTLaZna8wH3FZiQ", name: "Khoi N (he/him) BE"),
      Student.new(zoom_id: "sTvg885jQfeUPBCiLefv8Q", name: "Travis Rollins (he/him)"),
      Student.new(zoom_id: "yCdFUkVWSZO2KN5rt1_Evw", name: "Dane Brophy (he/they)# BE"),
      Student.new(zoom_id: "I-PHK5qRSD27I5lqPzhGTw", name: "Paul C"),
      Student.new(zoom_id: "dHyEMayjSNGVx1yxNMtiNA", name: "Kelsey T (she/her# BE)"),
      Student.new(zoom_id: "OnceRVu1Qn-4vnyeTqBSHA", name: "Anthony I# FE"),
      Student.new(zoom_id: "ySviBS6iR5qTVwXJ_LDWIg", name: "Nate Sheridan (he/him)"),
      Student.new(zoom_id: "J5g-w7z2SfK6s_qVuz0gdQ", name: "Raquel H (she/her) FE"),
      Student.new(zoom_id: "sA0MNPjDTYKkJ6plhGqH7g", name: "Ida O (she/her)# BE"),
      Student.new(zoom_id: "islYw3qxRGiCg3rhoee2gw", name: "Sami Peterson"),
      Student.new(zoom_id: "GVQVBmKXQTmHwXFg2AvbxA", name: "Jacq W. (they/them)"),
      Student.new(zoom_id: "4gwWaH-CS7i4oUwXymUNdA", name: "Erika K. (she/her) BE"),
      Student.new(zoom_id: "_Or_fpVCTJ2jrcLLAqvZtQ", name: "Jes Jones (she/her) BE"),
      Student.new(zoom_id: "oQH87Yp7T2CP2QvwDFE9yQ", name: "Rowan (they/them)"),
      Student.new(zoom_id: "qixZcwkKR3qLF8eIhJQB6g", name: "Phil T (he/him)# FE"),
      Student.new(zoom_id: "I_HbqYdbR7mTSN98awLUVg", name: "Sarah Rudy (she/her)# FE"),
      Student.new(zoom_id: "fNJX-t1hQgSlQKSSYLGXOA", name: "Bei Z (she/her) FE"),
      Student.new(zoom_id: "8oidz5nrSpqDbMofdV1jkw", name: "Logan V. (he/him) FE"),
      Student.new(zoom_id: "CudREtxyR_e6J0TTPI0pGg", name: "Laura C (she/her)# BE"),
      Student.new(zoom_id: "qhy-A8zjQjKq9mogfJkvvA", name: "Raquel Hill")
    ]
  }

  before(:each) do
    @test_zoom_meeting_id = "95490216907"

    stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
    .to_return(body: File.read('spec/fixtures/zoom_meeting_details.json'))

    stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@test_zoom_meeting_id}/participants?page_size=300") \
    .to_return(body: File.read('spec/fixtures/zoom_meeting_participant_report.json'))

    @zoom_meeting = ZoomMeeting.new(@test_zoom_meeting_id)
    @test_module = create(:turing_module)
    @user = create(:user)
  end

  context 'with students added to the module' do
    before(:each) do
      @test_module.students = roster
    end

    it 'creates a new attendance for the module' do
      new_attendance = CreateAttendanceFacade.take_attendance(@zoom_meeting, @test_module, @user)

      expect(new_attendance).to be_an_instance_of(Attendance)
      expect(new_attendance.zoom_meeting_id).to eq(@test_zoom_meeting_id)
      expect(new_attendance.meeting_title).to eq('Cohort Standup') #from spec/fixtures/zoom_meeting_details.json
      expect(new_attendance.meeting_time).to eq("2021-12-17T16:00:00Z") #from spec/fixtures/zoom_meeting_details.json
      expect(new_attendance).to be_valid
    end

    it 'creates a student attendance for each student in the module' do
      new_attendance = CreateAttendanceFacade.take_attendance(@zoom_meeting, @test_module, @user)
      students_marked = new_attendance.student_attendances.map do |student_attendance|
        student_attendance.student
      end
      expect(students_marked.sort).to eq(roster.sort)
    end
  end

  context 'without students added to the module' do
    it 'makes the call to add students to the module if the option is set to true' do
      expect(@test_module).to receive(:create_students_from_participants).with(@zoom_meeting.participant_report)
      new_attendance = CreateAttendanceFacade.take_attendance(@zoom_meeting, @test_module, @user, true)
    end

    it 'creates students but does not add them to the module if the option is not set to true' do
      expect(Student.count).to eq(0)
      new_attendance = CreateAttendanceFacade.take_attendance(@zoom_meeting, @test_module, @user)
      expect(Student.count).to eq(roster.length)
      expect(@test_module.students.length).to eq(0)
    end
  end
end
