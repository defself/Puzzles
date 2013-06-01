#! /usr/bin/env shoes

require './puzzle.rb'

Shoes.app(width:     1100,
          height:    600,
          title:     'Puzzle Game',
          resizable: false) do

  # Menu
  stack(width:  200,
        height: 600,
        left:   0) do
    background './data/menu.png'
    border(black, strokewidth: 8)

    # Buttons
    button('New picture', margin: 35) { new_picture }
    button(' Show/Hide ', margin: 35) { show_or_hide_picture }
    button(' Quit game ', margin: 35) { quit! }
  end

  def cache_cleaner
    # Delete all files in the puzzles directory
    if @puzzle
      Dir.open(dir = @puzzle.dir).each do |f|
        File.delete(dir + f) if f != '.' && f != '..'
      end
      @puzzle = nil
    end
    
    @puzzles = nil if @puzzles
    @mathes  = 0
    @table.remove  if @table
  end

  # Table for puzzles
  def reload_table
    cache_cleaner

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

  def new_picture
    if @picture
      return nil unless confirm('Choose new picture? Progress will be lost.')
      reload_table
    end
    return nil unless path = ask_open_file
    return warn('Unsupported image format') unless path =~ /.jpg/ # Fix this!!!
    
    @table.append { @picture = image(path,
                                     width:  800,
                                     height: 600).move(100, 0) }
    info "Load new picture from #{path}"
    
    @puzzles = {}
    @puzzle  = Puzzle.new(path)
    @puzzle.split.map { |k, v| @puzzles[k] = v.base_filename }
    show_puzzles
  end

  def show_puzzles
    return new_picture unless @picture
    return nil unless @puzzle

    @puzzles.reverse_each do |k, v|
      @table.append  { v = image v }
      @puzzles[k] = v
    end
    show_or_hide_picture unless @picture.hidden
  end

  def show_or_hide_picture
    return new_picture unless @picture
    return nil unless @puzzles

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

    @puzzles.map do |k, v|
      v.click do
        motion do |left, top|
          # Drag a puzzle
          v.move(left - 250,
                 top  - 50) if v
          # Drop a puzzle
          @table.release do
            v = nil
            puzzle_match?(k, left, top)
          end
        end
      end
    end
  end
  
  def puzzle_match?(k, l, t)
    original = []
    k.to_s.split('_').each { |i| original << i.to_i * 100 }
    left = (original.first + 300)..(original.first + 400)
    top  = (original.last  +   0)..(original.last  + 100)
    
    if left.include?(l) && top.include?(t)
      @puzzles[k].move(original.first + 100, original.last)
      @mathes == @puzzles.count ? level_complete? : @mathes += 1
    end
  end
  
  def level_complete?
    winner = false
    @puzzles.each do |k, v|
      original, current = [], []
      k.to_s.split('_').map { |i| original << i.to_i * 100 }
      original[0] += 100
      current = [v.left, v.top]
      winner = original == current ? true : false
    end
    
    if winner
      quit! unless confirm("Congratulations! You are winner!!!\n" +
                           'Would you like continue game?')
      reload_table
    end
  end
  
  def quit!
    msg = "Progress will be lost." if @picture
    if confirm("Are you sure? #{msg if msg}")
      cache_cleaner
      exit
    end
  end
end
