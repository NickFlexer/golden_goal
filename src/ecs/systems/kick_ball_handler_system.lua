local class = require "middleclass"

local InputListener = require "ecs.components.input_listener"
local KickBall = require "ecs.components.kick_ball"
local MainAim = require "ecs.components.main_aim"
local AimPath = require "ecs.components.aim_path"
local ActivePlayer = require "ecs.components.active_player"
local ControllBall = require "ecs.components.control_ball"
local Aiming = require "ecs.components.aiming"
local Ball = require "ecs.components.ball"
local Focus = require "ecs.components.focus"
local Actor = require "ecs.components.actor"
local UnderControl = require "ecs.components.under_control"

local RemoveComponentEvent = require "events.remove_component_event"
local RemoveEntityEvent = require "events.remove_entity_event"
local AddComponentEvent = require "events.add_component_event"


local KickBallHandlerSystem = class("KickBallHandlerSystem", System)

function KickBallHandlerSystem:initialize(data)
    System.initialize(self)

    self.event_manager = data.event_manager
end

function KickBallHandlerSystem:update(dt)
    for _, listener_entity in pairs(self.targets.listener) do
        print("Kick!!")

        local path
        local main_aim

        for _, main_aim_entity in pairs(self.targets.main_aim) do
            path = main_aim_entity:get(MainAim.name):get_path()
            main_aim = main_aim_entity
        end

        if path then
            self.event_manager:post_event(RemoveEntityEvent(main_aim))

            for _, aim_path_entity in pairs(self.targets.aim_path) do
                self.event_manager:post_event(RemoveEntityEvent(aim_path_entity))
            end

            for _, player_entity in pairs(self.targets.player_with_ball) do
                self.event_manager:post_event(RemoveComponentEvent(player_entity, Aiming.name))
                self.event_manager:post_event(RemoveComponentEvent(player_entity, ControllBall.name))
    
                player_entity:get(Actor.name):set_turn(true)
            end
    
            for _, ball_entity in pairs(self.targets.ball) do
                self.event_manager:post_event(AddComponentEvent(ball_entity, Focus()))
                table.remove(path, 1)
                ball_entity:get(Ball.name):set_path(path)
    
                self.event_manager:post_event(RemoveComponentEvent(ball_entity, UnderControl.name))
            end
        end

        listener_entity:get(InputListener.name):set_busy(false)
        self.event_manager:post_event(RemoveComponentEvent(listener_entity, KickBall.name))
    end
end

function KickBallHandlerSystem:requires()
    return {
        listener = {InputListener.name, KickBall.name},
        main_aim = {MainAim.name},
        aim_path = {AimPath.name},
        player_with_ball = {ActivePlayer.name, ControllBall.name},
        ball = {Ball.name}
    }
end

function KickBallHandlerSystem:onAddEntity(entity)

end

function KickBallHandlerSystem:onRemoveEntity(entity)
    -- body
end

return KickBallHandlerSystem
