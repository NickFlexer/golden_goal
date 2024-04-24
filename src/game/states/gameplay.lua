local class = require "middleclass"

local ViewSystem = require "ecs.systems.view_system"
local InputSystem = require "ecs.systems.input_system"
local MovingSystem = require "ecs.systems.moving_system"
local PitchControlSystem = require "ecs.systems.pitch_control_system"
local BallControlSystem = require "ecs.systems.ball_control_system"
local ActionSystem = require "ecs.systems.action_system"
local MovingActionHandlerSystem = require "ecs.systems.moving_action_handler_system"
local BallAimingHandlerSystem = require "ecs.systems.ball_aiming_handler_system"
local MovingAimHandlerSystem = require "ecs.systems.moving_aim_handler_system"
local KickBallHandlerSystem = require "src.ecs.systems.kick_ball_handler_system"
local BallMovingSystem = require "ecs.systems.ball_moving_system"
local CancelAimingHandlerSystem = require "ecs.systems.cancel_aiming_handler_system"
local WaitActionHandlerSystem = require "ecs.systems.wait_action_handler_system"

local EntityFactory = require "factories.entity_factory"

local AddNewEntityEvent = require "events.add_new_entity_event"
local AddComponentEvent = require "events.add_component_event"
local RemoveComponentEvent = require "events.remove_component_event"
local RemoveEntityEvent = require "events.remove_entity_event"

local Position = require "ecs.components.position"
local Image = require "ecs.components.image"
local ActivePlayer = require "ecs.components.active_player"
local MovingAction = require "ecs.components.moving_action"
local Unit = require "ecs.components.unit"
local Ball = require "ecs.components.ball"
local OnGrid = require "ecs.components.on_grid"
local Speed = require "ecs.components.speed"
local Focus = require "ecs.components.focus"
local Actor = require "ecs.components.actor"
local InputListener = require "ecs.components.input_listener"
local PotentialMoving = require "ecs.components.potential_moving"
local UnderControl = require "ecs.components.under_control"
local ControllBall = require "ecs.components.control_ball"
local PotentialKick = require "ecs.components.potential_kick"
local MainAim = require "ecs.components.main_aim"
local AimPath = require "ecs.components.aim_path"
local Aiming = require "ecs.components.aiming"
local KickBall = require "ecs.components.kick_ball"
local CancelAction = require "ecs.components.cancel_action"
local Wait = require "ecs.components.wait"

local GameObjectsTypes = require "data.enums.game_objects_types"

local Pitch = require "pitch.pitch"

local CoordinatesConver = require "utils.coordinates_converter"


local GameplayState = class("GameplayState")

function GameplayState:initialize(data)
    self.event_manager = data.event_manager

    local pitch_map_path = "res/map/pitch.lua"

    self.pitch = Pitch({pitch_map = pitch_map_path})
    self.converter = CoordinatesConver()

    self.view_system = ViewSystem({pitch_map = pitch_map_path})

    self.engine = Engine()

    self.engine:addSystem(InputSystem({event_manager = self.event_manager}), "update")
    self.engine:addSystem(MovingActionHandlerSystem({event_manager = self.event_manager}), "update")
    self.engine:addSystem(MovingAimHandlerSystem({event_manager = self.event_manager}), "update")
    self.engine:addSystem(BallAimingHandlerSystem({event_manager = self.event_manager}), "update")
    self.engine:addSystem(KickBallHandlerSystem({event_manager = self.event_manager}), "update")
    self.engine:addSystem(CancelAimingHandlerSystem({event_manager = self.event_manager}), "update")
    self.engine:addSystem(WaitActionHandlerSystem({event_manager = self.event_manager}), "update")
    self.engine:addSystem(MovingSystem({event_manager = self.event_manager}), "update")
    self.engine:addSystem(ActionSystem(), "update")
    self.engine:addSystem(BallMovingSystem(), "update")
    self.engine:addSystem(PitchControlSystem({pitch = self.pitch, event_manager = self.event_manager}), "update")
    self.engine:addSystem(BallControlSystem({pitch = self.pitch, event_manager = self.event_manager}), "update")
    self.engine:addSystem(self.view_system, "update")

    self.engine:addSystem(self.view_system, "draw")

    self.event_manager:add_listener(AddNewEntityEvent.name, self, self._handle_events)
    self.event_manager:add_listener(AddComponentEvent.name, self, self._handle_events)
    self.event_manager:add_listener(RemoveComponentEvent.name, self, self._handle_events)
    self.event_manager:add_listener(RemoveEntityEvent.name, self, self._handle_events)

    self.entity_factory = EntityFactory()

    self.entities_to_add = {}
    self.entities_to_remove = {}
    self.componets_to_add = {}
    self.componets_to_remove = {}
end

function GameplayState:enter(owner)
    print("GameplayState:enter")

    self.event_manager:post_event(AddNewEntityEvent(GameObjectsTypes.input_listener))
    self.event_manager:post_event(AddNewEntityEvent(GameObjectsTypes.ball, {pos_x = 38, pos_y = 63}))

    self.event_manager:post_event(
        AddNewEntityEvent(
            GameObjectsTypes.field_player,
            {
                pos_x = 36, pos_y = 56,
                on_player_control = true
            }
        )
    )
end

function GameplayState:execute(owner, dt)
    self.engine:update(dt)

    self:_add_new_entities()
    self:_add_components()
    self:_remove_components()
    self:_remove_entities()
end

function GameplayState:draw()
    self.engine:draw()
end

function GameplayState:exit(owner)
    -- do staff...
end

function GameplayState:_handle_events(event)
    if event.class.name == AddNewEntityEvent.name then
        local type = event:get_entity_type()
        local data = event:get_data()

        if type == GameObjectsTypes.field_player then
            local entity = self.entity_factory:get_field_player(
                {
                    x = self.converter:to_world_pos(data.pos_x),
                    y = self.converter:to_world_pos(data.pos_y),
                    on_player_control = data.on_player_control
                }
            )
            table.insert(self.entities_to_add, entity)
        end

        if type == GameObjectsTypes.ball then
            local entity = self.entity_factory:get_ball(
                self.converter:to_world_pos(data.pos_x),
                self.converter:to_world_pos(data.pos_y)
            )
            table.insert(self.entities_to_add, entity)
        end

        if type == GameObjectsTypes.input_listener then
            local entity = self.entity_factory:get_input_listener()
            table.insert(self.entities_to_add, entity)
        end

        if type == GameObjectsTypes.main_aim then
            local entity = self.entity_factory:get_main_aim(
                self.converter:to_world_pos(data.pos_x),
                self.converter:to_world_pos(data.pos_y)
            )
            table.insert(self.entities_to_add, entity)
        end

        if type == GameObjectsTypes.aim_path then
            local entity = self.entity_factory:get_aim_path(
                self.converter:to_world_pos(data.pos_x),
                self.converter:to_world_pos(data.pos_y)
            )
            table.insert(self.entities_to_add, entity)
        end
    elseif event.class.name == AddComponentEvent.name then
        table.insert(
            self.componets_to_add,
            {entity = event:get_entity(), component = event:get_component()}
        )
    elseif event.class.name == RemoveComponentEvent.name then
        table.insert(
            self.componets_to_remove,
            {entity = event:get_entity(), component_name = event:get_component_name()}
        )
    elseif event.class.name == RemoveEntityEvent.name then
        table.insert(
            self.entities_to_remove,
            event:get_entity()
        )
    end
end

function GameplayState:_add_new_entities()
    if #self.entities_to_add == 0 then
        return
    end

    for _, entity in ipairs(self.entities_to_add) do
        self.engine:addEntity(entity)
    end

    self.entities_to_add = {}
end

function GameplayState:_add_components()
    if #self.componets_to_add == 0 then
        return
    end

    for _, data in ipairs(self.componets_to_add) do
        if data.entity:has(data.component.class.name) then
            data.entity:remove(data.component.class.name)
        end

        data.entity:add(data.component)
    end

    self.componets_to_add = {}
end

function GameplayState:_remove_components()
    if #self.componets_to_remove == 0 then
        return
    end

    for _, data in ipairs(self.componets_to_remove) do
        data.entity:remove(data.component_name)
    end

    self.componets_to_remove = {}
end

function GameplayState:_remove_entities()
    if #self.entities_to_remove == 0 then
        return
    end

    for _, entity in ipairs(self.entities_to_remove) do
        self.engine:removeEntity(entity)
    end

    self.entities_to_remove = {}
end

function GameplayState:_register_components()
    Component.register(Position)
    Component.register(Image)
    Component.register(ActivePlayer)
    Component.register(MovingAction)
    Component.register(Unit)
    Component.register(Ball)
    Component.register(OnGrid)
    Component.register(Speed)
    Component.register(Focus)
    Component.register(Actor)
    Component.register(InputListener)
    Component.register(PotentialMoving)
    Component.register(UnderControl)
    Component.register(ControllBall)
    Component.register(PotentialKick)
    Component.register(MainAim)
    Component.register(AimPath)
    Component.register(Aiming)
    Component.register(KickBall)
    Component.register(CancelAction)
    Component.register(Wait)
end

return GameplayState
