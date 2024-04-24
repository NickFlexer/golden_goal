local class = require "middleclass"


local MainAim = class("MainAim")

function MainAim:initialize()
    self.path = nil
end

function MainAim:set_path(path)
    self.path = path
end

function MainAim:get_path()
    return self.path
end

return MainAim
