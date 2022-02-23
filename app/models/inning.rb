class Inning < ApplicationRecord
  validates_presence_of :name

  has_many :turing_modules

  def update_current_status_for_all_other_innings
    self.update(current: true)
    Inning.where.not(id: self.id).update_all(current: false)
  end
end
