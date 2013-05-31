#! /usr/bin/env shoes

require './picture.rb'
require './puzzle.rb'
require 'RMagick'

Shoes.app(width:  1000,
          height: 600,
          title:  'Puzzle Game',
          resizable: false) do

  @picture = Picture.new
  @puzzle  = Puzzle.new
  @puzzles = []

  @puzzle_box = flow(width:  800,
                     height: 600) do
    background orange(0.2)
  end

  @menu_box = stack(width:  200,
                    height: 600) do
    background orange(0.5)

    # Make lines
    (1..5).each do |i|
      power = 1.0 / i unless i == 1
      stroke orange(power)
      strokewidth(i * i)
      
      # Horizontal lines
      top  =  100; top  *= i
      line(0, top, 200, top)

      # Vertical lines
      left = 35; left *= i
      line(left, 0, left, 600)
    end

    button('Open picture', left: 35, top:  85) { open_picture }
    button(' Add puzzle ', left: 35, top: 185) { add_puzzle }
    button(' Show/Hide  ', left: 35, top: 285) { show_or_hide_picture }
    button('  Results   ', left: 35, top: 385) {}
    button('  Say bye!  ', left: 35, top: 485) { quit! }
  end


  def open_picture
    return warn('You already choose a picture!') if @current_picture

    @puzzle_box.append { @current_picture = image(@picture.open,
                                                  width:  800,
                                                  height: 600) }
  end

  def show_or_hide_picture
    return open_picture unless @current_picture

    if @current_picture.hidden
      @puzzles.map { |p| p.hide } if @puzzles.any?
      @current_picture.show
    else
      @current_picture.hide
      @puzzles.map { |p| p.show } if @puzzles.any?
    end
  end

  def add_puzzle
    return open_picture  unless @current_picture
    show_or_hide_picture unless @current_picture.hidden

    @puzzle_box.append { @current_puzzle = image(@puzzle.add,
                                                 width:  100,
                                                 height: 100) } unless @puzzle.last
    @puzzles << @current_puzzle if @current_puzzle
    drag_and_drop_puzzle
  end

  def drag_and_drop_puzzle
    @puzzles.dup.each do |p|
      p.click do
        motion do |left, top|
          # Drag puzzle
          p.move(left - 50,
                 top  - 50) if p
          # Drop puzzle
          @puzzle_box.click { p = nil }
        end
      end
    end
  end

  def quit!
    exit if confirm("Data won't be saved. Are you sure?")
  end
end
