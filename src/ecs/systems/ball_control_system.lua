local class = require "middleclass"

local Ball = require "ecs.components.ball"
local OnGrid = require "ecs.components.on_grid"
local Position = require "ecs.components.position"
local UnderControl = require "ecs.components.under_control"
local Unit = require "ecs.components.unit"
local ControllBall = require "ecs.components.control_ball"

local AddComponentEvent = require "events.add_component_event"

local CoordinatesConver = require "utils.coordinates_converter"


local BallControlSystem = class("BallControlSystem", System)

function BallControlSystem:initialize(data)
    System.initialize(self)

    self.pitch = data.pitch
    self.event_manager = data.event_manager

    self.converter = CoordinatesConver()
end

function BallControlSystem:update(dt)
    for _, entity in pairs(self.targets.ball) do
        if not entity:has(UnderControl.name) then
            for _, player_entity in pairs(self.targets.players) do
                local ball_x, ball_y = entity:get(OnGrid.name):get_cur_pos()
                local player_x, player_y = player_entity:get(OnGrid.name):get_cur_pos()

                if ball_x == player_x and ball_y == player_y then
                    print("Ball under control!")
                    self.event_manager:post_event(AddComponentEvent(entity, UnderControl()))
                    self.event_manager:post_event(AddComponentEvent(player_entity, ControllBall()))
                end
            end
        end
    end
end

function BallControlSystem:requires()
    return {ball = {Ball.name}, players = {Unit.name}}
end

function BallControlSystem:onAddEntity(entity, group)
    if group == "ball" then
        local pos_x, pos_y = entity:get(Position.name):get()
        self.pitch:set_ball(entity, self.converter:to_pitch_pos(pos_x), self.converter:to_pitch_pos(pos_y))
        entity:get(OnGrid.name):set_cur_pos(self.converter:to_pitch_pos(pos_x), self.converter:to_pitch_pos(pos_y))
    end
end

function BallControlSystem:onRemoveEntity(entity, group)
    -- body
end

return BallControlSystem
