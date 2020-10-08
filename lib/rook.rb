require_relative 'piece'
require_relative 'output'

class Rook < Piece
  include Output

  def to_s
    self.color == "black" ? "#{BLACK_ROOK_IMAGE}" : "#{WHITE_ROOK_IMAGE}"
  end
end 