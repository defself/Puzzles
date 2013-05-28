#! /usr/bin/env shoes

require './puzzle.rb'

Shoes.app(width: 1024, height: 768, title: 'Puzzle Game', resizable: false) do
  def create_puzzle
    if url = @obj.get_url
      @puzzles << @puzzle = image(url, weidth: 100, height: 100)

      motion do |left, top|
        @puzzle.move(left, top)
      end
    else
      @puzzle = nil
    end
  end

  background gray(0.7)

  @body = stack(height: 0.8) do
    background rgb(0, 100, 100, 50)
    @obj = Puzzle.new
    @puzzles = Array.new(@obj.max)

    flow do
      button('Open picture', margin: 10) { @pic = ask_open_file }
      button('Add puzzle', margin: 10) { create_puzzle }
      button('Clear', margin: 10) { @puzzles.clear if confirm('Clear all puzzles?') }
      button('Exit', margin: 10) { exit if confirm('Are you sure?') }
    end
  end

  @body.click { create_puzzle }
end
