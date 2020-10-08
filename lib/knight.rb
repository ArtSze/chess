require_relative 'piece'
require_relative 'output'

class Knight < Piece
  include Output

  MOVE_SET = [
    [2, 1],
    [2, -1],
    [-2, 1],
    [-2, -1],
    [1, 2],
    [1, -2],
    [-1, 2],
    [-1, -2]
  ]

  def valid_space(position)
    position.first.between?(65, 72) && position.last.between?(1, 8) ? true : false
  end

  def create_moves
    x = @current_square.first.ord
    y = @current_square.last.to_i

    MOVE_SET.map { |move| @moves << [(move.first + x).chr, (move.last + y).to_s] if valid_space([(move.first + x), (move.last + y)]) }
  end

  def to_s
    self.color == "black" ? "#{BLACK_KNIGHT_IMAGE}" : "#{WHITE_KNIGHT_IMAGE}"
  end
end 