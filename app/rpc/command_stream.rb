class CommandStream
  attr_reader :on_call

  def initialize
    @on_call = Rx::Subject.new
    @buffer = ''
  end

  def push(data)
    @buffer += data
    extract
  end

  def extract
    loop do
      @buffer =~ /\n/
      src = $`

      break if src.nil?

      @on_call.on_next JSON.parse(src)
      @buffer.sub!(/^.*\n/, '')
    end
  end

  def dispose
    @on_call.on_completed
  end
end
