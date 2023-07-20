require 'rails_helper'

RSpec.describe SlackPresenceCheck, type: :model do
  describe 'relationships' do
    it {should belong_to :student}
  end

  describe 'validations' do
    it {should define_enum_for(:presence).with_values([:active, :away])}
    it {should validate_presence_of :check_time}
  end

  it 'has a class method to collect all of itself in order from most recently created to last created' do
    first_check = create(:slack_presence_check)
    second_check = create(:slack_presence_check)
    third_check = create(:slack_presence_check)

    expect(SlackPresenceCheck.collect_for_pagination).to eq([third_check, second_check, first_check])
  end
end
