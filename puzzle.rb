require 'RMagick'

class Puzzle < Shoes::App
  attr_reader :max, :picture
  attr_accessor :all

  def initialize
    @num, @max = 0, 48
    @path = './data/'
    @ext  = '.jpg'
    @all  = []
    @last = false
    @picture = nil
  end

  def add
    return nil if @last

    @num  = @num.next if @num < @max
    @last = true if @num == @max
    @path + @num.to_s + @ext
  end

  def load(path)
    @picture = Magick::Image.read(path).first
  end

  def split
    puzzle_width, puzzle_height = 100, 100
    x, y = 0, 0 
    col, row = 0, 0
    prefix = '%r_%c'

    while y < puzzle_height
      while x < puzzle_width
        split_width  = (x + 100) > puzzle_width  ? puzzle_width  - x : puzzle_width
        split_height = (y + 100) > puzzle_height ? puzzle_height - y : puzzle_height

        self.extract(x, y, split_width, split_height) do |p|
          name = prefix.gsub(/\%r/, row.to_s).gsub(/\%c/, col.to_s)
          p.write("#{@path + name + @ext}")
        end

        x += puzzle_width
        col += 1
      end

      x = 0
      y += puzzle_height
      col = 0
      row += 1
    end
  end

  def extract(x, y, w, h)
    buff = @picture.dispatch(x, y, w, h, "RGB", false)
    ni = Magick::Image.constitute(w, h, "RGB", buff)
    yield(ni)
  end

  def write(name)
    @picture.write(name)
  end
end
