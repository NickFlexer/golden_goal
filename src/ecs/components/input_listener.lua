local class = require "middleclass"


local InputListener = class("InputListener")

function InputListener:initialize()
    self.busy = false
end

function InputListener:is_busy()
    return self.busy
end

function InputListener:set_busy(busy)
    self.busy = busy
end

return InputListener
