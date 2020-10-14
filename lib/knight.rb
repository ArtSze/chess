require_relative 'piece'
require_relative 'output'

class Knight < Piece
  def initialize(color, current_square, moves = [], type = 'knight')
    super(color, current_square, moves, type)
  end
end 