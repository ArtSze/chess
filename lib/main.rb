require_relative 'board'
require_relative 'square'
require_relative 'output'
require_relative 'piece'
require_relative 'knight'
require_relative 'pawn'
require_relative 'rook'
require_relative 'queen'
require_relative 'king'
require_relative 'bishop'

game = Board.new
piece_two = Knight.new('black', ['B', '3'])
piece_one = Pawn.new('white', ['D', '5'])

#placing piece into new square
g8 = game.squares.select { |square| square.co_ord.first == "G" && square.co_ord.last == "8" }.first
g8.occupied_by = piece_two
piece_two.current_square = g8.co_ord

d5 = game.squares.select { |square| square.co_ord.first == "D" && square.co_ord.last == "5" }.first
d5.occupied_by = piece_one
piece_one.current_square = d5.co_ord
game.draw

#create move options and show possible path
piece_two.create_moves
game.show_path(g8)
game.draw