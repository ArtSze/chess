require 'colorize'
require_relative 'square.rb'

ROW_HEADERS = %w(1 2 3 4 5 6 7 8)
COLUMN_HEADERS = %w(A B C D E F G H)

class Board
  attr_accessor :squares
  attr_reader :rows, :columns

  def initialize
    @squares = []

    COLUMN_HEADERS.each_with_index do |column, i|
      ROW_HEADERS.each_with_index do |row, j|
        if j.even?
          i.even? ? @squares << Square.new([column, row], "white") : @squares << Square.new([column, row], "black")
        else
          i.even? ? @squares << Square.new([column, row], "black") : @squares << Square.new([column, row], "white")
        end
      end
    end
  end

  def draw
    puts "\n"
    for i in 8.downto(1)
      draw_row(i)
    end
    puts "  A B C D E F G H "
  end

  def draw_row(row_num)
    row = @squares.select{ |square| square.co_ord.last == row_num.to_s }
    print "#{row_num} "
    row.each { |square| print square.string}
    puts
  end

  def show_path(starting_point)
    path = [] 
    @squares.each { |square| path << square if starting_point.occupied_by.moves.include?(square.co_ord)}
    path.each do |square| 
      square.illuminated = true
    end
  end

  def retrieve_square(co_ord)
    column = co_ord[0]
    row = co_ord[1]
    @squares.select { |square| square.co_ord.first == column && square.co_ord.last == row }.first
  end
end