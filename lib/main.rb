require_relative 'board'
require_relative 'square'
require_relative 'output'
require_relative 'move_sets'
require_relative 'piece'
require_relative 'knight'
require_relative 'pawn'
require_relative 'rook'
require_relative 'queen'
require_relative 'king'
require_relative 'bishop'

game = Board.new
@white_pieces_in_play = []
@black_pieces_in_play = []

# piece_two = Knight.new('black', ['D', '4'])
piece_one = Pawn.new('white', ['B', '2'])
piece_three = Pawn.new('black', ['C','4'])
# piece_four = King.new('black', ['C', '7'])
# piece_five = Rook.new('white', ['E', '3'])
# piece_six = Bishop.new('white', ['F', '4'])
# piece_seven = Queen.new('white', ['E', '4'])

# [piece_two, piece_one, piece_four].each { |piece| @black_pieces_in_play << piece }
# [piece_three, piece_five, piece_six, piece_seven].each { |piece| @white_pieces_in_play << piece }


#placing piece into new square... used during game initialization to populate board
# d4 = game.retrieve_square("D4")
# d4.occupied_by = piece_two
# piece_two.current_square = d4.co_ord

b2 = game.retrieve_square("B2")
b2.occupied_by = piece_one
piece_one.current_square = b2.co_ord

c4 = game.retrieve_square('C4')
c4.occupied_by = piece_three
piece_three.current_square = c4.co_ord

# c7 = game.retrieve_square('C7')
# c7.occupied_by = piece_four
# piece_four.current_square = c7.co_ord

# e3 = game.retrieve_square('E3')
# e3.occupied_by = piece_five
# piece_five.current_square = e3.co_ord

# f4 = game.retrieve_square('F4')
# f4.occupied_by = piece_six
# piece_six.current_square = f4.co_ord

# e4 = game.retrieve_square('E4')
# e4.occupied_by = piece_seven
# piece_seven.current_square = e4.co_ord

# replace 'game' with @board in game.rb
def pawn_diag(pawn_to_check, game)
  if pawn_to_check.color == 'black'
    left = [(pawn_to_check.current_square.first.ord - 1).chr, (pawn_to_check.current_square.last.to_i - 1).to_s]
    right = [(pawn_to_check.current_square.first.ord + 1).chr, (pawn_to_check.current_square.last.to_i - 1).to_s]
    [left, right].each do |square|
      if game.retrieve_square(square).occupied_by != nil
        pawn_to_check.moves << square if game.retrieve_square(square).occupied_by.color == 'white'
      end
    end
  elsif pawn_to_check.color == 'white'
    left = [(pawn_to_check.current_square.first.ord - 1).chr, (pawn_to_check.current_square.last.to_i + 1).to_s]
    right = [(pawn_to_check.current_square.first.ord + 1).chr, (pawn_to_check.current_square.last.to_i + 1).to_s]
    [left, right].each do |square|
      if game.retrieve_square(square).occupied_by != nil
        pawn_to_check.moves << square if game.retrieve_square(square).occupied_by.color == 'black'
      end
    end
  end
end

def check_path(piece, game)
  taken = piece.moves.select do |move|
    game.retrieve_square(move).occupied_by.nil? == false
  end
  
  taken.each do |square|
    piece_column_ascii = piece.current_square.first.ord
    piece_row_num = piece.current_square.last.to_i
    taken_column_ascii = square.first.ord
    taken_row_num = square.last.to_i
    
    up_left_diagonal, up_right_diagonal, down_left_diagonal, down_right_diagonal = [], [], [], []
    steps = (1..7)
    steps.each do |step| 
      up_left_diagonal << [(piece_column_ascii - step).chr, (piece_row_num + step).to_s]
      up_right_diagonal << [(piece_column_ascii + step).chr, (piece_row_num + step).to_s]
      down_left_diagonal << [(piece_column_ascii - step).chr, (piece_row_num - step).to_s]
      down_right_diagonal << [(piece_column_ascii - step).chr, (piece_row_num + step).to_s]
    end 

    to_omit = []

    if game.retrieve_square(square).occupied_by.color == piece.color #same color
      if up_left_diagonal.include?(square)
        piece.moves.each do |move|
          to_omit << move if up_left_diagonal.include?(move) && move.last.to_i >= taken_row_num
        end
      elsif up_right_diagonal.include?(square)
        piece.moves.each do |move|
          to_omit << move if up_right_diagonal.include?(move) && move.last.to_i >= taken_row_num
        end
      elsif down_left_diagonal.include?(square)
        piece.moves.each do |move|
          to_omit << move if down_left_diagonal.include?(move) && move.last.to_i <= taken_row_num
        end
      elsif down_right_diagonal.include?(square)
        piece.moves.each do |move|
          to_omit << move if down_right_diagonal.include?(move) && move.last.to_i <= taken_row_num
        end
      elsif (taken_column_ascii < piece_column_ascii) && (taken_row_num == piece_row_num) #left
        piece.moves.each do |move|
          to_omit << move if (move.first.ord <= taken_column_ascii) && (move.last.to_i == taken_row_num)
        end
      elsif (taken_column_ascii > piece_column_ascii) && (taken_row_num == piece_row_num) #right
        piece.moves.each do |move|
          to_omit << move if (move.first.ord >= taken_column_ascii) && (move.last.to_i == taken_row_num)
        end
      elsif (taken_column_ascii == piece_column_ascii) && (taken_row_num > piece_row_num) #above
        piece.moves.each do |move|
          to_omit << move if (move.first.ord == taken_column_ascii) && (move.last.to_i >= taken_row_num)
        end
      elsif (taken_column_ascii == piece_column_ascii) && (taken_row_num < piece_row_num) #below
        piece.moves.each do |move|
          to_omit << move if (move.first.ord == taken_column_ascii) && (move.last.to_i <= taken_row_num)
        end
      end
    end

    if game.retrieve_square(square).occupied_by.color != piece.color #opp color
      if up_left_diagonal.include?(square)
        piece.moves.each do |move|
          to_omit << move if up_left_diagonal.include?(move) && move.last.to_i > taken_row_num
        end
      elsif up_right_diagonal.include?(square)
        piece.moves.each do |move|
          to_omit << move if up_right_diagonal.include?(move) && move.last.to_i > taken_row_num
        end
      elsif down_left_diagonal.include?(square)
        piece.moves.each do |move|
          to_omit << move if down_left_diagonal.include?(move) && move.last.to_i < taken_row_num
        end
      elsif down_right_diagonal.include?(square)
        piece.moves.each do |move|
          to_omit << move if down_right_diagonal.include?(move) && move.last.to_i < taken_row_num
        end
      elsif (taken_column_ascii < piece_column_ascii) && (taken_row_num == piece_row_num) #left
        piece.moves.each do |move|
          to_omit << move if (move.first.ord < taken_column_ascii) && (move.last.to_i == taken_row_num)
        end
      elsif (taken_column_ascii > piece_column_ascii) && (taken_row_num == piece_row_num) #right
        piece.moves.each do |move|
          to_omit << move if (move.first.ord > taken_column_ascii) && (move.last.to_i == taken_row_num)
        end
      elsif (taken_column_ascii == piece_column_ascii) && (taken_row_num > piece_row_num) #above
        piece.moves.each do |move|
          to_omit << move if (move.first.ord == taken_column_ascii) && (move.last.to_i > taken_row_num)
        end
      elsif (taken_column_ascii == piece_column_ascii) && (taken_row_num < piece_row_num) #below
        piece.moves.each do |move|
          to_omit << move if (move.first.ord == taken_column_ascii) && (move.last.to_i < taken_row_num)
        end
      end
    end

    piece.moves.delete_if { |move| to_omit.include?(move) }
  end
end

def king_viable_moves(piece)
  opp_pieces, opp_moves = [], []
  piece.color == 'black' ? @white_pieces_in_play.each { |piece| opp_pieces << piece } : @black_pieces_in_play.each { |piece| opp_pieces << piece }
  opp_pieces.each do |piece| 
    piece.create_moves 
    piece.moves.each { |move| opp_moves << move }
  end
  piece.moves.delete_if { |move| opp_moves.include?(move) }
end

# en_passant method
# pawn must be at origin
# pawn must move two squares ahead to a square where an opp pawn is on an adjacent square(left or right) 
# opp pawn can move diagonally to square beyond OG pawn, taking OG pawn in the process...
# MUST be done immediately after OG pawn moves two squares... otherwise that pawn cannot be taken en-passant




# promote method
# discards pawn when: white reaches row 8 || black reaches row 1... initializes queen of same color in pawn's place

# castling method





#create move options, check path to remove paths w/obstructions and then show possible path

#specific order of ops for pawn
# piece_one.create_moves
# pawn_diag(piece_one, game)
# game.show_path(b2)

# piece_seven.create_moves
# check_path(piece_seven, game)
# game.show_path(e4)

# piece_five.create_moves
# check_path(piece_five, game)
# game.show_path(e3)

# piece_four.create_moves
# check_path(piece_four, game)
# king_viable_moves(piece_four)
# game.show_path(c7)

game.draw