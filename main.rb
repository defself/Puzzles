#! /usr/bin/env shoes

require './puzzle.rb'

Shoes.app(width:  1100,
          height: 600,
          title:  'Puzzle Game',
          resizable: false) do


############################## Boxes ##############################


  # Menu
  stack(width:  200,
        height: 600,
        left: 0) do
    background '/home/seniorihor/Code/shoes/puzzles/data/menu.png'
    border(black, strokewidth: 8)

    # Buttons
    { open_picture:         'Open picture',
      show_or_hide_picture: ' Show/Hide  ',
      quit!:                '  Say bye!  ' }.map { |m, t|
        button(t, margin: 35) { eval m.to_s } }
  end

  # Table for puzzles
  def reload_table
    @puzzle  = nil if @puzzle
    @puzzles = nil if @puzzles
    @table.remove  if @table

    @table = stack(width:  900,
                   height: 600,
                   right:  0) do
      background rgb(0.824, 0.706, 0.549, 0.5)
      stroke white
      strokewidth 4

      # Make lines
      v, h = 100, 0
      9.times do
        line(v, 0, v, 600) if v <= 900
        line(100, h, 900, h) if h <= 600
        v += 100
        h += 100
      end
    end
    @table.click { drag_and_drop }
  end
  reload_table


############################# Methods #############################


  def open_picture
    if @picture
      return nil unless confirm('Choose new picture?')
      reload_table
    end
    return nil unless path = ask_open_file
    return warn('Unsupported image format') unless path =~ /.jpg/ # Fix this!!!
    
    @table.append { @picture = image(path,
                                     width:  800,
                                     height: 600).move(100, 0) }
    info "Took picture from #{path}"
    
    @puzzles = {}
    @puzzle  = Puzzle.new(path)
    @puzzle.split.map { |k, v| @puzzles[k] = v.base_filename }
    show_puzzles
  end

  def show_puzzles
    return open_picture unless @picture
    return nil unless @puzzle

    @puzzles.map do |k, v|
      @table.append { v = image v }
      @puzzles[k] = v
    end
    show_or_hide_picture unless @picture.hidden
  end

  def show_or_hide_picture
    return open_picture unless @picture

    if @picture.hidden
      @picture.show
      @puzzles.each_value { |p| p.hide } if @puzzles.any?
    else
      @picture.hide
      @puzzles.each_value { |p| p.show } if @puzzles.any?
    end
  end

  def drag_and_drop
    return nil unless @puzzles

    @puzzles.each_value do |p|
      p.click do
        motion do |left, top|
          # Drag a puzzle
          p.move(left - 250,
                 top  - 50) if p
          # Drop a puzzle
          @table.release { p = nil }
        end
      end
    end
  end

  def quit!
    msg = "Progress won't be saved." if @picture
    exit if confirm("Are you sure? #{msg if msg}")
  end
end
