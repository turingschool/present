require 'rails_helper'

RSpec.describe 'Security' do
  it 'does not allow a visitor to visit any routes under the user namespace' do
    visit '/innings/1'

    expect(page).to have_content('Please Sign In with Google to get started')
    expect(page).to have_link('Sign In With Google')

    visit '/innings'

    expect(page).to have_content('Please Sign In with Google to get started')
    expect(page).to have_link('Sign In With Google')
  end


  it 'does not allow a non-turing user to visit any routes under the user namespace' do
    user = mock_login

    expect(user.organization_domain).to_not eq('turing.edu')

    visit '/innings/1'

    expect(page).to have_content('You are not authorized to view this page')
    expect(page).to have_content('Please sign in with a Google account registered with the Turing Google Workspace')

    visit '/innings'

    expect(page).to have_content('You are not authorized to view this page')
    expect(page).to have_content('Please sign in with a Google account registered with the Turing Google Workspace')
  end
end
