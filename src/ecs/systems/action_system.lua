local class = require "middleclass"

local Ringer = require "ringer"

local Actor = require "ecs.components.actor"


local ActionSystem = class("ActionSystem", System)

function ActionSystem:initialize(data)
    System.initialize(self)

    self.actors = Ringer()
end

function ActionSystem:update(dt)
    if not self.actors:is_empty() then
        while true do
            local actor = self.actors:get()

            if self:_can_take_turn(actor) then
                if actor:get(Actor.name):get_turn() then
                    -- print("TURN")
                    actor:get(Actor.name):set_turn(false)
                    actor:get(Actor.name):set_cur_energy(0)

                    self.actors:next()

                    return
                else
                    return
                end
            else
                self:_gain_energy(actor)
                self.actors:next()
            end
        end
    end
end

function ActionSystem:requires()
    return {Actor.name}
end

function ActionSystem:onAddEntity(entity)
    self.actors:insert(entity)
end

function ActionSystem:onRemoveEntity(entity)
    self.actors:remove(entity)
end

function ActionSystem:_can_take_turn(entity)
    local energy = entity:get(Actor.name):get_energy()
    local cur_energy = entity:get(Actor.name):get_cur_energy()

    if cur_energy >= energy then
        return true
    end

    return false
end

function ActionSystem:_gain_energy(entity)
    local cur_energy = entity:get(Actor.name):get_cur_energy()
    local gain = entity:get(Actor.name):get_energy_gain()
    entity:get(Actor.name):set_cur_energy(cur_energy + gain)
end

return ActionSystem
