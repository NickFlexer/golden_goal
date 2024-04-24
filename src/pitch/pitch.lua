local class = require "middleclass"

local STI = require "sti"
local Grid = require "grid"

local Cell = require "pitch.cell"


local Pitch = class("Pitch")

function Pitch:initialize(data)
    self.map_data = STI(data.pitch_map)
    self.map = Grid(self.map_data.width, self.map_data.height)

    self.ball_pos_x = nil
    self.ball_pos_y = nil

    for x, y, _ in self.map:iterate() do
        self.map:set_cell(x, y, Cell())
    end
end

function Pitch:set_player(player, x, y)
    if not self.map:get_cell(x, y):get_player() then
        self.map:get_cell(x, y):set_player(player)
    else
        error("Pitch:set_pyayer() Player already exist on " .. tostring(x) .. ":" .. tostring(y))
    end
end

function Pitch:get_player_at(x, y)
    return self.map:get_cell(x, y):get_player()
end

function Pitch:remove_player(x, y)
    if self.map:get_cell(x, y):get_player() then
        self.map:get_cell(x, y):delete_player()
    else
        error("Pitch:set_pyayer() Player das not exist on " .. tostring(x) .. ":" .. tostring(y))
    end
end

function Pitch:check_player_new_position(x, y)
    if self.map:is_valid(x, y) then
        return true
    end

    return false
end

function Pitch:check_ball_new_position(x, y)
    if self.map:is_valid(x, y) then
        return true
    end

    return false
end

function Pitch:check_aim_new_position(x, y)
    if self.map:is_valid(x, y) then
        return true
    end

    return false
end

function Pitch:set_ball(ball, x, y)
    if not self.map:get_cell(x, y):get_ball() then
        self.map:get_cell(x, y):set_ball(ball)
        self.ball_pos_x, self.ball_pos_y = x, y
    else
        error("Pitch:set_pyayer() Ball already exist on " .. tostring(x) .. ":" .. tostring(y))
    end
end

function Pitch:remove_ball(x, y)
    if self.map:get_cell(x, y):get_ball() then
        self.map:get_cell(x, y):delete_ball()
        self.ball_pos_x, self.ball_pos_y = nil, nil
    else
        error("Pitch:set_pyayer() Ball das not exist on " .. tostring(x) .. ":" .. tostring(y))
    end
end

function Pitch:set_aim(aim, x, y)
    if not self.map:get_cell(x, y):get_aim() then
        self.map:get_cell(x, y):set_aim(aim)
    else
        error("Pitch:set_aim() Aim already exist on " .. tostring(x) .. ":" .. tostring(y))
    end
end

function Pitch:remove_aim(x, y)
    if self.map:get_cell(x, y):get_aim() then
        self.map:get_cell(x, y):delete_aim()
    else
        error("Pitch:remove_aim() Aim das not exist on " .. tostring(x) .. ":" .. tostring(y))
    end
end

return Pitch
