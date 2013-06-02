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
    button('image_methods') { info "#{@picture.methods.sort.join("\t")}" }
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
    formats = ['.jpg', '.gif', '.png']
    return alert("Unsupported image format!\nAvaible: #{formats}") unless
                                                        formats.include?(path[-4..-1])
    
    @table.append { @picture = image(path,
                                     width:  800,
                                     height: 600).move(100, 0) }
    info "Load new picture from #{path}"
    
    @puzzle  = Puzzle.new(path)
    @puzzles = @puzzle.split
    @puzzles.each { |k, v| @table.append {
      @puzzles[k] = image(v.base_filename) } }

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
  
  def puzzle_match?(key, current_left, current_top)
    original = {}
    key.to_s.split('_').each do |position|
      position = position.to_i * 100
      original.empty? ? original[:left] = position : original[:top] = position
    end

    if ((original[:left] + 300)..(original[:left] + 400)).include?(current_left) &&
       (original[:top]..(original[:top]  + 100)).include?(current_top)
      @puzzles[key].move(original[:left] + 100, original[:top])
      @matches == @puzzles.size - 1 ? level_complete? : @matches += 1
    end
  end
  
  def level_complete?
    winner = false
    @puzzles.each do |position, puzzle|
      original = []
      position.to_s.split('_').map { |position| original << position.to_i * 100 }
      original[0] = original[0] + 100
      current = [puzzle.left, puzzle.top]
      winner  = original == current ? true : false
      info "#{winner}, #{original}, #{current}"
      break unless winner
    end
    if winner
      show_or_hide_picture
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
