require 'rails_helper'

RSpec.describe 'Security' do
  before :each do
    create(:inning)
  end
  
  it 'does not allow a visitor to visit any routes under the user namespace' do
    visit '/innings/1'

    expect(page).to have_content('Please Sign In with Google to get started')
    expect(page).to have_link('Sign In With Google')

    visit '/modules/1'

    expect(page).to have_content('Please Sign In with Google to get started')
    expect(page).to have_link('Sign In With Google')
  end

  it 'does not allow a non-turing user to visit any routes under the user namespace' do
    user = mock_login
    user.update(organization_domain: 'notturing.edu')

    visit '/innings/1'

    expect(page).to have_content('You are not authorized to view this page')
    expect(page).to have_content('Please sign in with a Google account registered with the Turing Google Workspace')

    visit '/modules/1'

    expect(page).to have_content('You are not authorized to view this page')
    expect(page).to have_content('Please sign in with a Google account registered with the Turing Google Workspace')
  end

  it 'does not allow a visitor to view the sidekiq dashboard' do
    expect{ visit '/sidekiq' }.to raise_error(ActionController::RoutingError)
  end

  it 'does not allow a non-turing user to view the sidekiq dashboard' do
    user = mock_login
    expect{ visit '/sidekiq' }.to raise_error(ActionController::RoutingError)
  end

  describe 'Admin Views' do
    describe '/admin' do
      it 'does not allow a visitor to access admin views' do
        visit '/admin'
  
        expect(page).to have_content('Please Sign In with Google to get started')
        expect(page).to have_link('Sign In With Google')
      end
  
      it 'does not allow a non turing user to access admin views' do
        user = mock_login
        user.update(organization_domain: 'notturing.edu')
  
        visit '/admin'
  
        expect(page).to have_content('You are not authorized to view this page')
        expect(page).to have_content('Please sign in with a Google account registered with the Turing Google Workspace')
      end
  
      it 'does not allow a turing default user to access admin views' do
        user = mock_login
  
        visit '/admin'
  
        expect(page).to have_content('You are not authorized to view this page')
        expect(page).to have_content('Please sign in with a Google account registered with the Turing Google Workspace')
      end
  
      it 'allows a turing admin to access admin views' do
        user = mock_admin_login
  
        visit '/admin'
  
        expect(page).to_not have_content('You are not authorized to view this page')
        expect(page).to_not have_content('Please Sign In with Google to get started')
      end
    end
    
    describe '/admin/slack_presence_checks' do
      it 'does not allow a visitor to access admin views' do
        visit '/admin/slack_presence_checks'
  
        expect(page).to have_content('Please Sign In with Google to get started')
        expect(page).to have_link('Sign In With Google')
      end
  
      it 'does not allow a non turing user to access admin views' do
        user = mock_login
        user.update(organization_domain: 'notturing.edu')
  
        visit '/admin/slack_presence_checks'
  
        expect(page).to have_content('You are not authorized to view this page')
        expect(page).to have_content('Please sign in with a Google account registered with the Turing Google Workspace')
      end
  
      it 'does not allow a turing default user to access admin views' do
        user = mock_login
  
        visit '/admin/slack_presence_checks'
  
        expect(page).to have_content('You are not authorized to view this page')
        expect(page).to have_content('Please sign in with a Google account registered with the Turing Google Workspace')
      end
  
      it 'allows a turing admin to access admin views' do
        user = mock_admin_login
  
        visit '/admin/slack_presence_checks'
  
        expect(page).to_not have_content('You are not authorized to view this page')
        expect(page).to_not have_content('Please Sign In with Google to get started')
      end
    end
  end
end
