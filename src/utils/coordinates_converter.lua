local class = require "middleclass"

local Settings = require "data.enums.settings"
local Directions = require "data.enums.directions"


local CoordinatesConver = class("CoordinatesConver")

function CoordinatesConver:initialize()
    
end

function CoordinatesConver:to_pitch_pos(world_pos)
    return math.floor(world_pos / Settings.tile_size) + 1
end

function CoordinatesConver:to_world_pos(pitch_pos)
    return (pitch_pos - 1) * Settings.tile_size
end

function CoordinatesConver:direction_to_position(direction)
    if direction == Directions.up then
        return 0, -1
    elseif direction == Directions.down then
        return 0, 1
    elseif direction == Directions.left then
        return -1, 0
    elseif direction == Directions.right then
        return 1, 0
    end
end

return CoordinatesConver
