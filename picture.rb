class Picture < Shoes::App
  attr_reader :path, :pictures

  def initialize
    @pictures = []
    @path = nil
  end
  
  def open
    @pictures << @path = ask_open_file
  end
end
