local class = require "middleclass"


local MovingAction = class("MovingAction")

function MovingAction:initialize(next_x, next_y)
    self.next_x = next_x
    self.next_y = next_y
end

function MovingAction:get_next_pos()
    return self.next_x, self.next_y
end

return MovingAction
