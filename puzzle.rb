require 'RMagick'

class Puzzle
  attr_reader :dir
  
  def initialize(path)
    @pic  = Magick::Image.read(path).first
    @name = @pic.base_filename.split('.').first.split('/').last
    @dir  = './data/puzzles/'
    @ext  = path.split('.').last
    @all  = {}
    @output = {}
  end

  def split
    return @all if @all.any?

    width, height = 800, 600
    split_width, split_height = 100, 100
    x, y = 0, 0 
    col, row = 0, 0
    self.resize_picture(width, height)
    
    while y < height
      while x < width
        self.extract(x, y, split_width, split_height) do |puzzle|
          puzzle.write("#{@dir}#{@name}_#{row}#{col}.#{@ext}")
          @all["#{row}#{col}".to_sym] = puzzle.base_filename
        end
        x   += split_width
        col += 1
      end
      x    = 0
      y   += split_height
      col  = 0
      row += 1
    end
    @all
  end

  def resize_picture(w, h)
    @pic.resize!(w, h) if @pic.columns != w ||
                          @pic.rows    != h
  end

  def extract(x, y, w, h)
    buff = @pic.dispatch(x, y, w, h, 'RGB', false)
    ni   = Magick::Image.constitute(w, h, 'RGB', buff)
    yield(ni)
  end

  def write(path)
    @pic.write(path)
  end
end
