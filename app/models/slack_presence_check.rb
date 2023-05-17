class SlackPresenceCheck < ApplicationRecord
  belongs_to :student

  enum :presence, [:active, :away]
end