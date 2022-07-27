class StudentGroup < ApplicationRecord
  belongs_to :student
  belongs_to :group
end
