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
    
    @matches = 0
    @picture = nil if @picture
    @puzzles.clear if @puzzles
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
    formats = ['jpg', 'gif', 'png']
    ext = path.split('.').last
    return alert("Unsupported image format!\nAvaible: #{formats}") unless
                                                        formats.include?(ext)
    
    @table.append { @picture = image(path,
                                     width:  800,
                                     height: 600).move(100, 0) }
    info "Load new picture from #{path}"
    
    @puzzle  = Puzzle.new(path)
    @puzzles = {}
    puzzles  = @puzzle.split

    # Shuffle puzzles
    random = []
    puzzles.each_key { |k| random << k.to_s.to_i }
    random = random.shuffle.map { |k| k.to_s.size == 2 ? k.to_s.to_sym : "0#{k}".to_sym }

    # Show puzzles
    puzzles.size.times do |i|
      @table.append { @puzzles[random[i]] = image(puzzles[random[i]]) }
    end
    
    info 'Puzzles are ready!'
    show_or_hide_picture
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

    @puzzles.map do |position, puzzle|
      puzzle.click do
        motion do |left, top|
          puzzle.move(left - 250,
                      top  - 50) if puzzle
          @table.release do
            puzzle = nil
            puzzle_match?(position, left, top)
          end
        end
      end
    end
  end
  
  def puzzle_match?(position, left, top)
    original_top  = position.to_s[0].to_i * 100
    original_left = position.to_s[1].to_i * 100

    if ((original_left + 300)..(original_left + 400)).include?(left) &&
       (original_top..(original_top + 100)).include?(top)
      @puzzles[position].move(original_left + 100, original_top)
      #@matches == @puzzles.size - 1 ? level_complete? : @matches += 1
      if @matches == @puzzles.size - 1
        level_complete?
      else
        @matches += 1
      end
    end
  end
  
  def level_complete?
    winner = false
    @puzzles.each do |position, puzzle|
      original_top  = ((position.to_s[0].to_i * 100) - 100)..(position.to_s[0].to_i * 100)
      original_left = (position.to_s[1].to_i * 100)..((position.to_s[1].to_i * 100) + 100)
      #winner = original_left.include?(puzzle.left) &&
      #         original_top.include?(puzzle.top) ? true : false
      if original_left.include?(puzzle.left) &&
         original_top.include?(puzzle.top)
        winner = true
      else
        winner = false
      end

      break unless winner
    end

    if winner
      show_or_hide_picture
      if confirm("Congratulations! You are winner!!!\n" +
                 "Let's play with other picture?")
        reload_table
        new_picture
      end
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
