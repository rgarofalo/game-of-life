class World < ApplicationRecord
  has_many :game_sessions, dependent: :destroy

  # Validations
  validates :matrix, presence: true
  validates :number_generation, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Get matrix as 2D array (deserialize from binary)
  def grid
    return [] if matrix.blank?
    Marshal.load(matrix)
  end

  # Get dimensions
  def rows
    grid.length
  end

  def cols
    grid.first&.length || 0
  end

  # Check if cell is alive
  def alive?(row, col)
    grid[row]&.[](col) == 1
  end
end
