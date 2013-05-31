class Puzzle < Shoes::App
  attr_reader :max, :all, :last

  def initialize
    @num, @min, @max = 0, 0, 48
    @path = '/home/seniorihor/Code/shoes/puzzles/puzzles/'
    @ext  = '.jpg'
    @all  = []
    @last = false
  end

  def path
    if @last
      nil
    else
      "#{@path + self.next.to_s + @ext}"
    end
  end

  def add
    if path = self.path
      @all << path
      path
    else
      nil
    end
  end

  def next
    @num = @num + 1 if @num < @max
    @last = true if @num == @max
    @num
  end

  #def prev
  #  @num = @num - 1 if @num > @min
  #  @last = false if @num < @max
  #  @num
  #end
end
