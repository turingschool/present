require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it {should validate_presence_of :email}
    it {should validate_presence_of :google_oauth_token}
    it {should validate_presence_of :google_id}
    it {should belong_to(:turing_module).optional}
    it {should define_enum_for(:user_type).with_values([:default, :admin])}
    it 'is not an admin by default' do
      user = create(:user)
      expect(user.admin?).to eq(false)
    end
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

    describe 'is_this_my_mod?' do
      it 'returns true if the mod is the users mod' do
        user = create(:user)
        mod = create(:turing_module)
        user.turing_module = mod
        expect(user.is_this_my_mod?(mod)).to eq(true)
      end

      it 'returns false if user has no My Module' do
        user = create(:user)
        mod = create(:turing_module)
        expect(user.is_this_my_mod?(mod)).to eq(false)
      end

      it 'returns false if user has a different My Module' do
        user = create(:user)
        mymod = create(:turing_module)
        diffmod = create(:turing_module)
        user.turing_module = mymod
        expect(user.is_this_my_mod?(diffmod)).to eq(false)
      end
    end
  end

  describe 'class methods' do
    it 'reset_modules' do
      inning = Inning.create(name: '2108', start_date: Date.today)
      inning.create_turing_modules
      user1 = create(:user, turing_module: inning.turing_modules.first)
      user2 = create(:user, turing_module: inning.turing_modules.second)
      user3 = create(:user, turing_module: inning.turing_modules.third)
      
      expect(user1.turing_module_id).to_not eq(nil)
      expect(user2.turing_module_id).to_not eq(nil)
      expect(user3.turing_module_id).to_not eq(nil)

      User.reset_modules
      
      expect(user1.reload.turing_module_id).to eq(nil)
      expect(user2.reload.turing_module_id).to eq(nil)
      expect(user3.reload.turing_module_id).to eq(nil)
    end
  end
end
