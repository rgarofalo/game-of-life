class GameSession < ApplicationRecord
  belongs_to :user
  belongs_to :world

  # Validations
  validates :status, presence: true
  validates :user, presence: true
  validates :world, presence: true

  # Status constants
  STATUSES = %w[active completed].freeze
  validates :status, inclusion: { in: STATUSES }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :recent, -> { order(created_at: :desc) }
end
