class Piece
  attr_reader :color, :origin
  attr_accessor :current_square, :moves

  def initialize(color, current_square, moves = [])
    @color = color
    @current_square = current_square
    @moves = moves
    @origin = current_square
  end

  def alive?
    @current_square.nil? ? false : true
  end

  def at_origin?
    @current_square.eql?(@origin) ? true : false
  end
end