require 'rails_helper'

RSpec.describe Pair, type: :model do
  describe 'validations' do
    it {should validate_presence_of :name}
    it {should validate_presence_of :size}
  end

  describe 'relationships' do
    it {should have_many :student_pairs}
    it {should have_many(:students).through(:student_pairs)}
  end
end
