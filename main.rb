#! /usr/bin/env shoes

require './picture.rb'
require './puzzle.rb'

Shoes.app(width:  1000,
          height: 600,
          title:  'Puzzle Game',
          resizable: false) do

  @picture = Picture.new
  @puzzle  = Puzzle.new
  @puzzles = []

  @puzzle_box = flow(width:  800,
                     height: 600) do
    background rgb(0.1, 0.2, 0.3, 0.2)
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

    button('Open picture', left: 35, top:  85) { open_picture unless @current_picture }
    button(' Add puzzle ', left: 35, top: 185) { @current_picture ? add_puzzle   : open_picture }
    button('Show picture', left: 35, top: 285) { @current_picture ? show_picture : open_picture }
    button('    Test    ', left: 35, top: 385) { info 'test' }
    button('  Say bye!  ', left: 35, top: 485) { quit! }
  end


  def open_picture
    @picture.open
    @current_picture = @picture.path
  end

  def show_picture
    window(width:  800,
           height: 600) do
      if @current_picture
        image @current_picture
      else
        para 'Oops! Not found a picture...'
      end
    end
  end

  def add_puzzle
    @puzzle_box.append { @current_puzzle = image(@puzzle.add,
                                                 width:  100,
                                                 height: 100) } unless @puzzle.last
    @puzzles << @current_puzzle

    # Drag and drop puzzle
    @puzzles.each do |p|
      p.click do
        motion do |left, top|
          p.move(left - 50,
                 top  - 50) if p
          @puzzle_box.click { p = nil }
        end
      end
    end
  end

  def quit!
    exit if confirm('Are you sure?')
  end 
end
