require 'rails_helper'

RSpec.describe "Admin Reporting" do
  before :each do
    mock_admin_login
    @student = create(:setup_student, :with_attendances)

    visit admin_path

    click_link "Reports"

    click_link @student.name
    
    fill_in :start_date, with: "2023-11-06"
    fill_in :end_date, with: "2023-11-07"

    click_button "Generate Report"
  end

  it 'can create a report for a single student' do
    expect(find("#report")).to have_table_row("Status" => "present", "Date" => "11/06/2023", "Start" => "9:00 AM", "End" => "10:00 AM", "Type" => "Lesson", "Check Method" => "Zoom", "Minutes Active" => 60)
    expect(find("#report")).to have_table_row("Status" => "present", "Date" => "11/06/2023", "Start" => "10:00 AM", "End" => "11:00 AM", "Type" => "Lesson", "Check Method" => "Zoom", "Minutes Active" => 60)
    expect(find("#report")).to have_table_row("Status" => "present", "Date" => "11/06/2023", "Start" => "11:00 AM", "End" => "12:00 PM", "Type" => "Lesson", "Check Method" => "Zoom", "Minutes Active" => 55)
    
    expect(find("#report")).to have_table_row("Status" => "present", "Date" => "11/06/2023", "Start" => "1:00 PM", "End" => "2:00 PM", "Type" => "Lab", "Check Method" => "Slack", "Minutes Active" => 58)
    expect(find("#report")).to have_table_row("Status" => "absent", "Date" => "11/06/2023", "Start" => "2:00 PM", "End" => "3:00 PM", "Type" => "Lab", "Check Method" => "Slack", "Minutes Active" => 13)
    expect(find("#report")).to have_table_row("Status" => "absent", "Date" => "11/06/2023", "Start" => "3:00 PM", "End" => "4:00 PM", "Type" => "Lab", "Check Method" => "Slack", "Minutes Active" => 0)

    expect(find("#report")).to have_table_row("Status" => "absent", "Date" => "11/07/2023", "Start" => "9:00 AM", "End" => "10:00 AM", "Type" => "Lesson", "Check Method" => "Zoom", "Minutes Active" => 0)
    expect(find("#report")).to have_table_row("Status" => "absent", "Date" => "11/07/2023", "Start" => "10:00 AM", "End" => "11:00 AM", "Type" => "Lesson", "Check Method" => "Zoom", "Minutes Active" => 15)
    expect(find("#report")).to have_table_row("Status" => "absent", "Date" => "11/07/2023", "Start" => "11:00 AM", "End" => "12:00 PM", "Type" => "Lesson", "Check Method" => "Zoom", "Minutes Active" => 15)

    expect(find("#report")).to have_table_row("Status" => "present", "Date" => "11/07/2023", "Start" => "1:00 PM", "End" => "2:00 PM", "Type" => "Lab", "Check Method" => "Slack", "Minutes Active" => 60)
    expect(find("#report")).to have_table_row("Status" => "present", "Date" => "11/07/2023", "Start" => "2:00 PM", "End" => "3:00 PM", "Type" => "Lab", "Check Method" => "Slack", "Minutes Active" => 60)
    expect(find("#report")).to have_table_row("Status" => "present", "Date" => "11/07/2023", "Start" => "3:00 PM", "End" => "4:00 PM", "Type" => "Lab", "Check Method" => "Slack", "Minutes Active" => 60)
  end

  it 'can download a CSV report a student' do
    click_link "Download as CSV"

    report = CSV.parse(page.body, headers: true)
    
    expect(report.headers).to eq(["Status","Minutes Active","Date","Start","End","Type","Check Method"])
    expect(report.count).to eq(12)

    expect(report[0]["Status"]).to eq("present")
    expect(report[0]["Date"]).to eq("11/07/2023")
    expect(report[0]["Start"]).to eq("3:00 PM")
    expect(report[0]["End"]).to eq("4:00 PM")
    expect(report[0][ "Type"]).to eq("Lab")
    expect(report[0]["Check Method"]).to eq("Slack")
    expect(report[0]["Minutes Active"]).to eq("60")

    expect(report[11]["Status"]).to eq("present")
    expect(report[11]["Date"]).to eq("11/06/2023")
    expect(report[11]["Start"]).to eq("9:00 AM")
    expect(report[11]["End"]).to eq("10:00 AM")
    expect(report[11][ "Type"]).to eq("Lesson")
    expect(report[11]["Check Method"]).to eq("Zoom")
    expect(report[11]["Minutes Active"]).to eq("60")
  end

  it 'shows a summary of the report' do
    expect(page).to have_content("Credit Hours Eligible: 12.0")
    expect(page).to have_content("Credit Hours Earned: 7.0")
    expect(page).to have_content("Lesson Hours Eligible: 6.0")
    expect(page).to have_content("Lesson Hours Earned: 3.0")
    expect(page).to have_content("Lab Hours Eligible: 6.0")
    expect(page).to have_content("Lab Hours Earned: 4.0")
  end
end