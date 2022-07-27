require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'relationships' do
    it { should belong_to :project }
    it { should have_many :student_groups }
    it { should have_many(:students).through(:student_groups) }
  end
end
