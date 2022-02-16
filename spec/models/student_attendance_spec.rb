require 'rails_helper'

RSpec.describe StudentAttendance, type: :model do
  describe 'relationships' do
    it {should belong_to :student}
    it {should belong_to :attendance}
  end
end
