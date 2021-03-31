args = {...}
left = tonumber(args[1])
right = tonumber(args[2])
forward = tonumber(args[3])

pos = position.Position:create()

function withdrawSandEnderChest(count)
    local sand_chest_slot = 14
    local function withdrawSand()
        turtle.select(1)
        turtle.suck(64)
    end

    util.interactWithInventoryChest(sand_chest_slot, withdrawSand)
end

function fillColumnWithSand()
    present, block = turtle.inspectDown()
    while block.name ~= 'minecraft:sand' do
        sandCount = util.countInInventory('minecraft:sand')
        if sandCount == 0 then
            withdrawSandEnderChest(64)
        end
        sandSlot = util.findInInventory('minecraft:sand')
        turtle.select(sandSlot)
        turtle.placeDown()
        present, block = turtle.inspectDown()
    end
end

function preMove()
    -- while turtle.detect() do
    --     turtle.dig()
    -- end
end

function postMove()
    if util.countFreeSlots() < 1 then
        error("Out of inv space")
    end
    util.tryRefuel("mekanism:block_charcoal", 500)
    fillColumnWithSand()
end

pos:coverGridAndReturn(0, forward, left, right, preMove, postMove)
