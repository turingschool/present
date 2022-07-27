require 'rails_helper'

RSpec.describe StudentGroup, type: :model do
  describe 'relationships' do
    it {should belong_to :student}
    it {should belong_to :group}
  end
end
