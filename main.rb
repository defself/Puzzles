#! /usr/bin/env shoes

require './puzzle.rb'

Shoes.app(width: 1024,
          height: 768,
          title: 'Puzzle Game',
          resizable: false) do
            
  # Add next puzzle
  def add
    if path = @puzz.path
      @puzzles << @puzzle = image(path,
                                  weidth: 100,
                                  height: 100)
      move
    else
      @puzzle = nil
    end
  end

  # Reorganize certain puzzle
  #def put
  #  @puzzle = @puzzles[ask('Which puzzle?').to_i - 1]
  #end

  # Move puzzle
  def move
    motion do |left, top|
      @puzzle.move(left + 1,
                   top + 1) if @puzzle
    end
  end

  # Drag each puzzle
  def drag
    @puzzles.each do |p|
      p.click do
        motion do |left, top|
          p.move(left + 1,
                 top + 1)
        end
      end
    end
  end

  @body = stack(height: 0.8) do
    background rgb(0.5, 0.5, 0.5, 0.2)

    # @puzz is initialized Puzzle object
    @puzz = Puzzle.new
    @puzzles = []
    LOCK_MSG = "Lock out all puzzles? You won't use drag and drop after this."
    
    # Menu buttons
    flow do
      button('Open picture', margin: 5) { @pic = ask_open_file }
      button('Add puzzle', margin: 5) { add }
      #button('Reorganize puzzle', margin: 5) { put }
      button('Lock', margin: 5) { @puzzles = nil if confirm(LOCK_MSG) }
      button('Exit', margin: 5) { exit if confirm('Are you sure?') }
    end
  end

  # Drop current puzzle
  @body.click { @puzzle = nil if @puzzle; drag }
end
