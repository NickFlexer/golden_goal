local class = require "middleclass"

local Vector = require "hump.vector"

local Position = require "ecs.components.position"
local MovingAction = require "ecs.components.moving_action"
local Speed = require "ecs.components.speed"

local RemoveComponentEvent = require "events.remove_component_event"


local MovingSystem = class("MovingSystem", System)

function MovingSystem:initialize(data)
    System.initialize(self)

    self.event_manager = data.event_manager
end

function MovingSystem:update(dt)
    for _, entity in pairs(self.targets) do
        local cur_x, cur_y = entity:get(Position.name):get()
        local next_x, next_y = entity:get(MovingAction.name):get_next_pos()

        local cur_pos = Vector.new(cur_x, cur_y)
        local next_pos = Vector.new(next_x, next_y)
        local dir = (next_pos - cur_pos):normalized()

        if cur_pos ~= next_pos then
            local speed = entity:get(Speed.name):get()
            local delta = next_pos - cur_pos

            if delta:len() > (dir * speed * dt):len() then
                cur_pos = cur_pos + dir * speed * dt
                entity:get(Position.name):set(cur_pos.x, cur_pos.y)
            else
                entity:get(Position.name):set(next_pos.x, next_pos.y)
                dir = Vector.new(0, 0)
            end
        else
            self.event_manager:post_event(RemoveComponentEvent(entity, MovingAction.name))
        end
    end
end

function MovingSystem:requires()
    return {MovingAction.name}
end

function MovingSystem:onAddEntity(entity)

end

function MovingSystem:onRemoveEntity(entity)
    -- body
end

return MovingSystem
