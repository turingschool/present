require 'rails_helper'

RSpec.describe 'delete zoom attendance' do
  include ApplicationHelper

  before :each do
    @user = mock_login
    @module = create(:turing_module)
    @test_attendance = create(:attendance_with_student_attendances, turing_module: @module)
    visit "/attendances/#{@test_attendance.id}"
  end

  it "deletes student attendance" do
    expect(@module.attendances.count).to eq(1)

    click_link "Delete Attendance"

    expect(current_path).to eq(turing_module_path(@module))
    expect(page).to have_content("Attendance successfully deleted.")
    expect(@module.attendances.count).to eq(0)
  end

  it "keeps a log of deleted attendance" do    
    attendance_details = {
      id: @test_attendance.id,
      turing_module_id: @test_attendance.turing_module_id,
      user_id: @test_attendance.user_id,
      meeting_type: @test_attendance.meeting_type,
      meeting_id: @test_attendance.meeting_id,
      end_time: @test_attendance.end_time
    }

    #allows for the logger to listen to the info method for desired output
    allow(Rails.logger).to receive(:info)

    expect(Rails.logger).to receive(:info).with("Attendance #{@test_attendance.id} deleted by user #{@user.email}. Deleted Attendance Details: #{attendance_details.inspect}")
    
    click_link "Delete Attendance"
  end
end