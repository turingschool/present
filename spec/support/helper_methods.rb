def mock_login
  user = create(:user)
  allow_any_instance_of(ApplicationController).to \
    receive(:current_user).and_return(user)
  return user
end
