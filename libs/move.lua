local function doNothing()

end

function forward(distance, pre, post)
    distance = distance or 1
    if distance < 0 then distance = 0 end
    pre = pre or doNothing
    post = post or doNothing

    covered = 0
    for i=1,distance do
        pre()
        if turtle.forward() then
            covered = covered + 1
            post(true)
        else
            post(false)
        end
    end
    return covered
end

function forceForward(distance, pre, post)
    distance = distance or 1
    if distance < 0 then distance = 0 end
    pre = pre or doNothing
    post = post or doNothing

    covered = 0
    for i=1,distance do
        pre()
        while not turtle.forward() do
            clearPath("forward")
        end
        covered = covered + 1
        post(true)
    end
    return covered
end

local function clearPath(dir)
    dir = dir or "forward"
    pre = pre or doNothing
    post = post or doNothing
    if dir == "forward" then
        while turtle.detect() do
            turtle.dig()
        end
    elseif dir == "backward" then
        turnLeft(2)
        while turtle.detect() do
            turtle.dig()
        end
        turnLeft(2)
    elseif dir == "up" then
        while turtle.detectUp() do
            turtle.digUp()
        end
    elseif dir == "down" then
        while turtle.detectDown() do
            turtle.digDown()
        end
    end
end

function forceMove(dir, distance, pre, post)
    dir = dir or "forward"

    if dir == "forward" then
        return forceForward(distance, pre, post)
    elseif dir == "backward" then
        return forceBack(distance, pre, post)
    elseif dir == "up" then
        return forceUp(distance, pre, post)
    elseif dir == "down" then
        return forceDown(distance, pre, post)
    end
end

function back(distance, pre, post)
    distance = distance or 1
    if distance < 0 then distance = 0 end
    pre = pre or doNothing
    post = post or doNothing

    covered = 0
    for i=1,distance do
        pre()
        if turtle.back() then
            covered = covered + 1
            post(true)
        else
            post(false)
        end
    end
    return covered
end

function forceBack(distance, pre, post)
    distance = distance or 1
    if distance < 0 then distance = 0 end
    pre = pre or doNothing
    post = post or doNothing

    covered = 0
    for i=1,distance do
        pre()
        while not turtle.back() do
            clearPath("back")
        end
        covered = covered + 1
        post(true)
    end
    return covered
end

function up(distance, pre, post)
    distance = distance or 1
    if distance < 0 then distance = 0 end
    pre = pre or doNothing
    post = post or doNothing

    covered = 0
    for i=1,distance do
        pre()
        if turtle.up() then
            covered = covered + 1
            post(true)
        else
            post(false)
        end
    end
    return covered
end

function forceUp(distance, pre, post)
    distance = distance or 1
    if distance < 0 then distance = 0 end
    pre = pre or doNothing
    post = post or doNothing

    covered = 0
    for i=1,distance do
        pre()
        while not turtle.up() do
            clearPath("up")
        end
        covered = covered + 1
        post(true)
    end
    return covered
end

function down(distance, pre, post)
    distance = distance or 1
    if distance < 0 then distance = 0 end
    pre = pre or doNothing
    post = post or doNothing

    covered = 0
    for i=1,distance do
        pre()
        if turtle.down() then
            covered = covered + 1
            post(true)
        else
            post(false)
        end
    end
    return covered
end

function forceDown(distance, pre, post)
    distance = distance or 1
    if distance < 0 then distance = 0 end
    pre = pre or doNothing
    post = post or doNothing

    covered = 0
    for i=1,distance do
        pre()
        while not turtle.down() do
            clearPath("down")
        end
        covered = covered + 1
        post(true)
    end
    return covered
end

function turnLeft(turns, pre, post)
    turns = turns or 1
    if turns < 0 then turns = 0 end
    pre = pre or doNothing
    post = post or doNothing

    covered = 0
    for i=1,turns do
        pre()
        if turtle.turnLeft() then
            covered = covered + 1
            post(true)
        else
            post(false)
        end
    end
    return covered
end

function turnRight(turns, pre, post)
    turns = turns or 1
    if turns < 0 then turns = 0 end
    pre = pre or doNothing
    post = post or doNothing

    covered = 0
    for i=1,turns do
        pre()
        if turtle.turnRight() then
            covered = covered + 1
            post(true)
        else
            post(false)
        end
    end
    return covered
end

--  
-- initial_forward_dist = 3
-- depth = 4, left = 2, right = 3
-- 
--  344445
--  333325
--  122225
--  110665
--    0
--    0
--    0

function coverGridAndReturn(initial_forward_dist, depth, left, right, pre, post, withdraw, deposit)
    pre = pre or doNothing
    post = post or doNothing
    withdraw = withdraw or doNothing
    deposit = deposit or doNothing
    initial_forward_dist = initial_forward_dist or 0
    local width = left + right + 1
    withdraw()
    turnRight(2)
    forward(initial_forward_dist - 1)
    if initial_forward_dist > 0 then
        forward(1, pre, post) -- Now at end of hall, facing forward
    else
        post(false)
    end

    if left > 0 then
        turnLeft()
        forward(left, pre, post)
        turnRight()
    end -- Now at front left, facing forward

    for i=1,depth-1 do
        forward(1, pre, post)
        if i%2 == 1 then
            turnRight()
            forward(width-2, pre, post)
            turnLeft()
        else
            turnLeft()
            forward(width-2, pre, post)
            turnRight()
        end
    end -- Now at back left or 1-off-right, facing forward

    turnRight()
    if (depth-1) % 2 == 0 then
        forward(width-2)
    end
    forward(1, pre, post)
    turnRight() -- Now at back right, facing backward

    forward(depth - 1, pre, post)
    if right > 0 then
        turnRight()
        forward(right-1, pre, post)
        forward(1)
        turnLeft()
    end -- Now at end of hall, facing backward
    
    forward(initial_forward_dist)
    deposit()
end