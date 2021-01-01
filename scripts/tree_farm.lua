pos = position.Position:create()

function inspectTree()
    pos:turnLeft()
    exists, state = turtle.inspect()
    if state.name == "minecraft:birch_log" then
        dig.dfs("scan_only")
        plant()
    end
    pos:turnRight()
end

function plant()
    util.placeBlock("forward", "minecraft:birch_sapling")
end

function deposit()
    util.depositInChestExcept({"minecraft:birch_sapling", "mekanism:block_charcoal"})
end

function withdraw()
    turtle.suckUp(1)
end

function suck()
    turtle.suck()
    turtle.suckDown()
    util.tryRefuel("mekanism:block_charcoal")
end

function inspectTrees()
    withdraw()
    pos:forward(1, suck)
    inspectTree()
    for i=1,4 do
        pos:forward(4, suck)
        inspectTree()
    end
    pos:turnRight(1, suck)
    pos:forward(2, suck)
    pos:turnRight(1, suck)
    inspectTree()
    for i=1,4 do
        pos:forward(4, suck)
        inspectTree()
    end
    pos:forward(1, suck)
    pos:turnRight(1, suck)
    pos:forward(2, suck)
    pos:turnLeft(1, suck)
    deposit()
    pos:turnRight(2, suck)
    util.countdown(180)
end

inspectTrees()