local class = require "middleclass"

local InputListener = require "ecs.components.input_listener"
local Wait = require "ecs.components.wait"
local ActivePlayer = require "ecs.components.active_player"
local Aiming = require "ecs.components.aiming"
local Actor = require "ecs.components.actor"

local RemoveComponentEvent = require "events.remove_component_event"


local WaitActionHandlerSystem = class("WaitActionHandlerSystem", System)

function WaitActionHandlerSystem:initialize(data)
    System.initialize(self)

    self.event_manager = data.event_manager
end

function WaitActionHandlerSystem:update(dt)
    for _, listener_entity in pairs(self.targets.listener) do
        for _, player_entity in pairs(self.targets.player) do
            if not player_entity:has(Aiming.name) then
                print("Wait!")

                player_entity:get(Actor.name):set_turn(true)
            end
        end

        listener_entity:get(InputListener.name):set_busy(false)
        self.event_manager:post_event(RemoveComponentEvent(listener_entity, Wait.name))
    end
end

function WaitActionHandlerSystem:requires()
    return {
        listener = {InputListener.name, Wait.name},
        player = {ActivePlayer.name}
    }
end

function WaitActionHandlerSystem:onAddEntity(entity)

end

function WaitActionHandlerSystem:onRemoveEntity(entity)
    -- body
end

return WaitActionHandlerSystem
