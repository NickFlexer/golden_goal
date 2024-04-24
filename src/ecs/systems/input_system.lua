local class = require "middleclass"

local Input = require "Input"

local InputListener = require "ecs.components.input_listener"
local PotentialMoving = require "ecs.components.potential_moving"
local PotentialKick = require "ecs.components.potential_kick"
local KickBall = require "ecs.components.kick_ball"
local CancelAction = require "ecs.components.cancel_action"
local Wait = require "ecs.components.wait"

local AddComponentEvent = require "events.add_component_event"

local Directions = require "data.enums.directions"


local InputSystem = class("InputSystem", System)

function InputSystem:initialize(data)
    System.initialize(self)

    self.event_manager = data.event_manager

    self.input = Input()

    self.input:bind("w", "up")
    self.input:bind("s", "down")
    self.input:bind("d", "right")
    self.input:bind("a", "left")
    self.input:bind("e", "action")
    self.input:bind("return", "kick")
    self.input:bind("escape", "cancel")
    self.input:bind("space", "wait")

    self.interval = 0.4
end

function InputSystem:update(dt)
    for _, entity in pairs(self.targets) do
        if not entity:get(InputListener.name):is_busy() then
            if self.input:down("up", self.interval) then
                self.event_manager:post_event(AddComponentEvent(entity, PotentialMoving(Directions.up)))
                entity:get(InputListener.name):set_busy(true)
            elseif self.input:down("down", self.interval) then
                self.event_manager:post_event(AddComponentEvent(entity, PotentialMoving(Directions.down)))
                entity:get(InputListener.name):set_busy(true)
            elseif self.input:down("right", self.interval) then
                self.event_manager:post_event(AddComponentEvent(entity, PotentialMoving(Directions.right)))
                entity:get(InputListener.name):set_busy(true)
            elseif self.input:down("left", self.interval) then
                self.event_manager:post_event(AddComponentEvent(entity, PotentialMoving(Directions.left)))
                entity:get(InputListener.name):set_busy(true)
            elseif self.input:down("action", self.interval) then
                self.event_manager:post_event(AddComponentEvent(entity, PotentialKick()))
                entity:get(InputListener.name):set_busy(true)
            elseif self.input:down("kick", self.interval) then
                self.event_manager:post_event(AddComponentEvent(entity, KickBall()))
                entity:get(InputListener.name):set_busy(true)
            elseif self.input:down("cancel", self.interval) then
                self.event_manager:post_event(AddComponentEvent(entity, CancelAction()))
                entity:get(InputListener.name):set_busy(true)
            elseif self.input:down("wait", self.interval) then
                self.event_manager:post_event(AddComponentEvent(entity, Wait()))
                entity:get(InputListener.name):set_busy(true)
            end
        end
    end
end

function InputSystem:requires()
    return {InputListener.name}
end

function InputSystem:onAddEntity(entity)

end

function InputSystem:onRemoveEntity(entity)
    -- body
end

return InputSystem
