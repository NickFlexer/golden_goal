local class = require "middleclass"


local PotentialMoving = class("PotentialMoving")

function PotentialMoving:initialize(direction)
    self.direction = direction
end

function PotentialMoving:get_direction()
    return self.direction
end

return PotentialMoving
