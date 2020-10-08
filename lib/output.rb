module Output
  BLACK_PAWN_IMAGE = "\u{2659} "
  BLACK_KNIGHT_IMAGE = "\u{2658} "
  BLACK_BISHOP_IMAGE = "\u{2657} "
  BLACK_ROOK_IMAGE = "\u{2656} "
  BLACK_QUEEN_IMAGE = "\u{2655} "
  BLACK_KING_IMAGE = "\u{2654} "
  WHITE_PAWN_IMAGE = "\u{265F} "
  WHITE_KNIGHT_IMAGE = "\u{265E} "
  WHITE_BISHOP_IMAGE = "\u{265D} "
  WHITE_ROOK_IMAGE = "\u{265C} "
  WHITE_QUEEN_IMAGE = "\u{265B} "
  WHITE_KING_IMAGE = "\u{265A} "

  def clear_terminal
    system 'clear'
  end

  def clear_line_above
    print "\e[1A\e[K"
  end
end

