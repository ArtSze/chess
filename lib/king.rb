require_relative 'piece'
require_relative 'output'

class King < Piece
  include Output

  def to_s
    self.color == "black" ? "#{BLACK_KING_IMAGE}" : "#{WHITE_KING_IMAGE}"
  end
end 