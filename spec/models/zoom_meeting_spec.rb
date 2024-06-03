require 'rails_helper'

RSpec.describe ZoomMeeting do
  describe 'relationships' do
    it {should have_many(:zoom_aliases).dependent(:destroy)}
    it {should have_one :attendance}
    it {should have_one(:turing_module).through(:attendance)}
  end

  describe 'validations' do
    it {should validate_uniqueness_of(:meeting_id)}
  end

  describe "instance methods" do
    describe "#take_participant_attendance" do
      before :each do
        @user = mock_login
        @turing_module = create(:turing_module)
        allow(ZoomService).to receive(:access_token)
        allow(ZoomService).to receive(:meeting_details)
        @meeting_id = "96851574864"
        @zoom_meeting = ZoomMeeting.new(meeting_id: @meeting_id)
        start_time = "2024-05-29T15:00:00Z".to_datetime
        attributes = {
          start_time: start_time, 
          end_time: start_time + 120.minutes, 
          title: "- Modules ",
          duration: (120)
        }
        @zoom_meeting.update(attributes)
        @zoom_meeting.turing_module = @turing_module
        @attendance = Attendance.create(attendance_time: start_time, end_time: start_time + 120.minutes, meeting: @zoom_meeting, turing_module: @turing_module, user: @user)
        @zoom_meeting.attendance = @attendance
        stub_request(:get, "https://api.zoom.us/v2/report/meetings/#{@meeting_id}/participants?page_size=300") \
          .to_return(body: File.read('spec/fixtures/zoom/participant_report_for_student_present_less_than_thirty.json'))
      end
        
      context 'when a student misses more than 30 minutes of a class' do
        it 'records the student as absent' do
          student_1 = Student.create(name: "Sid Swaminathan", turing_module: @turing_module) # This student was in class less than 30 minutes
          student_2 = Student.create(name: "Lito Croy", turing_module: @turing_module)
          student_3 = Student.create(name: "Karl Fallenius", turing_module: @turing_module)
          student_4 = Student.create(name: "Cameron Pittman", turing_module: @turing_module)
          student_5 = Student.create(name: "Tyler Noble", turing_module: @turing_module)
          
          @report = ZoomService.participant_report(@meeting_id)[:participants]
          
          aliases = @report.map do |participant|
            {
              name: participant[:name], 
              zoom_meeting_id: @zoom_meeting.id, 
              turing_module_id: @turing_module.id
            }
          end
          ZoomAlias.insert_all(aliases, unique_by: [:name, :turing_module_id])

          ZoomAlias.find_by(name: "sid swaminathan").update(student: student_1)
          ZoomAlias.find_by(name: "Lito Croy (he/him) BE").update(student: student_2)
          ZoomAlias.find_by(name: "Karl F (He/Him), BE").update(student: student_3)
          ZoomAlias.find_by(name: "Cameron P BE").update(student: student_4)
          ZoomAlias.find_by(name: "Tyler Noble").update(student: student_5)

          grouped_participants = @report.map do |participant| 
            ZoomParticipant.new(participant, @attendance.attendance_time, @attendance.end_time)
          end.group_by(&:name)

          @turing_module.students.each do |student|
            matching_participants = student.zoom_aliases.pluck(:name).flat_map do |zoom_name|
              grouped_participants[zoom_name]
            end.compact
          
            total_duration = ((matching_participants.sum(&:duration).to_f) / 60 ).round
            @zoom_meeting.record_student_attendance(student, matching_participants, total_duration)
          end

          expect(student_1.student_attendances[0].status).to eq("absent")
          expect(student_2.student_attendances[0].status).to eq("present")
          expect(student_3.student_attendances[0].status).to eq("present")
          expect(student_4.student_attendances[0].status).to eq("tardy")
          expect(student_5.student_attendances[0].status).to eq("present")
        end
      end
    end
  end

  describe 'class methods' do
    describe '.from_meeting_details' do
      before :each do 
        @test_zoom_meeting_id = "95490216907"
        allow(ZoomService).to receive(:access_token) # Do nothing when fetching Zoom access token
        stub_request(:get, "https://api.zoom.us/v2/meetings/#{@test_zoom_meeting_id}") \
          .to_return(body: File.read('spec/fixtures/zoom/meeting_details.json'))
      end

      it "creates the zoom meeting" do
        zoom = ZoomMeeting.from_meeting_details(@test_zoom_meeting_id)
        expect(zoom.meeting_id).to eq(@test_zoom_meeting_id)
        expect(zoom.start_time).to eq(DateTime.parse("Tue, 10 Jan 2023 15:45:22 UTC +00:00"))
        expect(zoom.end_time).to eq(DateTime.parse("Tue, 10 Jan 2023 17:00:22 UTC +00:00"))
        expect(zoom.title).to eq("ReadMe Workshop")
        expect(zoom.duration).to eq(75)
      end

      it "does not duplicate meeting records with the same meeting id" do
        ZoomMeeting.from_meeting_details(@test_zoom_meeting_id)
        ZoomMeeting.from_meeting_details(@test_zoom_meeting_id)
        expect(ZoomMeeting.count).to eq(1)
      end

      it 'will update existing records if any non unique fields changed' do
        zoom = ZoomMeeting.from_meeting_details(@test_zoom_meeting_id)
        zoom.update!(title: "Fake Title", start_time: Time.now, end_time: Time.now, duration: 0)

        zoom = ZoomMeeting.from_meeting_details(@test_zoom_meeting_id)
        expect(zoom.meeting_id).to eq(@test_zoom_meeting_id)
        expect(zoom.start_time).to eq(DateTime.parse("Tue, 10 Jan 2023 15:45:22 UTC +00:00"))
        expect(zoom.end_time).to eq(DateTime.parse("Tue, 10 Jan 2023 17:00:22 UTC +00:00"))
        expect(zoom.title).to eq("ReadMe Workshop")
        expect(zoom.duration).to eq(75)
        expect(ZoomMeeting.count).to eq(1)
      end      
    end
  end
end