require 'rails_helper'

RSpec.describe 'delete zoom attendance' do
  include ApplicationHelper

  before :each do
    @user = mock_login
    @module = create(:turing_module)
    @test_attendance = create(:zoom_attendance, turing_module: @module)
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
    #allows for the logger to listen to the info method for desired output
    allow(Rails.logger).to receive(:info)

    expect(Rails.logger).to receive(:info).with("Attendance #{@test_attendance.id} deleted by user #{@user.email}. Deleted Attendance Details: #{@test_attendance.attributes.inspect}")
    
    click_link "Delete Attendance"
  end
end