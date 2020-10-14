require_relative 'piece'
require_relative 'output'

class Pawn < Piece
  def initialize(color, current_square, moves = [], type = 'pawn')
    super(color, current_square, moves, type)
  end
end 