class Pair < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :size

  has_many :student_pairs, dependent: :destroy
  has_many :students, through: :student_pairs

  def generate_student_pairings(students)
    groups = students.shuffle.each_slice(size).to_a
    create_student_pairs(groups)
  end

  private

  def create_student_pairs(groups)
    groups.each_with_index do |group, i|
      group.each do |student|
        StudentPair.create(student: student, pair: self, name: "Group #{i+1}")
      end
    end
  end
end
