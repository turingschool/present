require 'rails_helper'

RSpec.describe "Admin Reporting" do
  before :each do
    mock_admin_login
    @module = create(:setup_module_with_presence_checks)
    @other_module = create(:turing_module)
    student1, student2, student3 = create_list(:student, 3, turing_module: @other_module)
    create(:slack_presence_check, student: student1, check_time: Time.now - 5.minutes, status: :active)
  end

  it 'can show a report for a module' do
    # Every day,
    # For each slack attendance taken yesterday
      # For each 15 minute time period
        # For each student
          # Find all slack presence checks with an "active" status for that student where the check time is between the start and end of that fifteen minute period
          # If there were any returned add 15 minutes to the student attendance duration

    # For a module
    # 1. Get all of the module's attendances
    # 2. Iterate through the module's attendances
      # If the attendance is Slack, build the Slack presence check report for that meeting

    # Get Course meetings for the module
    # For each course meeting
      # If the meeting counts towards clinical hours
        

    visit admin_path

    within '#available-reports' do
      within '#current-inning-reports' do
        click_link @module.name
      end
    end

    expect(current_path).to eq("admin/module_reports/#{@module.id}")
    expect(find("#report")).to have_table_row("Student" => absent.name, "Status" => 'absent', "Join Time" => "N/A")

  end

  it 'can show a report for all students in the current inning' do
    visit admin_path

    click_link "Current Inning Report"

    expect(page).to have_content("Report for #{test_inning.name} Inning")

    expect(find("#student-attendances")).to have_table_row("Student" => absent.name, "Status" => 'absent', "Join Time" => "N/A")

  end

  it 'can download a CSV report for all students in the current inning' do
    visit admin_path
    within '#available-reports' do
      within '#current-inning-report' do
        click_button 'Generate Report'
      end
    end

    report = CSV.parse(page.body, headers: true)
    expect(report.headers).to eq([])
    expect(report.count).to eq(0)
  end
end