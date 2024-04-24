local class = require "middleclass"


local RemoveEntityEvent = class("RemoveEntityEvent")

function RemoveEntityEvent:initialize(entity)
    self.entity = entity
end

function RemoveEntityEvent:get_entity()
    return self.entity
end

return RemoveEntityEvent
