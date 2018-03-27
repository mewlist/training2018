
class AttackEffect
  attr_reader :x
  attr_reader :y
  attr_reader :t
  attr_reader :disposed

  def initialize(x, y)
    @t = 0
    @x, @y = x, y
    @disposed = false
  end

  def update
    return if @disposed
    @t += 1
    dispose if @t >= 10
  end

  def dispose
    @disposed = true
  end
end

