class Student < ApplicationRecord
  belongs_to :turing_module, optional: true
  has_many :student_attendances, dependent: :destroy
  has_many :attendances, through: :student_attendances
  has_many :zoom_aliases

  validates_presence_of :name

  validates_uniqueness_of :slack_id, scope: :turing_module_id, allow_nil: true

  def self.have_slack_ids 
    # REFACTOR
    !Student.where.not(slack_id: nil).empty?
  end 
  
  def self.have_zoom_aliases?
    joins(:zoom_aliases).any?
  end

  def latest_zoom_alias
    zoom_aliases.order(created_at: :DESC).limit(1).first
  end

  def zoom_name
    latest_zoom_alias.name if latest_zoom_alias
  end

  def add_zoom_alias(name)
    return true if name.blank?
    self.zoom_aliases.create(name: name)
  end
end
