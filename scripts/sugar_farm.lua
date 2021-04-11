args = {...}

pos = position.Position:create()

local function preMove()
    isBlock, block = turtle.inspect()
    if isBlock and block.name == 'minecraft:sugar_cane' then
        turtle.dig()
    end
end

local function postMove()
    util.tryRefuel('mekanism:block_charcoal', 500)
end

while true do
    pos:coverGridAndReturn(3, 25, 5, 0, preMove, postMove)
    util.depositInChest('minecraft:sugar_cane', 0, nil, 'down')
    util.countdown(600)
end
