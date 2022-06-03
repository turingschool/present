require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it {should validate_presence_of :email}
    it {should validate_presence_of :google_oauth_token}
    it {should validate_presence_of :google_id}
    it {should belong_to(:turing_module).optional}
  end

  describe 'instance methods' do
    describe 'my_module' do
      it 'returns the users module' do
        mod = create(:turing_module)
        user = create(:user, turing_module: mod)
        expect(user.my_module).to eq(mod)
      end

      it 'returns nil if the user has no module' do
        user = create(:user)
        expect(user.my_module).to eq(nil)
      end
    end

    describe 'valid_google_user?' do
      it 'returns true if the the users org is turing' do
        user = create(:user, organization_domain: 'turing.edu')
        expect(user.valid_google_user?).to eq(true)
      end

      it 'returns false if the users org is not turing' do
        user = create(:user, organization_domain: 'notturing.edu')
        expect(user.valid_google_user?).to eq(false)
      end

      it 'return false if the user has no org' do
        user = create(:user)
        expect(user.valid_google_user?).to eq(false)
      end
    end
  end
end
