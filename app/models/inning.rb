class Inning < ApplicationRecord
  validates_presence_of :name

  has_many :turing_modules
end
