local class = require "middleclass"


local Actor = class("Actor")

function Actor:initialize(energy, energy_gain)
    self.turn = false
    self.energy = energy
    self.cur_energy = energy
    self.energy_gain = energy_gain
end

function Actor:get_turn()
    return self.turn
end

function Actor:set_turn(turn)
    self.turn = turn
end

function Actor:get_energy()
    return self.energy
end

function Actor:set_energy(energy)
    self.energy = energy
end

function Actor:get_energy_gain()
    return self.energy_gain
end

function Actor:set_energy_gain(gain)
    self.energy_gain = gain
end

function Actor:get_cur_energy()
    return self.cur_energy
end

function Actor:set_cur_energy(energy)
    self.cur_energy = energy
end

return Actor
