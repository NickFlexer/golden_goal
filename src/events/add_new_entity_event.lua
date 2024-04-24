local class = require "middleclass"


local AddNewEntityEvent = class("AddNewEntityEvent")

function AddNewEntityEvent:initialize(entity_type, data)
    self.entity_type = entity_type
    self.data = data
end

function AddNewEntityEvent:get_entity_type()
    return self.entity_type
end

function AddNewEntityEvent:get_data()
    return self.data
end

return AddNewEntityEvent
