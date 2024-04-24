local class = require "middleclass"


local Ball = class("Ball")

function Ball:initialize()
    self.path = {}
end

function Ball:get_path()
    return self.path
end

function Ball:set_path(path)
    self.path = path
end

return Ball
