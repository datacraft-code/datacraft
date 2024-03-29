args = {...}
left = tonumber(args[1])
right = tonumber(args[2])
forward = tonumber(args[3])
depth = tonumber(args[4])

pos = position.Position:create()

function preMove()
    while turtle.detect() do
        turtle.dig()
    end
end

function dropAllBut64Fuel()
    for i=1,16 do
        local detail = turtle.getItemDetail(i) 
        local itemDetail = turtle.getItemDetail(i)
        if itemDetail and itemDetail.name ~= "mekanism:block_charcoal" then
            turtle.select(i)
            turtle.drop()
        end
    end
    util.moveItemFromEverywhere("mekanism:block_charcoal", 1)
    for i=2,16 do
        turtle.select(i)
        turtle.drop()
    end
    local coalToCollect = turtle.getItemSpace(1) 
    turtle.suckUp(coalToCollect)
    turtle.select(1)
end

function postMove()
    turtle.digUp()
    turtle.digDown()
    if util.countFreeSlots() < 3 then
        util.depositItemsEnderChestExcept("mekanism:block_charcoal")
    end
    if util.countFreeSlots() < 1 then
        error("Out of inv space")
    end
    util.tryRefuel("mekanism:block_charcoal", 500)
    -- dig.dfs("ore", true, pos)

    -- Pre-ender chest code
    -- local isBlock, blockData = turtle.inspectUp()
    -- if isBlock and blockData and not string.match(blockData.name, "chest$") then
    --     turtle.digUp()
    -- end
    -- turtle.digDown()
    -- util.tryRefuel("mekanism:block_charcoal", 500)
    -- if (turtle.getItemCount(16) > 0) then
    --     pos:savePos()
    --     pos:goToPos(0, 0, 0, 0)
    --     dropAllBut64Fuel()
    --     util.tryRefuel("mekanism:block_charcoal", 500)
    --     pos:loadPos()
    --     util.tryRefuel("mekanism:block_charcoal", 500)
    -- end
end

-- Position:coverGridAndReturn(initial_forward_dist, depth, left, right, pre, post, withdraw, deposit)
local lastDigLevel = 1
while pos.z > -(depth - 1) do
    while pos.z > lastDigLevel - 3 and pos.z > -(depth - 1) do
        turtle.digDown()
        pos:down()
    end
    turtle.digDown()
    lastDigLevel = pos.z
    pos:coverGridAndReturn(0, forward, left, right, preMove, postMove)
end
util.depositItemsEnderChestExcept("mekanism:block_charcoal")
pos:goToPos(0, 0, 0, 0)
