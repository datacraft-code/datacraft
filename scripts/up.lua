args = {...}
up = tonumber(args[1])

pos = position.Position:create()

turtle.select(1)
util.tryRefuel("quark:charcoal_block", 500)
pos:forceUp(up)
