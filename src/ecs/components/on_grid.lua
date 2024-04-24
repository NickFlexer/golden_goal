local class = require "middleclass"


local OnGrid = class("OnGrid")

function OnGrid:initialize()
    self.cur_pos_x = nil
    self.cur_pos_y = nil

    self.next_pos_x = nil
    self.next_pos_y = nil
end

function OnGrid:get_cur_pos()
    return self.cur_pos_x, self.cur_pos_y
end

function OnGrid:set_cur_pos(x, y)
    self.cur_pos_x = x
    self.cur_pos_y = y
end

function OnGrid:get_next_pos()
    return self.next_pos_x, self.next_pos_y
end

function OnGrid:set_next_pos(x, y)
    self.next_pos_x = x
    self.next_pos_y = y
end

return OnGrid
