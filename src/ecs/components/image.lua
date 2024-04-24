local class = require "middleclass"


local Image = class("Image")

function Image:initialize(tile)
    self.tile = tile
end

function Image:get_tile()
    return self.tile
end

return Image
