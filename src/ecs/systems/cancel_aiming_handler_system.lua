local class = require "middleclass"

local InputListener = require "ecs.components.input_listener"
local CancelAction = require "ecs.components.cancel_action"
local MainAim = require "ecs.components.main_aim"
local AimPath = require "ecs.components.aim_path"
local ActivePlayer = require "ecs.components.active_player"
local Aiming = require "ecs.components.aiming"
local Ball = require "ecs.components.ball"
local Focus = require "ecs.components.focus"

local RemoveComponentEvent = require "events.remove_component_event"
local RemoveEntityEvent = require "events.remove_entity_event"
local AddComponentEvent = require "events.add_component_event"


local CancelAimingHandlerSystem = class("CancelAimingHandlerSystem", System)

function CancelAimingHandlerSystem:initialize(data)
    System.initialize(self)

    self.event_manager = data.event_manager
end

function CancelAimingHandlerSystem:update(dt)
    for _, listener_entity in pairs(self.targets.listener) do
        print("cancel aiming!")

        for _, main_aim_entity in pairs(self.targets.main_aim) do
            self.event_manager:post_event(RemoveEntityEvent(main_aim_entity))
        end

        for _, aim_path_entity in pairs(self.targets.aim_path) do
            self.event_manager:post_event(RemoveEntityEvent(aim_path_entity))
        end

        for _, player_entity in pairs(self.targets.aiming_player) do
            self.event_manager:post_event(RemoveComponentEvent(player_entity, Aiming.name))
        end

        for _, ball_entity in pairs(self.targets.ball) do
            self.event_manager:post_event(AddComponentEvent(ball_entity, Focus()))
        end

        listener_entity:get(InputListener.name):set_busy(false)
        self.event_manager:post_event(RemoveComponentEvent(listener_entity, CancelAction.name))
    end
end

function CancelAimingHandlerSystem:requires()
    return {
        listener = {InputListener.name, CancelAction.name},
        main_aim = {MainAim.name},
        aim_path = {AimPath.name},
        aiming_player = {ActivePlayer.name, Aiming.name},
        ball = {Ball.name}
    }
end

function CancelAimingHandlerSystem:onAddEntity(entity)

end

function CancelAimingHandlerSystem:onRemoveEntity(entity)
    -- body
end

return CancelAimingHandlerSystem
