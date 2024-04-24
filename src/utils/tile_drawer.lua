local class = require "middleclass"

local TileCutter = require "tile_cutter"

local Settings = require "data.enums.settings"
local Tiles = require "data.enums.tiles"


local TileDrawer = class("TileDrawer")

function TileDrawer:initialize()
    self.drawer = TileCutter("res/tiles/Soccer01.png", Settings.tile_size)

    self.drawer:config_tileset(
        {
            {Tiles.red_player, 1, 5},
            {Tiles.ball, 1, 8},

            {Tiles.active_player_NW, 12, 1},
            {Tiles.active_player_N, 13, 1},
            {Tiles.active_player_NE, 14, 1},
            {Tiles.active_player_E, 14, 2},
            {Tiles.active_player_SE, 14, 3},
            {Tiles.active_player_S, 13, 3},
            {Tiles.active_player_SW, 12, 3},
            {Tiles.active_player_W, 12, 2},

            {Tiles.aim_main, 15, 2},
            {Tiles.aim_path, 15, 1}
        }
    )
end

function TileDrawer:draw(tile, x, y)
    self.drawer:draw(tile, x, y)
end

return TileDrawer
