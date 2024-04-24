local class = require "middleclass"

local InputListener = require "ecs.components.input_listener"
local PotentialKick = require "ecs.components.potential_kick"
local ActivePlayer = require "ecs.components.active_player"
local ControllBall = require "ecs.components.control_ball"
local OnGrid = require "ecs.components.on_grid"
local Ball = require "ecs.components.ball"
local Focus = require "ecs.components.focus"
local Aiming = require "ecs.components.aiming"

local AddComponentEvent = require "events.add_component_event"
local RemoveComponentEvent = require "events.remove_component_event"
local AddNewEntityEvent = require "events.add_new_entity_event"

local GameObjectsTypes = require "data.enums.game_objects_types"


local BallAimingHandlerSystem = class("BallAimingHandlerSystem", System)

function BallAimingHandlerSystem:initialize(data)
    System.initialize(self)

    self.event_manager = data.event_manager
end

function BallAimingHandlerSystem:update(dt)
    for _, entity in pairs(self.targets.listener) do
        for _, player_entity in pairs(self.targets.player_with_ball) do
            if player_entity:has(Aiming.name) then
                break
            end

            print("Aiming!")
            local x, y = player_entity:get(OnGrid.name):get_cur_pos()
            self.event_manager:post_event(AddNewEntityEvent(GameObjectsTypes.main_aim, {pos_x = x, pos_y = y}))
            self.event_manager:post_event(AddComponentEvent(player_entity, Aiming()))

            for _, ball_entity in pairs(self.targets.ball) do
                self.event_manager:post_event(RemoveComponentEvent(ball_entity, Focus.name))
            end
        end

        entity:get(InputListener.name):set_busy(false)
        self.event_manager:post_event(RemoveComponentEvent(entity, PotentialKick.name))
    end
end

function BallAimingHandlerSystem:requires()
    return {
        listener = {InputListener.name, PotentialKick.name},
        player_with_ball = {ActivePlayer.name, ControllBall.name},
        ball = {Ball.name}
    }
end

function BallAimingHandlerSystem:onAddEntity(entity)

end

function BallAimingHandlerSystem:onRemoveEntity(entity)
    -- body
end

return BallAimingHandlerSystem
