files = ['board', 'square', 'output', 'move_sets', 'piece', 'knight', 'pawn', 'rook', 'queen', 'king', 'bishop']
files.each { |file| require_relative file }

class Game
  include Output

  attr_reader :board
  attr_accessor :white_pieces_in_play, :black_pieces_in_play, :white_king, :black_king

  def initialize
    @board = Board.new
    @white_pieces_in_play = []
    @black_pieces_in_play = []
    populate_board
  end

  Player = Struct.new(:name, :color)

  def create_players
    @player_one = Player.new(get_name(1), 'white')
    @player_two = Player.new(get_name(2), 'black')
    @active_player = @player_two #initializes as P2 so that it switches to P1 on initial turn
  end

  def get_name(player_num)
    loop do
      puts "\nWhat is your name player #{player_num}?"
      name = gets.chomp.strip
      break name if name.match?(/^[\w]+$/)
      clear_line_above
      puts "\nPlease enter a valid name... (alphanumeric only without spaces)".red
    end
  end

  def populate_board
    colors = ['black', 'white']
    columns = ('A'..'H').to_a
    colors.each do |color|
      pawn_row, spec_row, group = '7', '8', @black_pieces_in_play if color == 'black' 
      pawn_row, spec_row, group  = '2', '1', @white_pieces_in_play if color == 'white'
      columns.each do |column| 
        piece = Pawn.new(color, [column, pawn_row]) 
        group << piece
        current_square = @board.retrieve_square(piece.current_square)
        current_square.occupied_by = piece
      end
      ['A', 'H'].each do |rook_column|
        piece = Rook.new(color, [rook_column, spec_row])
        group << piece 
        current_square = @board.retrieve_square(piece.current_square)
        current_square.occupied_by = piece
      end
      ['B', 'G'].each do |knight_column|
        piece = Knight.new(color, [knight_column, spec_row]) 
        group << piece
        current_square = @board.retrieve_square(piece.current_square)
        current_square.occupied_by = piece
      end
      ['C', 'F'].each do |bishop_column|
        piece = Bishop.new(color, [bishop_column, spec_row]) 
        group << piece
        current_square = @board.retrieve_square(piece.current_square)
        current_square.occupied_by = piece
      end
      queen = Queen.new(color, ['D', spec_row])
      group << queen
      queen_square = @board.retrieve_square(queen.current_square)
      queen_square.occupied_by = queen

      king = King.new(color, ['E', spec_row])
      group << king
      king_square = @board.retrieve_square(king.current_square)
      king_square.occupied_by = king
    end
    @white_king = @white_pieces_in_play.select { |piece| piece.type == 'king' }.first
    @black_king = @black_pieces_in_play.select { |piece| piece.type == 'king' }.first
  end

  def switch_player
    @active_player == @player_one ? @active_player = @player_two : @active_player = @player_one
  end

  def check_path(piece)
    taken = piece.moves.select do |move|
      @board.retrieve_square(move).occupied_by.nil? == false
    end

    if piece.type == 'knight'
      to_omit = taken.select { |move| @board.retrieve_square(move).occupied_by.color == piece.color }
      piece.moves.delete_if { |move| to_omit.include?(move) }
    end
    
    if piece.type == 'pawn'
      to_omit = taken.select { |move| @board.retrieve_square(move).co_ord.first == piece.current_square.first }
      piece.moves.delete_if { |move| to_omit.include?(move) }
    end

    # bishops, queens, and rooks
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
        down_right_diagonal << [(piece_column_ascii + step).chr, (piece_row_num - step).to_s]
      end 
  
      to_omit = []
  
      if @board.retrieve_square(square).occupied_by.color == piece.color #same color
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
            if down_right_diagonal.include?(move) && move.last.to_i <= taken_row_num
              to_omit << move 
            end
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
  
      if @board.retrieve_square(square).occupied_by.color != piece.color #opp color
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

  def pawn_diag(piece)
    column = piece.current_square.first.ord
    row = piece.current_square.last.to_i

    if piece.color == 'black'
      to_process = []
      
      to_process << [(column - 1).chr, (row - 1).to_s] if piece.valid_space([column - 1, row - 1])
      to_process << [(column + 1).chr, (row - 1).to_s] if piece.valid_space([column + 1, row - 1])  
      
      to_process.each do |square|
        if @analyzing_king_moveset == true
          piece.moves << square
        else
          if @board.retrieve_square(square).occupied_by != nil && @board.retrieve_square(square).occupied_by.color == 'white'
            piece.moves << square 
          end
        end
      end 
      
    elsif piece.color == 'white'
      to_process = []
      
      to_process << [(column - 1).chr, (row + 1).to_s] if piece.valid_space([column - 1, row + 1])
      to_process << [(column + 1).chr, (row + 1).to_s] if piece.valid_space([column + 1, row + 1])
      
      to_process.each do |square|
        if @analyzing_king_moveset == true
          piece.moves << square
        else
          if @board.retrieve_square(square).occupied_by != nil && @board.retrieve_square(square).occupied_by.color == 'black'
            piece.moves << square 
          end
        end
      end 
    end
  end

  def king_viable_moves(piece) #incorporate king_in_check? to see if any hypothetical moves would put it in check... remove those from @moves if so
    @analyzing_king_moveset = true
    opp_pieces, opp_moves = [], []
    piece.color == 'black' ? @white_pieces_in_play.each { |piece| opp_pieces << piece } : @black_pieces_in_play.each { |piece| opp_pieces << piece }
    
    opp_pieces.each do |opp_piece| 
      if opp_piece.type == 'pawn' 
        pawn_diag(opp_piece) 
      else 
        opp_piece.create_moves 
        check_path(opp_piece)
      end
      opp_piece.moves.each do |move| 
        opp_moves << move 
      end
    end 

    piece.create_moves

    #flawed because you only want to remove moves if the bait space is in the move_set of another opp piece
    immediate_surroundings = piece.moves
    opp_occupied = immediate_surroundings.select { |move| @board.retrieve_square(move).occupied_by != nil && @board.retrieve_square(move).occupied_by.color != piece.color }
    own_occupied = immediate_surroundings.select { |move| @board.retrieve_square(move).occupied_by != nil && @board.retrieve_square(move).occupied_by.color == piece.color }

    # opp_occupied.each { |bait_space| piece.moves.delete_if { |bait_space| opp_moves.include?(bait_space) } }

    piece.moves.delete_if { |move| opp_moves.include?(move) || own_occupied.include?(move) }
    @analyzing_king_moveset = false
  end

  def king_in_check?(piece, square)
    opp_pieces, opp_moves = [], []
    piece.color == 'black' ? @white_pieces_in_play.each { |piece| opp_pieces << piece } : @black_pieces_in_play.each { |piece| opp_pieces << piece }
    
    opp_pieces.each do |opp_piece| 
      if opp_piece.type == "pawn" 
        pawn_diag(opp_piece) 
      else 
        opp_piece.create_moves 
        check_path(opp_piece)
      end
      opp_piece.moves.each do |move| 
        opp_moves << move 
      end
    end

    opp_moves.include?(square) ? true : false
  end

  def turn
    switch_player
    reset_board
    player_move_piece(choose_piece)
    reset_board
  end

  def choose_piece
    loop do
      puts "\n#{@active_player.color.upcase}'s turn: Which piece would you like to move #{@active_player.name}? (enter its current square e.g. 'A2')" 
      choice = gets.chomp.strip.upcase
      break choice if valid_choice?(choice) && piece_has_moves?(choice)
      clear_line_above
      puts "\nPlease enter a valid square... (column letter followed by row number)".red
    end
  end 

  def valid_choice?(choice)
    (choice.match?(/[A-H][1-8]/) && (@board.retrieve_square(choice).occupied_by != nil) && (@board.retrieve_square(choice).occupied_by.color == @active_player.color)) ? true : false
  end

  def piece_has_moves?(choice)
    piece = @board.retrieve_square(choice).occupied_by
    all_move_options(piece)
    piece.moves.length > 0 ? true : false
  end

  def all_move_options(piece)
    if piece.type == 'king'
      king_viable_moves(piece) 
    else
      piece.create_moves
      pawn_diag(piece) if piece.type == 'pawn'
      check_path(piece)
    end
  end

  def player_move_piece(start)
    first_square = @board.retrieve_square(start)
    piece = first_square.occupied_by
    piece.moves.clear
    all_move_options(piece)
    @board.show_path(piece)
    draw_board
    co_ords = []
    
    loop do
      puts "\nwhere would you like to move to?"
      choice = gets.chomp.strip.upcase
      co_ords.clear
      co_ords << choice[0]
      co_ords << choice[1]
      break if piece.moves.include?(co_ords) && choice.match?(/[A-H][1-8]/)
      puts "\ninvalid choice... please choose from the illuminated squares".red
    end
    second_square = @board.retrieve_square(co_ords)

    if second_square.occupied_by != nil
      if @active_player.color == 'white'
        @black_pieces_in_play.delete(second_square.occupied_by)
      elsif @active_player.color == 'black'
        @white_pieces_in_play.delete(second_square.occupied_by)
      end
    end

    second_square.occupied_by = piece
    piece.current_square = second_square.co_ord
    first_square.occupied_by = nil
    piece.moves.clear
    p piece
  end

  def god_move_piece(start, destination)
    first_square = @board.retrieve_square(start)
    second_square = @board.retrieve_square(destination)
    piece = first_square.occupied_by
    first_square.occupied_by = nil
    second_square.occupied_by = piece
    piece.current_square = second_square.co_ord
  end

  def draw_board
    # clear_terminal
    @board.draw
  end

  def reset_board
    @board.clear_illumination
    # clear_terminal
    @board.draw
  end

  def clear_all_moves
    all_pieces = []
    [@white_pieces_in_play, @white_pieces_in_play].each { |collection| collection.each { |piece| all_pieces << piece } }
    all_pieces.each { |piece| piece.moves.clear }
  end

  # en_passant method
  # pawn must be at origin
  # pawn must move two squares ahead to a square where an opp pawn is on an adjacent square(left or right) 
  # opp pawn can move diagonally to square beyond OG pawn, taking OG pawn in the process...
  # MUST be done immediately after OG pawn moves two squares... otherwise that pawn cannot be taken en-passant

end
  

game = Game.new
game.create_players
game.god_move_piece('E1', 'E3')
game.god_move_piece('D7', 'D4')
game.god_move_piece('A8', 'C4')

game.turn

p game.white_king
puts ''
p game.king_in_check?(game.white_king, game.white_king.current_square)

game.turn
p game.king_in_check?(game.white_king, game.white_king.current_square)
game.turn
p game.king_in_check?(game.white_king, game.white_king.current_square)
game.turn
p game.king_in_check?(game.white_king, game.white_king.current_square)