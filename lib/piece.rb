class Piece
  include Output
  include Move_Sets

  attr_reader :color, :origin, :type
  attr_accessor :current_square, :moves

  def initialize(color, current_square, moves = [], type)
    @color = color
    @current_square = current_square
    @moves = moves
    @type = type
    @origin = current_square
  end

  def alive?
    @current_square.nil? ? false : true
  end

  def at_origin?
    @current_square.eql?(@origin) ? true : false
  end

  def valid_space(position)
    position[0].between?(65, 72) && position[1].between?(1, 8) ? true : false
  end

  def create_moves
    x = @current_square.first.ord
    y = @current_square.last.to_i
    @type == 'pawn' ? key = [self.color, self.type].join('_').to_sym : key = self.type.to_sym 
    
    move_set = MOVE_SETS.fetch(key)
    opts = []
    move_set.each { |move| opts << move }
  
    if @type == 'pawn'
      opts << [0, 2] if self.at_origin? && self.color == 'white'
      opts << [0, -2] if self.at_origin? && self.color == 'black'
    end

    opts.each { |move| @moves << [(move.first + x).chr, (move.last + y).to_s] if valid_space([(move.first + x), (move.last + y)]) }
  end

  def to_s
    key = [self.color, self.type].join('_').to_sym
    image = IMAGES.fetch(key)
    " #{image}"
  end

end