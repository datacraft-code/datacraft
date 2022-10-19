args = {...}
left = tonumber(args[1])
forward = tonumber(args[2])

local function suckSand()
    for i=2,16 do
        turtle.select(i)
        turtle.suck(64-turtle.getItemCount(i))
    end
    turtle.select(1)
    turtle.suckUp(64-turtle.getItemCount(i))
end

local function movePre()
    util.tryRefuel("thermal:charcoal_block", 500)
    local isBlock, blockData = turtle.inspectDown()

    while not isBlock do
        if util.countInInventory("minecraft:sand") < 32 then
            print("Returning for more sand")
            pos:savePos()
            pos:goToPos(0, 0, 0, 0)
            suckSand()
            if util.countInInventory("minecraft:sand") < 32 then
                error("Couldn't get enough sand")
            end
            pos:loadPos()
        end
        local itemDetail = turtle.getItemDetail()
        if not itemDetail or itemDetail.name ~= "minecraft:sand" then
            turtle.select(findInInventory("minecraft:sand"))
        end
        turtle.placeDown()
        util.countdown(1)
        isBlock, blockData = turtle.inspectDown()
    end
end

suckSand()
print("Starting...")
pos:turnRight(2)
print("Corner 0")
pos:forceMove("forward", forward-1, movePre)
pos:turnLeft()
print("Corner 1")
pos:forceMove("forward", left, movePre)
pos:turnLeft()
print("Corner 2")
pos:forceMove("forward", forward-1, movePre)
pos:turnLeft()
print("Corner 3")
pos:forceMove("forward", left, movePre)
pos:turnRight()
print("Corner 4 - Done")
