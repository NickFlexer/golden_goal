local class = require "middleclass"


local RemoveComponentEvent = class("RemoveComponentEvent")

function RemoveComponentEvent:initialize(entity, component_name)
    self.entity = entity
    self.component_name = component_name
end

function RemoveComponentEvent:get_entity()
    return self.entity
end

function RemoveComponentEvent:get_component_name()
    return self.component_name
end

return RemoveComponentEvent
