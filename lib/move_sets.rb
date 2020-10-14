module Move_Sets
  MOVE_SETS = {
    knight: [
      [2, 1],
      [2, -1],
      [-2, 1],
      [-2, -1],
      [1, 2],
      [1, -2],
      [-1, 2],
      [-1, -2]
    ],
    white_pawn: [
      [0, 1]
    ],
    black_pawn: [
      [0, -1]
    ],
    rook: [
      [1, 0],
      [7, 0]
    ],
    king: [
      [-1, 1],
      [0, 1],
      [1, 1],
      [-1, 0],
      [1, 0],
      [-1, -1],
      [0, -1],
      [1, -1]
    ]
  }
  #rook has range of +/-7 along x and y axis (create method to populate possible moves?)
  #bishop has range of +/-7 along diagonal axes
  #queen is combination of both rook and bishop
  #king has range of one square in each direction for each move
  #create multiple move_sets for pawn that are used for create_moves method based on certain conditions (such as origin, or opp on diagonal)
end