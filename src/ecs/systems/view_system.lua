local class = require "middleclass"

local STI = require "sti"
local Camera = require "gamera"

local TileDrawer = require "utils.tile_drawer"

local Image = require "ecs.components.image"
local Position = require "ecs.components.position"
local Unit = require "ecs.components.unit"
local Ball = require "ecs.components.ball"
local Focus = require "ecs.components.focus"
local ActivePlayer = require "ecs.components.active_player"
local MainAim = require "ecs.components.main_aim"
local AimPath = require "ecs.components.aim_path"

local Settings = require "data.enums.settings"
local Tiles = require "data.enums.tiles"


local ViewSystem = class("ViewSystem", System)

function ViewSystem:initialize(data)
    System.initialize(self)

    self.drawer = TileDrawer()

    self.pitch = STI(data.pitch_map)

    self.camera = Camera.new(0, 0, self.pitch.width * Settings.tile_size, self.pitch.height * Settings.tile_size)
    self.camera:setWindow(
        0,
        0,
        Settings.tile_size * 48,
        Settings.tile_size * 40
    )
    self.camera:setScale(1.2)
end

function ViewSystem:update(dt)
    for _, entity in pairs(self.targets.focus) do
        local x, y = entity:get(Position.name):get()
        self.camera:setPosition(x, y)
    end
end

function ViewSystem:draw()
    local function draw_all()
        self.pitch:drawLayer(self.pitch.layers["grass"])
        self.pitch:drawLayer(self.pitch.layers["lines"])
        self.pitch:drawLayer(self.pitch.layers["objects"])

        for _, entity in pairs(self.targets.units) do
            local x, y = entity:get(Position.name):get()
            local tile = entity:get(Image.name):get_tile()

            self.drawer:draw(tile, x, y)
        end

        for _, entity in pairs(self.targets.ball) do
            local x, y = entity:get(Position.name):get()
            local tile = entity:get(Image.name):get_tile()

            self.drawer:draw(tile, x, y)
        end

        for _, entity in pairs(self.targets.aim_path) do
            local x, y = entity:get(Position.name):get()
            local tile = entity:get(Image.name):get_tile()

            self.drawer:draw(tile, x, y)
        end

        for _, entity in pairs(self.targets.aim) do
            local x, y = entity:get(Position.name):get()
            local tile = entity:get(Image.name):get_tile()

            self.drawer:draw(tile, x, y)
        end

        for _, entity in pairs(self.targets.active_player) do
            local x, y = entity:get(Position.name):get()

            self:_draw_active_player_mark(x, y)
        end
    end

    self.camera:draw(draw_all)
end

function ViewSystem:requires()
    return {
        units = {Image.name, Unit.name},
        ball = {Image.name, Ball.name},
        focus = {Focus.name},
        active_player = {ActivePlayer.name},
        aim = {MainAim.name},
        aim_path = {AimPath.name}
    }
end

function ViewSystem:onAddEntity(entity)

end

function ViewSystem:onRemoveEntity(entity)
    -- body
end

function ViewSystem:_draw_active_player_mark(x, y)
    self.drawer:draw(Tiles.active_player_NW, x - Settings.tile_size, y - Settings.tile_size)
    self.drawer:draw(Tiles.active_player_N, x, y - Settings.tile_size)
    self.drawer:draw(Tiles.active_player_NE, x + Settings.tile_size, y - Settings.tile_size)
    self.drawer:draw(Tiles.active_player_E, x + Settings.tile_size, y)
    self.drawer:draw(Tiles.active_player_SE, x + Settings.tile_size, y + Settings.tile_size)
    self.drawer:draw(Tiles.active_player_S, x, y + Settings.tile_size)
    self.drawer:draw(Tiles.active_player_SW, x - Settings.tile_size, y + Settings.tile_size)
    self.drawer:draw(Tiles.active_player_W, x - Settings.tile_size, y)
end

return ViewSystem
