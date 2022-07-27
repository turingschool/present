class Pair < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :size

  has_many :student_pairs, dependent: :destroy
  has_many :students, through: :student_pairs
end
