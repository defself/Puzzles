require 'RMagick'

class Puzzle
  attr_reader :dir
  
  def initialize(path)
    @pic = Magick::Image.read(path).first
    @all = {}
    @dir = './data/puzzles/'
    @ext = path[-4..-1]
  end

  def split
    width, height = 800, 600
    split_width, split_height = 100, 100
    x, y = 0, 0 
    col, row = 0, 0
    self.resize_picture(width, height)
    
    @all.clear unless @all.empty?
    while y < height
      while x < width
        self.extract(x, y, split_width, split_height) do |puzzle|
          name = '%col_%row'.gsub(/\%col/, col.to_s).
                             gsub(/\%row/, row.to_s)
          puzzle.write("#{@dir + name + @ext}")
          @all[name.to_sym] = puzzle
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
