
class Player
  attr_reader :name
  attr_reader :x, :y

  def fellows
    @client.fellows
  end

  def raid
    @client.raid
  end

  def initialize(client, name, x, y)
    @client = client
    @name = name
    @x, @y = x, y
  end

  def setpos(x, y)
    @x, @y = x, y
  end

  def update
    # do something
  end
end

class Bot < Player
  def update
    # ここに Bot AI のコードを書こう
  end
end
