args = {...}
forward = tonumber(args[1])
left = tonumber(args[2])
down = tonumber(args[3])

blockName = 'minecraft:glass'

local function withdrawBlockEnderChest(count)
    local chest_slot = 14
    local function withdrawBlock()
        turtle.select(1)
        turtle.suck(64)
    end

    util.interactWithInventoryChest(chest_slot, withdrawBlock)
end

local function placeBlockUp()
    blockCount = util.countInInventory(blockName)
    if blockCount == 0 then
        withdrawBlockEnderChest(64)
    end
    blockSlot = util.findInInventory(blockName)
    turtle.select(blockSlot)
    turtle.placeUp()
end

local function pre()
    if util.countFreeSlots() < 2 then
        util.depositItemsEnderChestExcept({"mekanism:block_charcoal", "minecraft:glass"})
    end
    util.tryRefuel("mekanism:block_charcoal", 500)
end

local function post()
    placeBlockUp()
end

local pos = pos or position.Position:create()
for i=1,down do
    pos:forceMove("forward", forward, pre, post)
    pos:turnRight(1)
    pos:forceMove("forward", left, pre, post)
    pos:turnRight(1)
    pos:forceMove("forward", forward, pre, post)
    pos:turnRight(1)
    pos:forceMove("forward", left, pre, post)
    pos:turnRight(1)
    pos:forceMove("down", 1, pre, post)
end
