require 'rails_helper'

RSpec.describe SlackPresenceCheck, type: :model do
  describe 'relationships' do
    it {should belong_to :student}
  end

  describe 'validations' do
    it {should define_enum_for(:presence).with_values([:active, :away])}
  end
end
