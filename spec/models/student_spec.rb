require 'rails_helper'

RSpec.describe Student, type: :model do
  describe 'validations' do
    it {should validate_presence_of :zoom_id}
    it {should validate_uniqueness_of :zoom_id}
    xit {should validate_presence_of :zoom_email}
    xit {should validate_presence_of :name}

  end

  describe 'relationships' do
    it {should belong_to :turing_module}
    it {should have_many :student_attendances}
    it {should have_many(:attendances).through(:student_attendances)}
  end
end
