local class = require "middleclass"


local Cell = class("Cell")

function Cell:initialize()
    self.player = nil
    self.ball = nil
    self.aim = nil
end

function Cell:set_player(player)
    self.player = player
end

function Cell:get_player()
    return self.player
end

function Cell:delete_player()
    self.player = nil
end

function Cell:set_ball(ball)
    self.ball = ball
end

function Cell:get_ball()
    return self.ball
end

function Cell:delete_ball()
    self.ball = nil
end

function Cell:get_aim()
    return self.aim
end

function Cell:set_aim(aim)
    self.aim = aim
end

function Cell:delete_aim()
    self.aim = nil
end

return Cell
