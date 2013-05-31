class Picture < Shoes::App
  attr_reader :path, :pictures
  attr_accessor

  def initialize
    @pictures = []
    @path = nil
  end
  
  def open
    @pictures << @path = ask_open_file
    @path
  end
end
