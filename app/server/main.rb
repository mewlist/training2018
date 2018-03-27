require 'rx'
require_relative "./server.rb"
require_relative "./player.rb"
require_relative "./raid_boss.rb"

class GameState
  def start
  end

  def update
    p 'game state update'
  end

  def execute(command)
    command.Invoke
  end

  def end
  end
end

Server.run
