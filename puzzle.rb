class Puzzle
  attr_reader :max

  def initialize
    @url = '/home/seniorihor/Code/shoes/puzzles/pictures/'
    @min = 0
    @max = 6
    @num = @min
    @ext = '.jpg'
    @last = false
  end

  def next
    @num = @num + 1 if @num < @max
    @last = true if @num == @max
    @num
  end

  def prev
    @num = @num - 1 if @num > @min
    @last = false if @num < @max
    @num
  end

  def get_url
    if @last
      nil
    else
      "#{@url}#{self.next}#{@ext}"
    end
  end
end
