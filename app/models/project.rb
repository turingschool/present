class Project < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :size

  has_many :groups

  def generate_student_pairings(students)
    groups = students.shuffle.each_slice(size).to_a
    create_student_pairs(groups)
  end

  private

  def create_student_pairs(groups)
    groups.each_with_index do |group, i|
      group.each do |student|
        StudentPair.create(student: student, project: self, name: "Group #{i+1}")
      end
    end
  end
end
