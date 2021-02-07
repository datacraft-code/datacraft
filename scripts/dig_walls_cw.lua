args = {...}
forward = tonumber(args[1])
left = tonumber(args[2])
down = tonumber(args[3])

local function digWallsPre()
    if util.countFreeSlots() < 2 then
        util.depositItemsEnderChestExcept("mekanism:block_charcoal")
    end
    util.tryRefuel("mekanism:block_charcoal", 500)
    -- dig.dfs("ore", true, pos)
end

local pos = pos or position.Position:create()
for i=1,down do
    pos:forceMove("forward", forward, digWallsPre)
    pos:turnRight(1)
    pos:forceMove("forward", left, digWallsPre)
    pos:turnRight(1)
    pos:forceMove("forward", forward, digWallsPre)
    pos:turnRight(1)
    pos:forceMove("forward", left, digWallsPre)
    pos:turnRight(1)
    pos:forceMove("down", 1, digWallsPre)
end
