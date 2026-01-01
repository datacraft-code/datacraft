args = {...}
up = tonumber(args[1])

pos = position.Position:create()

turtle.select(1)
util.tryRefuel("betterend:charcoal_block", 500)
pos:forceUp(up)
