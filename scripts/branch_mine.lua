args = {...}
local direction = args[1] or "right"
local length = tonumber(args[2] or 150)

if length < 7 then
    print("ERROR: Length must be >= 7")
    return
end

local pos = position.Position:create()
local branch_number = 0
while true do
    if direction == "right" then
        pos:goToPos(branch_number * 4, 0, 0, 0)
    else
        pos:goToPos(branch_number * -4, 0, 0, 0)
    end
    dig.passage(length+1, 0, pos)

    if direction == "right" then
        pos:turnRight()
    else
        pos:turnLeft()
    end
    util.placeTorch("down")
    dig.passage(4, 0, pos)
    -- dig.tunnel(1, 1, 3, 1, 4, pos)
    
    pos:turnRight(2)
    pos:forceMove("forward", 2)

    if direction == "right" then
        pos:goToPos(branch_number * 4 + 2, length + 1, 3, 2)
    else
        pos:goToPos(branch_number * -4 - 2, length + 1, 3, 2)
    end
    dig.passage(length, 3, pos)

    pos:forceMove("forward", 1)
    pos:forceMove("down", 3)
    -- if direction == "right" then
    --     pos:turnLeft()
    -- else
    --     pos:turnRight()
    -- end
    -- pos:forceMove("forward", 2)
    -- if direction == "right" then
    --     pos:turnLeft()
    -- else
    --     pos:turnRight()
    -- end
    branch_number = branch_number + 1
end