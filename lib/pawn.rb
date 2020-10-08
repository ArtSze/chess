require_relative 'piece'
require_relative 'output'

class Pawn < Piece
  include Output

  #create multiple move_sets that are used for create_moves method based on certain conditions (such as origin, or opp on diagonal)

  def to_s
    self.color == "black" ? "#{BLACK_PAWN_IMAGE}" : "#{WHITE_PAWN_IMAGE}"
  end
end 