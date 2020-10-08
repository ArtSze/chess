require_relative 'piece'
require_relative 'output'

class Bishop < Piece
  include Output

  def to_s
    self.color == "black" ? "#{BLACK_BISHOP_IMAGE}" : "#{WHITE_BISHOP_IMAGE}"
  end
end 