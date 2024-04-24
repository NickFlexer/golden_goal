---
-- ringer.lua


local Ringer = {}

Ringer.__index = Ringer


local function new(data)
    if data and type(data) ~= "table" then
        error("Ringer(): data need to be table type")
    end

    return setmetatable(
        {
            buffer = data or {},
            current_index = 1
        },
        Ringer
    )
end

function Ringer.__len(self)
    return #self.buffer
end

function Ringer.__tostring(self)
    local result_table = {}

    for _, value in pairs(self.buffer) do
        table.insert(result_table, tostring(value))
    end

    return "[" .. table.concat(result_table, ", ") .. "]"
end

function Ringer:insert(item)
    table.insert(self.buffer, item)
end

function Ringer:remove(item)
    for index, cur_item in pairs(self.buffer) do
        if item == cur_item then
            table.remove(self.buffer, index)

            return
        end
    end

    error("remove(): item '" .. tostring(item) .. "' not available")
end

function Ringer:is_exist(item)
    for _, cur_item in pairs(self.buffer) do
        if item == cur_item then
            return true
        end
    end

    return false
end

function Ringer:get()
    if #self.buffer == 0 then
        error("get(): buffer is empty!")
    end

    if self.current_index > #self.buffer then
        self.current_index = 1
    end

    return self.buffer[self.current_index]
end

function Ringer:next()
    if #self.buffer == 0 then
        error("next(): buffer is empty!")
    end

    local result = self.buffer[self.current_index]

    self.current_index = self.current_index + 1

    if self.current_index > #self.buffer then
        self.current_index = 1
    end

    return result
end

function Ringer:is_empty()
    return not next(self.buffer)
end

-- return setmetatable(Ringer, {__call = Ringer.new})

return setmetatable(
    {
        new = new,
        _DESCRIPTION = "Lua implementation of ring buffer"
    },
    {
        __call = function(_, ...) return new(...) end
    }
)
