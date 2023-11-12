require 'rails_helper'

RSpec.describe StudentAttendanceHour do
  describe 'relationships' do
    it {should belong_to :student_attendance}
    it {should have_one(:attendance).through(:student_attendance)}
  end

  it {should define_enum_for(:status).with_values([:present, :absent])}
end