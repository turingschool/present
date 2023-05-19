require 'rails_helper'

RSpec.describe 'Presence Monitoring Index' do
  include ApplicationHelper
  before :each do
    mock_admin_login
  end
  
  it 'shows the slack presence check time, the student, and their presence' do
    checks = create_list(:slack_presence_check, 5)

    visit '/admin/slack_presence_checks'

    checks.each do |check|
      expect(page).to have_content(pretty_date(check.check_time))
      expect(page).to have_content(pretty_time(check.check_time))
      expect(page).to have_content(check.student.name)
      expect(page).to have_content(check.student.slack_id)
      expect(page).to have_content(check.presence)
    end
  end
end