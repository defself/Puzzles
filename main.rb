#! /usr/bin/env shoes

require './puzzle.rb'

Shoes.app(width:  1000,
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
      add_puzzle:           ' Add puzzle ',
      show_or_hide_picture: ' Show/Hide  ',
      quit!:                '  Say bye!  ' }.map { |m, t|
        button(t, margin: 35) { eval m.to_s } }
  end

  # Table for puzzles
  def reload_table
    @puzzle, @puzzles = nil if @puzzle && @puzzles
    @table.remove if @table

    @table = flow(width:  800,
                  height: 600,
                  right: 0) do
      background rgb(0.824, 0.706, 0.549, 0.5)
      stroke white
      strokewidth 4

      # Make lines
      v, h = 0, 0
      9.times do
        line(v, 0, v, 600) if v <= 800
        line(0, h, 800, h) if h <= 600
        v += 100
        h += 100
      end
    end
    @table.click { drag_and_drop_puzzle }
  end
  reload_table


############################# Methods #############################


  def open_picture
    if @picture
      return nil unless confirm('Choose new picture?')
      reload_table
    end
    return nil unless path = ask_open_file
    @puzzle  = Puzzle.new
    @puzzle.load(path)
    @puzzles = @puzzle.all

    if path =~ /.jpg/ # Add check for other formats!!!
      @table.append { @picture = image(@puzzle.picture.to_s.split.first,
                                       width:  800,
                                       height: 600) }
      info "Took picture from #{path}"
    else
      warn 'Unsupported image format'
    end
  end

  def show_or_hide_picture
    return open_picture unless @picture

    if @picture.hidden
      @picture.show
      @puzzles.map { |p| p.hide } if @puzzles.any?
    else
      @picture.hide
      @puzzles.map { |p| p.show } if @puzzles.any?
    end
  end

  def add_puzzle
    return open_picture unless @picture
    return info('All puzzles are on the table') unless @puzzles.size < @puzzle.max
    return nil unless @puzzle
    show_or_hide_picture unless @picture.hidden

    path = @puzzle.add
    if path
      @table.append { (@puzzles << image(path,
                                         width:  100,
                                         height: 100)).last }
    end
  end

  def drag_and_drop_puzzle
    return nil unless @puzzles

    @puzzles.dup.each do |p|
      p.click do
        motion do |left, top|
          # Drag puzzle
          p.move(left - 250,
                 top  - 50) if p
          # Drop puzzle
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
