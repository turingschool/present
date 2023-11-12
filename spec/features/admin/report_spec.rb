require 'rails_helper'

RSpec.describe "Admin Reporting" do
  before :each do
    mock_admin_login
    @student = create(:setup_student, :with_attendances)
  end

  it 'can create a report for a single student' do
    visit admin_path

    click_link "Reports"

    click_link @student.name
    
    fill_in :start_date, with: "2023-11-06"
    fill_in :end_date, with: "2023-11-07"

    click_button "Generate Report"

    expect(find("#report")).to have_table_row("Status" => "present", "Start" => "November 6th, 2023 9:00 AM", "End" => "November 6th, 2023 10:00 AM", "Type" => "Lesson", "Check Method" => "Zoom", "Minutes Active" => 60)
    expect(find("#report")).to have_table_row("Status" => "present", "Start" => "November 6th, 2023 10:00 AM", "End" => "November 6th, 2023 11:00 AM", "Type" => "Lesson", "Check Method" => "Zoom", "Minutes Active" => 60)
    expect(find("#report")).to have_table_row("Status" => "present", "Start" => "November 6th, 2023 11:00 AM", "End" => "November 6th, 2023 12:00 PM", "Type" => "Lesson", "Check Method" => "Zoom", "Minutes Active" => 55)
    
    expect(find("#report")).to have_table_row("Status" => "present", "Start" => "November 6th, 2023 1:00 PM", "End" => "November 6th, 2023 2:00 PM", "Type" => "Lab", "Check Method" => "Slack", "Minutes Active" => 58)
    expect(find("#report")).to have_table_row("Status" => "absent", "Start" => "November 6th, 2023 2:00 PM", "End" => "November 6th, 2023 3:00 PM", "Type" => "Lab", "Check Method" => "Slack", "Minutes Active" => 13)
    expect(find("#report")).to have_table_row("Status" => "absent", "Start" => "November 6th, 2023 3:00 PM", "End" => "November 6th, 2023 4:00 PM", "Type" => "Lab", "Check Method" => "Slack", "Minutes Active" => 0)

    expect(find("#report")).to have_table_row("Status" => "absent", "Start" => "November 7th, 2023 9:00 AM", "End" => "November 7th, 2023 10:00 AM", "Type" => "Lesson", "Check Method" => "Zoom", "Minutes Active" => 0)
    expect(find("#report")).to have_table_row("Status" => "absent", "Start" => "November 7th, 2023 10:00 AM", "End" => "November 7th, 2023 11:00 AM", "Type" => "Lesson", "Check Method" => "Zoom", "Minutes Active" => 15)
    expect(find("#report")).to have_table_row("Status" => "absent", "Start" => "November 7th, 2023 11:00 AM", "End" => "November 7th, 2023 12:00 PM", "Type" => "Lesson", "Check Method" => "Zoom", "Minutes Active" => 15)

    expect(find("#report")).to have_table_row("Status" => "present", "Start" => "November 7th, 2023 1:00 PM", "End" => "November 7th, 2023 2:00 PM", "Type" => "Lab", "Check Method" => "Slack", "Minutes Active" => 60)
    expect(find("#report")).to have_table_row("Status" => "present", "Start" => "November 7th, 2023 2:00 PM", "End" => "November 7th, 2023 3:00 PM", "Type" => "Lab", "Check Method" => "Slack", "Minutes Active" => 60)
    expect(find("#report")).to have_table_row("Status" => "present", "Start" => "November 7th, 2023 3:00 PM", "End" => "November 7th, 2023 4:00 PM", "Type" => "Lab", "Check Method" => "Slack", "Minutes Active" => 60)
  end

  xit 'can show a report for a module' do
    visit admin_path

    within '#available-reports' do
      within '#current-inning-reports' do
        click_link @module.name
      end
    end

    expect(current_path).to eq("admin/module_reports/#{@module.id}")
    expect(find("#report")).to have_table_row("Student" => absent.name, "Status" => 'absent', "Join Time" => "N/A")

  end

  xit 'can show a report for all students in the current inning' do
    visit admin_path

    click_link "Current Inning Report"

    expect(page).to have_content("Report for #{test_inning.name} Inning")

    expect(find("#student-attendances")).to have_table_row("Student" => absent.name, "Status" => 'absent', "Join Time" => "N/A")

  end

  xit 'can download a CSV report for all students in the current inning' do
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