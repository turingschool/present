require 'rails_helper'

RSpec.describe StudentAttendance, type: :model do
  describe 'relationships' do
    it {should belong_to :student}
    it {should belong_to :attendance}
  end

  it {should define_enum_for(:status).with_values(present: 0, tardy: 1, absent: 2)}
end
