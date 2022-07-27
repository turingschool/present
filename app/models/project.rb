class Project < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :size

  has_many :groups

  def generate_student_groupings(students)
    group_lists = students.shuffle.each_slice(size).to_a
    create_student_groups(group_lists)
  end

  private

  def create_student_groups(group_lists)
    group_lists.each do |group|
      new_group = Group.create(project: self)
      group.each do |student|
        StudentGroup.create(student: student, group: new_group)
      end
    end
  end
end
