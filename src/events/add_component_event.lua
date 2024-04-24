local class = require "middleclass"


local AddComponentEvent = class("AddComponentEvent")

function AddComponentEvent:initialize(entity, component)
    self.entity = entity
    self.component = component
end

function AddComponentEvent:get_entity()
    return self.entity
end

function AddComponentEvent:get_component()
    return self.component
end

return AddComponentEvent
