require 'RMagick'

class Puzzle
  attr_reader :dir
  
  def initialize(path)
    @pic = Magick::Image.read(path).first
    @all = {}
    @dir = './data/puzzles/'
    @ext = path[-4..-1] # Avaible: '.jpg', '.gif', '.png'
  end

  def split
    width, height = 800, 600
    split_width, split_height = 100, 100
    x, y = 0, 0 
    col, row = 0, 0
    prefix = '%row_%col'
    self.resize_picture(width, height)
    
    while y < 600
      while x < 800
        self.extract(x, y, split_width, split_height) do |p|
          name = prefix.gsub(/\%row/, row.to_s).gsub(/\%col/, col.to_s)
          p.write("#{@dir + name + @ext}")
          row_col = "#{col}_#{row}".to_sym
          @all[row_col] = p
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
