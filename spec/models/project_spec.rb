require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'validations' do
    it {should validate_presence_of :name}
    it {should validate_presence_of :size}
  end

  describe 'relationships' do
    it {should have_many :groups}
  end

  describe 'instance methods' do
    xdescribe '#generate_student_pairings' do
      let(:turing_module) { create(:turing_module) }
      let(:students) { create_list(:student, 12, turing_module: turing_module) }
      let(:project) { create(:project, size: 3) }
      let(:subject) { project.generate_student_pairings(students) }

      it 'creates_pairs_of_the_correct_size' do
        expect { subject }.to change { StudentPair.count }.by(12)
      end
    end
  end
end
