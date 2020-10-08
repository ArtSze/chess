require_relative 'piece'
require_relative 'output'

class Queen < Piece
  include Output

  def to_s
    self.color == "black" ? "#{BLACK_QUEEN_IMAGE}" : "#{WHITE_QUEEN_IMAGE}"
  end
end 