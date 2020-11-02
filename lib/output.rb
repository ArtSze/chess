module Output
  IMAGES = {
    black_pawn: "\u{2659} ",
    black_knight: "\u{2658} ",
    black_bishop: "\u{2657} ",
    black_rook: "\u{2656} ",
    black_queen: "\u{2655} ",
    black_king: "\u{2654} ",
    white_pawn: "\u{265F} ",
    white_knight: "\u{265E} ",
    white_bishop: "\u{265D} ",
    white_rook: "\u{265C} ",
    white_queen: "\u{265B} ",
    white_king: "\u{265A} "
  }

  SAVE_PROMPT = "You may also save the game and exit at this stage simply by typing 'save'" 

  def clear_terminal
    system 'clear'
  end

  def clear_line_above
    print "\e[1A\e[K"
  end
end

