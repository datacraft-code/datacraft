args = {...}

for i=1,5 do
    for j = 1,20 do
        turtle.turnRight()
        blockSlot = util.findInInventory('minecraft:prismarine_stairs')
        turtle.select(blockSlot)
        turtle.place()
        turtle.turnRight()
        turtle.turnRight()
        blockSlot = util.findInInventory('minecraft:prismarine_stairs')
        turtle.select(blockSlot)
        turtle.placeDown()
        turtle.turnRight()
        turtle.forward()
    end
    turtle.up()
    turtle.up()
    turtle.turnRight()
    turtle.turnRight()
    for j = 1,20 do
        turtle.turnLeft()
        blockSlot = util.findInInventory('minecraft:prismarine_stairs')
        turtle.select(blockSlot)
        turtle.place()
        turtle.turnLeft()
        turtle.turnLeft()
        blockSlot = util.findInInventory('minecraft:prismarine_stairs')
        turtle.select(blockSlot)
        turtle.placeDown()
        turtle.turnLeft()
        turtle.forward()
    end
    turtle.up()
    turtle.up()
    turtle.turnRight()
    turtle.turnRight()
end