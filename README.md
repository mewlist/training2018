

## Run server

```
$ cd app/server
$ ruby main.rb
```

## Run client

```
$ cd app/client
$ ruby main.rb [server IP adedress]
```

## Control player manually

* [W] : Move Up
* [A] : Move Left
* [S] : Move Right
* [D] : Move Down
* [Space] : Attack (3x3 range)
* [Z] : Attack Buff (3x3 range)

## How to create bot

### client/bot.rb

#### move left every frame
```
class Bot < Player
  def update
    move_left
  end
end
```

#### get raid position and approach

```
class Bot < Player
  def update
    move_right if @x < raid.x
    move_left if @x > raid.x
    move_down if @y < raid.y
    move_up if @y > raid.y
  end
end
```

#### attack
```
class Bot < Player
  def update
    attack
  end
end
```

#### attack buff
```
class Bot < Player
  def update
    empower
  end
end
```
