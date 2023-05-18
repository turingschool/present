class SlackPresenceCheck < ApplicationRecord
  belongs_to :student

  enum :presence, [:active, :away]

  validates_presence_of :check_time
end