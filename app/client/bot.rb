
class Bot < Player
  def update
    move_right if @x < raid.x
    move_left if @x > raid.x
    move_down if @y < raid.y
    move_up if @y > raid.y
    attack
  end
end
