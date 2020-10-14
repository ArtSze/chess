require_relative 'piece'
require_relative 'output'

class Queen < Piece
  def initialize(color, current_square, moves = [], type = 'queen')
    super(color, current_square, moves, type)
  end

  def create_moves
    x = @current_square.first.ord
    y = @current_square.last.to_i
    steps = (-7..7).reject { |i| i == 0 }
    steps.each { |step| @moves << [(x + step).chr, y.to_s] if valid_space([(x + step), y]) } 
    steps.each { |step| @moves << [x.chr, (y + step).to_s] if valid_space([x, ( y+ step)]) }
    steps.each { |step| @moves << [(x + step).chr, (y + step).to_s] if valid_space([(x + step), (y + step)]) } 
    steps.each { |step| @moves << [(x - step).chr, (y + step).to_s] if valid_space([(x - step), (y + step)]) }
  end
end 