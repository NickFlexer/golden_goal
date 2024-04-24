local class = require "middleclass"

local OnGrid = require "ecs.components.on_grid"
local Unit = require "ecs.components.unit"
local Position = require "ecs.components.position"
local MovingAction = require "ecs.components.moving_action"
local Actor = require "ecs.components.actor"
local ControllBall = require "ecs.components.control_ball"
local Ball = require "ecs.components.ball"

local CoordinatesConver = require "utils.coordinates_converter"

local AddComponentEvent = require "events.add_component_event"


local PitchControlSystem = class("PitchControlSystem", System)

function PitchControlSystem:initialize(data)
    System.initialize(self)

    self.pitch = data.pitch
    self.event_manager = data.event_manager

    self.converter = CoordinatesConver()
end

function PitchControlSystem:update(dt)
    for _, entity in pairs(self.targets.all) do
        local next_x, next_y = entity:get(OnGrid.name):get_next_pos()

        if next_x and next_y then
            if self:_needs_moving(entity) then
                local cur_x, cur_y = entity:get(OnGrid.name):get_cur_pos()

                if entity:has(Unit.name) then
                    if self.pitch:check_player_new_position(next_x, next_y) then
                        self.pitch:remove_player(cur_x, cur_y)
                        self.pitch:set_player(entity, next_x, next_y)

                        entity:get(OnGrid.name):set_cur_pos(next_x, next_y)
                        entity:get(OnGrid.name):set_next_pos(nil, nil)

                        entity:get(Actor.name):set_turn(true)

                        self.event_manager:post_event(
                            AddComponentEvent(entity, MovingAction(
                                self.converter:to_world_pos(next_x),
                                self.converter:to_world_pos(next_y)
                            ))
                        )

                        if entity:has(ControllBall.name) then
                            for _, ball_entity in pairs(self.targets.ball) do
                                ball_entity:get(OnGrid.name):set_next_pos(next_x, next_y)
                            end
                        end
                    end
                end

                if entity:has(Ball.name) then
                    if self.pitch:check_ball_new_position(next_x, next_y) then
                        self.pitch:remove_ball(cur_x, cur_y)
                        self.pitch:set_ball(entity, next_x, next_y)

                        entity:get(OnGrid.name):set_cur_pos(next_x, next_y)
                        entity:get(OnGrid.name):set_next_pos(nil, nil)

                        self.event_manager:post_event(
                            AddComponentEvent(entity, MovingAction(
                                self.converter:to_world_pos(next_x),
                                self.converter:to_world_pos(next_y)
                            ))
                        )
                    end
                end
            end
        end
    end
end

function PitchControlSystem:requires()
    return {all = {OnGrid.name}, ball = {Ball.name}}
end

function PitchControlSystem:onAddEntity(entity, group)
    if entity:has(Unit.name) then
        local pos_x, pos_y = entity:get(Position.name):get()
        self.pitch:set_player(entity, self.converter:to_pitch_pos(pos_x), self.converter:to_pitch_pos(pos_y))
        entity:get(OnGrid.name):set_cur_pos(self.converter:to_pitch_pos(pos_x), self.converter:to_pitch_pos(pos_y))
    end
end

function PitchControlSystem:onRemoveEntity(entity)
    -- body
end

function PitchControlSystem:_needs_moving(entity)
    local cur_x, cur_y = entity:get(OnGrid.name):get_cur_pos()
    local next_x, next_y = entity:get(OnGrid.name):get_next_pos()

    if next_x and next_y then
        if next_x ~= cur_x or next_y ~= cur_y then
            return true
        end
    end

    return false
end

return PitchControlSystem
