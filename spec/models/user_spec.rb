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
  end
end
