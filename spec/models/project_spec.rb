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
    describe '#generate_student_groupings' do
      let(:turing_module) { create(:turing_module) }
      let(:students) { create_list(:student, 12, turing_module: turing_module) }
      let(:project) { create(:project, size: 3) }
      let(:subject) { project.generate_student_groupings(students) }

      it 'creates_groups_of_the_correct_size' do
        expect { subject }.to change { Group.count }.by(4)
          .and change { StudentGroup.count }.by(12)
      end
    end
  end
end
