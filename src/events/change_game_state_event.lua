local class = require "middleclass"


local ChangeGameStateEvent = class("ChangeGameStateEvent")

function ChangeGameStateEvent:initialize(state_name)
    if not state_name then
        error("ChangeGameStateEvent:initialize no state_name!!")
    end

    self.state_name = state_name
end

function ChangeGameStateEvent:get_state_name()
    return self.state_name
end

return ChangeGameStateEvent
