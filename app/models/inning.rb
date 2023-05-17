class Inning < ApplicationRecord
  validates_presence_of :name

  has_many :turing_modules, dependent: :destroy
  has_many :students, through: :turing_modules

  def make_current_inning
    self.update(current: true)
    Inning.where.not(id: self.id).update_all(current: false)
  end

  def self.order_by_name
    order(name: :desc)
  end
end
