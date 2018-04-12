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

  def move_left
    @client.send_data Move.new(@x-1, @y)
  end

  def move_right
    @client.send_data Move.new(@x+1, @y)
  end

  def move_up
    @client.send_data Move.new(@x, @y-1)
  end

  def move_down
    @client.send_data Move.new(@x, @y+1)
  end

  def attack
    @client.send_data Attack.new(@x, @y)
  end
end

