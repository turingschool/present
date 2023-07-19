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

  describe 'pagination' do
    before(:each) do
      @checks_one = create_list(:slack_presence_check, 49)
      @first_page_last = create(:slack_presence_check)
      @second_page_first = create(:slack_presence_check)
      @checks_two = create_list(:slack_presence_check, 48)
      @second_page_last = create(:slack_presence_check)
      @third_page_first = create(:slack_presence_check)
    end

    it 'displays the slack presence checks in a paginated manner, with only 50 per page' do
      visit '/admin/slack_presence_checks'

      expect(page).to have_content(@first_page_last.student.name)
      expect(page).to have_content(@first_page_last.student.slack_id)
      expect(page).to_not have_content(@second_page_first.student.name)
      expect(page).to_not have_content(@second_page_first.student.slack_id)
      expect(page).to_not have_content(@second_page_last.student.name)
      expect(page).to_not have_content(@second_page_last.student.slack_id)
      expect(page).to_not have_content(@third_page_first.student.name)
      expect(page).to_not have_content(@third_page_first.student.slack_id)
    end

    it 'has navigation buttons that move between the pages' do
      visit '/admin/slack_presence_checks'

      expect(page).to have_link('Next', href: '/admin/slack_presence_checks/page/2')
      expect(page).to have_link('2', href: '/admin/slack_presence_checks/page/2')
      expect(page).to have_link('3', href: '/admin/slack_presence_checks/page/3')
      expect(page).to have_link('Last', href: '/admin/slack_presence_checks/page/3')
      click_link('Next')
      expect(current_path).to eq('/admin/slack_presence_checks/page/2')
    end
  end


end