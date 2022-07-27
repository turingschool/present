class Pair < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :size
end
