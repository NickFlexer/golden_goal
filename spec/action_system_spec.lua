package.path = package.path .. ";lib/?/init.lua;lib/?.lua;src/?.lua"

insulate("ActionSystem", function ()

    local lovetoys = require "lovetoys"


    lovetoys.initialize({
        globals = true,
        debug = true
    })

    _G.myglobal = true

    describe("initialize", function ()
        local ActionSystem = require "ecs.systems.action_system"

        it("instance of system", function ()
            local action_system = ActionSystem()
            assert.is.Table(action_system)
            assert.are.equal(action_system.class.name, "ActionSystem")
        end)
    end)

    describe("in lovetoys", function ()
        local ActionSystem = require "ecs.systems.action_system"
        local Actor = require "ecs.components.actor"

        local engine
        local action_system
        local actor_entity_1
        local actor_entity_2

        setup(function ()
            engine = Engine()
            action_system = ActionSystem()
            engine:addSystem(action_system, "update")

            Component.register(Actor)

            actor_entity_1 = Entity()
            actor_entity_1:initialize()
            actor_entity_1:add(Actor())

            actor_entity_2 = Entity()
            actor_entity_2:initialize()
            actor_entity_2:add(Actor())
        end)

        before_each(function ()
            actor_entity_1:get(Actor.name):set_energy(10)
            actor_entity_1:get(Actor.name):set_cur_energy(10)
            actor_entity_1:get(Actor.name):set_energy_gain(10)

            actor_entity_2:get(Actor.name):set_energy(10)
            actor_entity_2:get(Actor.name):set_cur_energy(10)
            actor_entity_2:get(Actor.name):set_energy_gain(10)
        end)

        after_each(function ()
            local entity_list = engine:getEntitiesWithComponent(Actor.name)

            for _, entity in ipairs(entity_list) do
                entity:get(Actor.name):set_turn(false)
                engine:removeEntity(entity)
            end
        end)

        it("call update without entities", function ()
            local s = spy.on(action_system, "update")

            engine:update()

            assert.spy(s).was.called(1)

            action_system.update:revert()
        end)

        it("add single entity", function ()
            engine:addEntity(actor_entity_1)

            assert.are.equal(#action_system.actors, 1)
            assert.True(action_system.actors:get() == actor_entity_1)
        end)

        it("add multiple entity", function ()
            engine:addEntity(actor_entity_1)
            engine:addEntity(actor_entity_2)

            assert.are.equal(#action_system.actors, 2)
            assert.True(action_system.actors:get() == actor_entity_1)
        end)

        it("remove entity", function ()
            engine:addEntity(actor_entity_1)
            engine:addEntity(actor_entity_2)

            engine:removeEntity(actor_entity_2)

            assert.are.equal(#action_system.actors, 1)
        end)

        it("entity can get turn", function ()
            actor_entity_1:get(Actor.name):set_turn(true)
            engine:addEntity(actor_entity_1)
            engine:update()

            assert.are.equal(actor_entity_1:get(Actor.name):get_cur_energy(), 0)
            assert.False(actor_entity_1:get(Actor.name):get_turn())
        end)

        it("first entity lost its energy", function ()
            actor_entity_1:get(Actor.name):set_energy_gain(10)
            actor_entity_2:get(Actor.name):set_energy_gain(5)
            actor_entity_1:get(Actor.name):set_turn(true)

            engine:addEntity(actor_entity_1)
            engine:addEntity(actor_entity_2)

            engine:update()

            assert.True(action_system.actors:get() == actor_entity_2)
            assert.are.equal(actor_entity_1:get(Actor.name):get_cur_energy(), 0)
            assert.are.equal(actor_entity_2:get(Actor.name):get_cur_energy(), 10)
        end)
    end)
end)
