args = {...}
left = tonumber(args[1])
forward = tonumber(args[2])
depth = tonumber(args[3])

pos = position.Position:create()

local function placeBlockDown()
    util.tryRefuel("thermal:charcoal_block", 500)
    local itemDetail = turtle.getItemDetail()
    if not itemDetail or itemDetail.name ~= "minecraft:cobblestone" then
        local inventorySlot = util.findInInventory("minecraft:cobblestone")
        if inventorySlot == -1 then 
            error("No more blocks to place") 
        end
        turtle.select(inventorySlot)
    end
    local isBlock, blockData = turtle.inspectDown()
    while not isBlock or blockData.name == "minecraft:water" do
        turtle.placeDown()
        isBlock, blockData = turtle.inspectDown()
    end
end

local function digBlockDown()
    util.tryRefuel("thermal:charcoal_block", 500)
    turtle.select(2)
    turtle.digDown()
end

print("Starting...")
pos:turnRight()
pos:forceForward(1)
pos:turnRight()
pos:forceForward(1)
for i=1,depth do
    print("Layer "..i.." of "..depth)
    for j=1,left+1 do
        pos:forceForward(forward-1, placeBlockDown, placeBlockDown)
        pos:turnRight(2)
        pos:forceForward(forward-1, digBlockDown, digBlockDown)
        if j ~= left+1 then
            pos:turnRight(1)
            pos:forceForward(1)
            pos:turnRight(1)
        end
    end
    pos:turnLeft(1)
    pos:forceForward(left)
    pos:turnLeft(1)

    -- Fill up on fuel if neccesary
    local fuelCount = turtle.getItemCount(1)
    if fuelCount < 42 then
        turtle.select(1)
        print("Returning for more fuel")
        pos:savePos()
        pos:goToPos(0, 0, 0, 0)
        turtle.suckUp(64-turtle.getItemCount())
        pos:loadPos()
    end

    pos:forceMove("down", 1)
end
pos:goToPos(0, 0, 0, 0)