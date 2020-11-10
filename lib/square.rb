require 'rubygems'
require 'colorize'

class Square
  attr_reader :bg_color 
  attr_accessor :co_ord, :occupied_by, :illuminated

  def initialize(co_ord, bg_color, occupied_by = nil)
    @co_ord = co_ord
    @bg_color = bg_color
    @occupied_by = occupied_by
    @illuminated = false
  end

  def string
    contents = @occupied_by.nil? ? "   " : @occupied_by.to_s 
    if @illuminated == true 
      contents == "   " ? contents.colorize( :background => :green) : contents.colorize( :background => :red)
    else
      @bg_color == "white" ? contents.colorize( :background => :light_black) : contents.colorize( :background => :black)
    end
  end
end
