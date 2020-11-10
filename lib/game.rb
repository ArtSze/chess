files = ['board', 'square', 'output', 'move_sets', 'piece', 'knight', 'pawn', 'rook', 'queen', 'king', 'bishop']
files.each { |file| require_relative file }
require 'yaml'

class Game
  include Output

  attr_reader :board
  attr_accessor :white_pieces_in_play, :black_pieces_in_play, :white_king, :black_king, :player_one, :player_two, :active_player, :active_king, :verify_for_choice, :analyzing_king_moveset, :en_passant_pieces

  Player = Struct.new(:name, :color)

  def create_players
    @player_one = Player.new(get_name(1), 'white')
    @player_two = Player.new(get_name(2), 'black')
    @active_player = @player_two #initializes as P2 so that it switches to P1 on initial turn
    @active_king = @black_king
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
    @en_passant_pieces = []
  end

  def switch_player
    @active_player == @player_one ? @active_player = @player_two : @active_player = @player_one
  end

  def all_move_options(piece)
    if piece.type == 'king'
      king_viable_moves(piece) 
    else
      piece.create_moves
      if piece.type == 'pawn'
        pawn_diag(piece)
        if @en_passant_pieces.length > 0 #if en_passant conditions exist... adds square on diagonal to move_set
          piece.color == 'white' ? row_change = 1 : row_change = -1
          @en_passant_pieces.each do |piece_and_move|
            en_passant_destination_row = (piece_and_move.last.last.to_i + row_change).to_s
            piece.moves << [piece_and_move.last.first, en_passant_destination_row] if piece_and_move.first == piece
          end
        end
      check_path(piece)
      end
    end
  end

  def king_viable_moves(piece) 
    @analyzing_king_moveset = true
    bait_spaces, unsafe_empties  = [], []

    piece.create_moves

    immediate_surroundings = piece.moves
    own_occupied = immediate_surroundings.select { |move| @board.retrieve_square(move).occupied_by != nil && @board.retrieve_square(move).occupied_by.color == piece.color }
    opp_occupied = immediate_surroundings.select { |move| @board.retrieve_square(move).occupied_by != nil && @board.retrieve_square(move).occupied_by.color != piece.color }
    empty_spaces = immediate_surroundings.select { |move| @board.retrieve_square(move).occupied_by == nil }

    opp_occupied.each do |check_if_bait|
      king_space = piece.current_square
      piece_temp_removed = @board.retrieve_square(check_if_bait).occupied_by
      @board.retrieve_square(check_if_bait).occupied_by = nil
      @board.retrieve_square(king_space).occupied_by = nil
      bait_spaces << check_if_bait if king_in_check?(piece, check_if_bait)
      @board.retrieve_square(check_if_bait).occupied_by = piece_temp_removed
      @board.retrieve_square(king_space).occupied_by = piece
    end

    empty_spaces.each do |empty_to_check|
      king_space = piece.current_square
      @board.retrieve_square(king_space).occupied_by = nil
      unsafe_empties << empty_to_check if king_in_check?(piece, empty_to_check)
      @board.retrieve_square(king_space).occupied_by = piece
    end

    piece.moves.delete_if { |move| unsafe_empties.include?(move) || own_occupied.include?(move) || bait_spaces.include?(move)}
    
    @analyzing_king_moveset = false
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

  def choose_piece 
    save_trigger = /SAVE/i
    if king_in_check?(@active_king, @active_king.current_square)
      @verify_for_choice = true
      pieces_checking_king = king_in_check?(@active_king, @active_king.current_square)
      @verify_for_choice = false
      opp_piece_squares, own_pieces, defensive_choices = [], [], []
      pieces_checking_king.each { |opp_piece_checking_king| opp_piece_squares << opp_piece_checking_king.current_square}
      @active_player.color == 'black' ? @black_pieces_in_play.each { |piece| own_pieces << piece } : @white_pieces_in_play.each { |piece| own_pieces << piece }
      own_pieces.each do |piece|
        all_move_options(piece)
        piece.moves.each do |move|
          defensive_choices << piece.current_square if opp_piece_squares.include?(move)
        end
      end
      defensive_choices << @active_king.current_square if piece_has_moves?(@active_king.current_square)
      puts "\n#{@active_player.color.upcase}'s turn..."
      loop do
        puts "Your king is in check. Either move him to safety or eliminate the threat."
        puts "Which piece would you like to move #{@active_player.name}? (enter its current square e.g. 'A2')"
        puts "#{SAVE_PROMPT}".blue
        puts "" 
        choice = gets.chomp.strip.upcase
        formatted_choice = []
        formatted_choice << choice[0]
        formatted_choice << choice[1]
        self.save_game if save_trigger.match(choice)
        break choice if defensive_choices.include?(formatted_choice) 
        puts "You must choose a piece that either takes the opponent's piece putting your king in check... or move the king himself."
      end
    else
      loop do
        puts "\n#{@active_player.color.upcase}'s turn: Which piece would you like to move #{@active_player.name}? (enter its current square e.g. 'A2')"
        puts "#{SAVE_PROMPT}".blue
        puts "" 
        choice = gets.chomp.strip.upcase
        self.save_game if save_trigger.match(choice)
        break choice if valid_choice?(choice) && piece_has_moves?(choice)
        clear_line_above
        puts "\nPlease enter a valid square... (column letter followed by row number)".red
      end
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
    else
      if piece.type == 'pawn' && ((co_ords.first.ord - start[0].ord).abs == 1) # post en_passant move clears square behind destination
        @active_player.color == 'white' ? row_behind = -1 : row_behind = 1
        square_taken_en_passant = @board.retrieve_square([co_ords.first, ((co_ords.last.to_i + row_behind).to_s)])
        square_taken_en_passant.occupied_by = nil
      end
      second_square.occupied_by = piece
      piece.current_square = second_square.co_ord
      first_square.occupied_by = nil
      @en_passant_pieces.clear
    end

    if piece.type == 'pawn'
      verify_promotion(piece)
      if (first_square.co_ord.last.to_i - second_square.co_ord.last.to_i).abs == 2 #triggers en_passant (pawn advances two squares)
        verify_en_passant(piece) 
      end
    end

    piece.moves.clear
    
  end

  def god_move_piece(start, destination)
    first_square = @board.retrieve_square(start)
    second_square = @board.retrieve_square(destination)
    piece = first_square.occupied_by
    first_square.occupied_by = nil
    second_square.occupied_by = piece
    piece.current_square = second_square.co_ord
  end

  def king_in_check?(piece, square)
    opp_pieces, opp_moves, pieces_checking_king = [], [], []
    piece.color == 'black' ? @white_pieces_in_play.each { |piece| opp_pieces << piece } : @black_pieces_in_play.each { |piece| opp_pieces << piece }
    
    opp_pieces.each do |opp_piece| 
      if opp_piece.type == "pawn" 
        pawn_diag(opp_piece) 
      else 
        opp_piece.create_moves 
        check_path(opp_piece)
      end
      opp_piece.moves.each do |move| 
        if @verify_for_choice == true
          pieces_checking_king << opp_piece if move == square
        else
          opp_moves << move 
        end
      end
    end

    if @verify_for_choice == true
      pieces_checking_king
    else
      opp_moves.include?(square) ? true : false
    end
  end

  def check_mate?(king) 
    king_viable_moves(king)
    (king_in_check?(king, king.current_square) || king.at_origin? == false) && king.moves.length == 0 ? false : false
  end

  def play
    start
    turn until check_mate?(@active_king) != false
  end

  def turn
    switch_player
    @active_player == @player_one ? @active_king = @white_king : @active_king = @black_king
    reset_board
    return end_game if check_mate?(@active_king)
    player_move_piece(choose_piece)
    reset_board
    clear_all_moves
  end

  def end_game
    puts "\n#{@active_player.name} loses!" 
    puts "Play again? (Y/N)"
    valid_yes_responses = ["y", "yes", "yup", "yeah"]
    valid_no_responses = ["n", "no", "nope", "nah"]
    response = gets.chomp.downcase
    until valid_yes_responses.any? { |option| option == response } || valid_no_responses.any? { |option| option == response }
      puts "\nPlay again?  (Y/N)"
      response = gets.chomp.downcase
      puts "\n"
    end
    Game.new.play if valid_yes_responses.any? { |option| option == response }
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

  def start
    clear_terminal
    puts "\nWelcome to Chess. Hopefully you already know how to play!"
    puts "\nWould you like to start a new game or load the most recent game? (new/load)"
    input = gets.chomp.strip.gsub(" ", "").downcase
    case input
    when "new"
      self.game_from_scratch
    when "load"
      self.load_game
    end
  end

  def game_from_scratch
    @board = Board.new
    @white_pieces_in_play = []
    @black_pieces_in_play = []
    populate_board
    create_players
  end

  def load_game
    most_recent_game = Dir[File.join("saved_games", '*')].max_by(&File.method(:ctime))
    game = YAML.load(File.open(most_recent_game))
    @board = game.board
    @player_one = game.player_one
    @player_two = game.player_two
    @white_pieces_in_play = game.white_pieces_in_play
    @black_pieces_in_play = game.black_pieces_in_play
    @white_king = game.white_king
    @black_king = game.black_king
    @active_player = game.active_player
    @active_king = game.active_king
    @verify_for_choice = game.verify_for_choice
    @analyzing_king_moveset = game.analyzing_king_moveset
    @en_passant_pieces = game.en_passant_pieces
    switch_player
  end

  def save_game
    puts "\ncurrently saving..."
    current_game = self
    @serialized_game = YAML::dump(current_game)
    current_time = Time.now.getlocal('-04:00') 
    Dir.mkdir("saved_games") unless Dir.exists? "saved_games"
    filename = "saved_games/#{current_time.mon}_#{current_time.day}_#{current_time.hour}h#{current_time.min}m"
    File.open(filename, 'w') { |file| file.puts @serialized_game}
    sleep(1)
    puts "saved!"
    exit
  end

  def verify_promotion(pawn)
    color = pawn.color
    color == 'white' ? promotion_row = '8' : promotion_row = '1'
    promote(pawn) if pawn.current_square.last == promotion_row 
  end

  def promote(pawn)
    current_square = @board.retrieve_square(pawn.current_square)
    color = pawn.color
    color == 'white' ? @white_pieces_in_play.delete(pawn) : @black_pieces_in_play.delete(pawn)
    current_square.occupied_by = nil
    choice = get_promotion_choice
    case choice
    when "K"
      current_square.occupied_by = Knight.new(color, current_square.co_ord) 
    when "Q"
      current_square.occupied_by = Queen.new(color, current_square.co_ord) 
    when "R"
      current_square.occupied_by = Rook.new(color, current_square.co_ord) 
    when "B"
      current_square.occupied_by = Bishop.new(color, current_square.co_ord) 
    end
    color == 'white' ? @white_pieces_in_play << current_square.occupied_by : @black_pieces_in_play << current_square.occupied_by
  end

  def get_promotion_choice
    promotion_choices = ["K", "Q", "R", "B"]
    loop do
      puts "\nYou can promote your pawn... what kind of piece would you like to promote it to?"
      puts "(K)night (Q)ueen (R)ook (B)ishop ?"
      choice = gets.chomp.strip.upcase
      break choice if promotion_choices.include?(choice)
      clear_line_above
      puts "\nPlease enter a valid piece"
    end
  end

  def verify_en_passant(piece) #checks adjacent square for en_passant & adds to array for later processing
    column = piece.current_square.first.ord
    row = piece.current_square.last
    c_to_left = (column - 1).chr
    c_to_right = (column + 1).chr
    left_square = @board.retrieve_square([c_to_left, row])
    right_square = @board.retrieve_square([c_to_right, row])
    [left_square, right_square].each do |square|
      if square != nil && square.occupied_by != nil
        if square.occupied_by.type == 'pawn' && square.occupied_by.color != piece.color
          @en_passant_pieces << [square.occupied_by, piece.current_square]
        end
      end
    end
  
  end

  # castling method
end
  
Game.new.play