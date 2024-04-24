local class = require "middleclass"

local Position = require "ecs.components.position"
local Image = require "ecs.components.image"
local ActivePlayer = require "ecs.components.active_player"
local Unit = require "ecs.components.unit"
local Ball = require "ecs.components.ball"
local OnGrid = require "ecs.components.on_grid"
local Speed = require "ecs.components.speed"
local Focus = require "ecs.components.focus"
local Actor = require "ecs.components.actor"
local InputListener = require "ecs.components.input_listener"
local MainAim = require "ecs.components.main_aim"
local AimPath = require "ecs.components.aim_path"

local Tiles = require "data.enums.tiles"


local EntityFactory = class("EntityFactory")

function EntityFactory:initialize(data)
    
end

function EntityFactory:get_field_player(data)
    local pos_x, pos_y = data.x or 0, data.y or 0

    local player = Entity()
    player:initialize()

    player:add(Position({x =  pos_x, y = pos_y}))
    player:add(Image(Tiles.red_player))
    player:add(Unit())
    player:add(OnGrid())
    player:add(Speed(120))
    player:add(Actor(16, 1))

    if data.on_player_control then
        player:add(ActivePlayer())
    end

    return player
end

function EntityFactory:get_ball(x, y)
    local pos_x, pos_y = x or 0, y or 0

    local ball = Entity()
    ball:initialize()

    ball:add(Position({x =  pos_x, y = pos_y}))
    ball:add(Image(Tiles.ball))
    ball:add(Ball())
    ball:add(OnGrid())
    ball:add(Speed(180))
    ball:add(Focus())
    ball:add(Actor(16, 16))

    return ball
end

function EntityFactory:get_input_listener()
    local listener = Entity()
    listener:initialize()

    listener:add(InputListener())

    return listener
end

function EntityFactory:get_main_aim(x, y)
    local pos_x, pos_y = x or 0, y or 0

    local main_aim = Entity()
    main_aim:initialize()

    main_aim:add(Position({x =  pos_x, y = pos_y}))
    main_aim:add(Image(Tiles.aim_main))
    main_aim:add(MainAim())
    main_aim:add(Speed(160))
    main_aim:add(Focus())

    return main_aim
end

function EntityFactory:get_aim_path(x, y)
    local pos_x, pos_y = x or 0, y or 0

    local aim_path = Entity()
    aim_path:initialize()

    aim_path:add(Position({x =  pos_x, y = pos_y}))
    aim_path:add(Image(Tiles.aim_path))
    aim_path:add(AimPath())

    return aim_path
end

return EntityFactory
