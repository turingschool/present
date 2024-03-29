def mock_login
  user = create(:user, organization_domain: 'turing.edu')
  allow_any_instance_of(ApplicationController).to \
    receive(:current_user).and_return(user)
  return user
end

def mock_admin_login
  user = create(:admin)
  allow_any_instance_of(ApplicationController).to \
    receive(:current_user).and_return(user)
  return user
end
