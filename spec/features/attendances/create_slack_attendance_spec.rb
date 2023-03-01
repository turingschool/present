require 'rails_helper'

RSpec.describe 'Creating an Attendance' do
  before(:each) do
    @user = mock_login
  end
  
  context 'with valid slack url' do
    before(:each) do
      @channel_id = "C02HRH7MF5K"
      @timestamp = "1672861516089859"

      stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v0/channel_members?channel_id=#{@channel_id}") \
      .to_return(body: File.read('spec/fixtures/slack/channel_members_report.json'))

      stub_request(:get, "https://slack-attendance-service.herokuapp.com/api/v1/attendance?channel_id=#{@channel_id}&timestamp=#{@timestamp}") \
      .to_return(body: File.read('spec/fixtures/slack/message_replies_response.json'))

      @test_module = create(:setup_module)
      create_list(:student, expected_students.length, turing_module: @test_module )
    end

    it 'creates a new attendance by providing a slack message link' do
      slack_url = "https://turingschool.slack.com/archives/C02HRH7MF5K/p1672861516089859"

      visit turing_module_path(@test_module)
      click_link('Take Attendance')

      expect(current_path).to eq("/modules/#{@test_module.id}/attendances/new")
      expect(page).to have_content(@test_module.name)
      expect(page).to have_content(@test_module.inning.name)
      expect(page).to have_content('Take Attendance for a Slack Thread')

      fill_in :slack_url, with: slack_url
      click_button 'Take Slack Attendance'

      new_attendance = Attendance.last
      expect(current_path).to eq(attendance_path(new_attendance))
      expect(page).to have_content("Slack Thread - #{new_attendance.slack_attendance.pretty_time}")
      # expect(page).to have_content("Slack Message URL - #{slack_url}) future idea to have this on this page
    end

    it 'creates students attendances' do
      slack_url = "https://turingschool.slack.com/archives/C02HRH7MF5K/p1672861516089859"
      
      # binding.pry
      absent_student = @test_module.students.create(zoom_id: "234sdfsdf-A8zjQjKq9mogfJkvvA", name: "AN ABSENT STUDENT", slack_id:"UO2l3kfjsldk3")

      visit turing_module_path(@test_module)
      click_link('Take Attendance')

      fill_in :slack_url, with: slack_url
      click_button 'Take Slack Attendance'

      visit "/attendances/#{Attendance.last.id}"

      expect(Attendance.last.student_attendances.count).to eq(expected_students.length + 1)

      Attendance.last.student_attendances.each do |student_attendance|
        student = student_attendance.student

        expect(find("#student-attendances")).to have_table_row("Student" => student.name, "Status" => student_attendance.status, "Zoom ID" => student.zoom_id, "Slack ID" => student.slack_id)
      end
      expect(find("#student-attendances")).to have_table_row("Student" => absent_student.name, "Status" => 'absent', "Zoom ID" => absent_student.zoom_id, "Slack ID" => absent_student.slack_id)
    end
  end
  
  let(:expected_students){
    [
      Student.new(zoom_id: "VTOR3RckQRSDd5OeKkOfkQ", name: "Meg Stang (she/her)", slack_id: "UBJS832JG"), 
      Student.new(zoom_id: "4zStqvqLStqmuqbAvC03kg", name: "Annie P.", slack_id: "U03MAN29L9W"), 
      Student.new(zoom_id: "CVQTm5CtRKqf05swMFzC8Q", name: "BE Ashley T (she/her)", slack_id: "U03BM5HCCRY"), 
      Student.new(zoom_id: "OUfhKnROQxufMTO8-RAS_Q", name: "James White (He/Him) BE 2208", slack_id: "U03LLTKBYUB"), 
      Student.new(zoom_id: "uZrMY7y1StyThYLy5UXOUA", name: "Kevin T (He/Him)# BE", slack_id: "U02KTLG8WBZ"), 
      Student.new(zoom_id: "xbYVHLWhR_aebK29zlPekw", name: "Madeline Mauser# BE", slack_id: "U0376KHBE78"), 
      Student.new(zoom_id: "yKWJiIdTS7-MP6P2hgVMRQ", name: "Joseph H (He/Him)# BE", slack_id: "U03L266HAUV"), 
      Student.new(zoom_id: "s94_3_CiQr6C1HMPD-r5Ow", name: "Emily P. (she/ her)# BE", slack_id: "U03KYFF1E0N"), 
      Student.new(zoom_id: "1nzD92XMQKSrtdVXoqhEbQ", name: "Naomi Y (she/her)# BE", slack_id: "U03L6BK5PAB"),
      Student.new(zoom_id: "er-o3-QvQgmHofSRBrBAKQ", name: "Amanda R (she/her)# BE",slack_id: "U03LUS2DCRE"),
      Student.new(zoom_id: "LeA0VUwlQam1mWOIAYajMw", name: "Darby S (she/her)# BE",slack_id: "U03L7FKNX0C"),
      Student.new(zoom_id: "O56xuW5YSQiQbvbhKPBNHg", name: "Rich K (he/him)# BE",slack_id: "U03LJ24QEPP"),
      Student.new(zoom_id: "KzAlQssMTR62vR7HmRqlKQ", name: "Yuji K (he/him)# BE",slack_id: "U03LEBHFZBQ"),
      Student.new(zoom_id: "YWhgOE11QWGWOgBIbBS4NA", name: "Sage S (she/her) BE",slack_id: "U02V1UU109Z"),
      Student.new(zoom_id: "ZMu_HIL6Sg6AlbM6XKaQOw", name: "Michael M (he/him) BE",slack_id: "U022NF3D4SV"),
      Student.new(zoom_id: "gKz01c9PQoO2-TfF0Nwqpw", name: "Lucas C. (he/him)# BE",slack_id: "U02SS907SAH"),
      Student.new(zoom_id: "FXLrfOGnTle16PbCxvSUpA", name: "Gabe N (he/him)# BE",slack_id: "U03LPBPDR44"),
      Student.new(zoom_id: "HcYrw04ZQZOU_9Se2eOlkw", name: "Alex M (He#Him) BE",slack_id: "U02ACB9A0B1"),
      Student.new(zoom_id: "HXqZyYDmScO32b0HfdH9-w", name: "Bryan K (he/him)# BE",slack_id: "U03KQFESGAK"),
      Student.new(zoom_id: "F87iJeJ4Rze7-MgJL--f0A", name: "Shawn L (He/Him) BE",slack_id: "U03EMJ8TK8S"),
      Student.new(zoom_id: "J7GkxLUXRCGyDs4xCsoJIw", name: "Kristen Nestler",slack_id: "U03EMGP53EW"),
      Student.new(zoom_id: "zkl1WX2MQ5GXvbGRBy1bDw", name: "Will W (he/him)# BE",slack_id: "U03KQFD5WJK"),
      Student.new(zoom_id: "Azz7feqVS9eDwPZdt7eX7Q", name: "Mostafa S (he/him)# BE",slack_id: "U03L53VSC1Y"),
      Student.new(zoom_id: "LvCxeSlySTqGynb3jCnmlQ", name: "Kenz L (she/her)# BE",slack_id: "U03LLV9J8DQ"),
      Student.new(zoom_id: "_QelgKtURaa3CmVX1pWrqw", name: "Sean Culliton (he/him) 2208 BE",slack_id: "U03LJ24VC0M"),
      Student.new(zoom_id: "Q4QZvdc3QEiV7DMtak47Zg", name: "Astrid H (she/her)# BE",slack_id: "U03E70Z4F39"),
      Student.new(zoom_id: "BeMgdDUNTWqKoXGs1c2-AA", name: "Eli Fuchsman",slack_id: "U03L53W3Q1Y")
    ]
  }

end 