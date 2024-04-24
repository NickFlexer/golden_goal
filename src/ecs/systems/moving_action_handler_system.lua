local class = require "middleclass"

local InputListener = require "ecs.components.input_listener"
local PotentialMoving = require "ecs.components.potential_moving"
local ActivePlayer = require "ecs.components.active_player"
local OnGrid = require "ecs.components.on_grid"
local Aiming = require "ecs.components.aiming"

local RemoveComponentEvent = require "events.remove_component_event"

local CoordinatesConver = require "utils.coordinates_converter"


local MovingActionHandlerSystem = class("MovingActionHandlerSystem", System)

function MovingActionHandlerSystem:initialize(data)
    System.initialize(self)

    self.event_manager = data.event_manager

    self.converter = CoordinatesConver()
end

function MovingActionHandlerSystem:update(dt)
    for _, entity in pairs(self.targets.listener) do
        local direction = entity:get(PotentialMoving.name):get_direction()
        local dx, dy = self.converter:direction_to_position(direction)

        for _, player_entity in pairs(self.targets.active_player) do
            if player_entity:get(Aiming.name) then
                return
            end

            local cur_x, cur_y = player_entity:get(OnGrid.name):get_cur_pos()
            player_entity:get(OnGrid.name):set_next_pos(cur_x + dx, cur_y + dy)

            entity:get(InputListener.name):set_busy(false)
            self.event_manager:post_event(RemoveComponentEvent(entity, PotentialMoving.name))
        end
    end
end

function MovingActionHandlerSystem:requires()
    return {
        listener = {InputListener.name, PotentialMoving.name},
        active_player = {ActivePlayer.name}
    }
end

function MovingActionHandlerSystem:onAddEntity(entity)

end

function MovingActionHandlerSystem:onRemoveEntity(entity)
    -- body
end

return MovingActionHandlerSystem
