require_relative 'piece'
require_relative 'output'

class King < Piece
  def initialize(color, current_square, moves = [], type = 'king')
    super(color, current_square, moves, type)
  end
end 