local class = require "middleclass"


local Speed = class("Speed")

function Speed:initialize(moving_speed)
    self.moving_speed = moving_speed
end

function Speed:get()
    return self.moving_speed
end

function Speed:set(moving_speed)
    self.moving_speed = moving_speed
end

return Speed
