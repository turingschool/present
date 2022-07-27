require 'rails_helper'

RSpec.describe StudentPair, type: :model do
  describe 'relationships' do
    it {should belong_to :student}
    it {should belong_to :project}
  end
end
