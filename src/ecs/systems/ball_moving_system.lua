local class = require "middleclass"

local Ball = require "ecs.components.ball"
local Actor = require "ecs.components.actor"
local OnGrid = require "ecs.components.on_grid"


local BallMovingSystem = class("BallMovingSystem", System)

function BallMovingSystem:initialize(data)
    System.initialize(self)
end

function BallMovingSystem:update(dt)
    for _, entity in pairs(self.targets) do
        if entity:has(Actor.name) then
            if not entity:get(Actor.name):get_turn() then
                local path = entity:get(Ball.name):get_path()

                if #path > 0 then
                    entity:get(OnGrid.name):set_next_pos(path[1].x, path[1].y)
                    table.remove(path, 1)
                end

                entity:get(Actor.name):set_turn(true)
            end
        end
    end
end

function BallMovingSystem:requires()
    return {Ball.name}
end

function BallMovingSystem:onAddEntity(entity)

end

function BallMovingSystem:onRemoveEntity(entity)
    -- body
end

return BallMovingSystem
