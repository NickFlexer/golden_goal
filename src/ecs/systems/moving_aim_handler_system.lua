local class = require "middleclass"
local Bresenham = require "Bresenham"

local InputListener = require "ecs.components.input_listener"
local PotentialMoving = require "ecs.components.potential_moving"
local MainAim = require "ecs.components.main_aim"
local MovingAction = require "ecs.components.moving_action"
local Position = require "ecs.components.position"
local ActivePlayer = require "ecs.components.active_player"
local ControllBall = require "ecs.components.control_ball"
local OnGrid = require "ecs.components.on_grid"
local AimPath = require "ecs.components.aim_path"

local CoordinatesConver = require "utils.coordinates_converter"

local RemoveComponentEvent = require "events.remove_component_event"
local AddComponentEvent = require "events.add_component_event"
local AddNewEntityEvent = require "events.add_new_entity_event"
local RemoveEntityEvent = require "events.remove_entity_event"

local Settings = require "data.enums.settings"
local GameObjectsTypes = require "data.enums.game_objects_types"


local MovingAimHandlerSystem = class("MovingAimHandlerSystem", System)

function MovingAimHandlerSystem:initialize(data)
    System.initialize(self)

    self.event_manager = data.event_manager

    self.converter = CoordinatesConver()
end

function MovingAimHandlerSystem:update(dt)
    for _, listener_entity in pairs(self.targets.listener) do
        for _, main_aim_entity in pairs(self.targets.main_aim) do
            local direction = listener_entity:get(PotentialMoving.name):get_direction()
            local dx, dy = self.converter:direction_to_position(direction)
            local cur_x, cur_y = main_aim_entity:get(Position.name):get()

            self.event_manager:post_event(
                AddComponentEvent(main_aim_entity, MovingAction(
                    cur_x + (dx * Settings.tile_size),
                    cur_y + (dy * Settings.tile_size)
                ))
            )

            for _, aim_path_entity in pairs(self.targets.aim_path) do
                self.event_manager:post_event(RemoveEntityEvent(aim_path_entity))
            end

            local player_x, player_y
            local aim_x, aim_y = self.converter:to_pitch_pos(cur_x + dx), self.converter:to_pitch_pos(cur_y + dy)

            for _, player_entity in pairs(self.targets.player_with_ball) do
                player_x, player_y = player_entity:get(OnGrid.name):get_cur_pos()
            end

            local result = {}

            Bresenham.line(
                player_x, player_y,
                aim_x, aim_y,
                function (x, y)
                    table.insert(result, {x = x, y = y})

                    return true
                end
            )

            for _, value in ipairs(result) do
                self.event_manager:post_event(
                    AddNewEntityEvent(GameObjectsTypes.aim_path, {pos_x = value.x, pos_y = value.y})
                )
            end

            main_aim_entity:get(MainAim.name):set_path(result)

            listener_entity:get(InputListener.name):set_busy(false)
            self.event_manager:post_event(RemoveComponentEvent(listener_entity, PotentialMoving.name))
        end
    end
end

function MovingAimHandlerSystem:requires()
    return {
        listener = {InputListener.name, PotentialMoving.name},
        main_aim = {MainAim.name},
        player_with_ball = {ActivePlayer.name, ControllBall.name},
        aim_path = {AimPath.name}
    }
end

function MovingAimHandlerSystem:onAddEntity(entity)

end

function MovingAimHandlerSystem:onRemoveEntity(entity)
    -- body
end

return MovingAimHandlerSystem
