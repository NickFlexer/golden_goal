local class = require "middleclass"

local FSM = require "fsm"
local EventManager = require "event_manager"

local GameplayState = require "game.states.gameplay"

local ChangeGameStateEvent = require "events.change_game_state_event"

local GameStates = require "data.enums.game_states"


local Game = class("Game")

function Game:initialize()
    self.event_manager = EventManager()
    self.fsm = FSM(self)
    self.states_queue = {}

    self.states = {
        gameplay = GameplayState({event_manager = self.event_manager})
    }

    self.event_manager:add_listener(
        ChangeGameStateEvent.name,
        self,
        self._handle_events
    )

    self.event_manager:post_event(ChangeGameStateEvent(GameStates.gameplay_state))
end

function Game:update(dt)
    self.fsm:update(dt)

    if #self.states_queue > 0 then
        self:_change_states()
    end
end

function Game:draw()
    if self.fsm:get_current_state() then
        self.fsm:get_current_state():draw()
    end
end

function Game:_handle_events(event)
    if event.class.name == ChangeGameStateEvent.name then
        if event:get_state_name() == GameStates.gameplay_state then
            table.insert(self.states_queue, self.states.gameplay)
        end
    end
end

function Game:_change_states()
    for _, state in ipairs(self.states_queue) do
        self.fsm:set_current_state(state)
    end

    self.states_queue = {}
end

return Game
