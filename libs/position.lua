Position = {}
Position.__index = Position

local function doNothing()

end

function Position:create()
    local pos = {}
    setmetatable(pos, Position)
    pos.x = 0
    pos.y = 0
    pos.z = 0
    pos.dir = 0 -- 0 is forward, 1 is right, 2 is back, 3 is left
    pos.x_store = 0
    pos.y_store = 0
    pos.z_store = 0
    pos.dir_store = 0
    return pos
end

function Position:forward(distance, pre, post)
    post = post or doNothing
    function newPost(success)
        if success then
            if self.dir == 0 then
                self.y = self.y + 1
            elseif self.dir == 1 then
                self.x = self.x + 1
            elseif self.dir == 2 then
                self.y = self.y - 1
            elseif self.dir == 3 then
                self.x = self.x - 1
            end
        end
        post()
    end
    local covered = move.forward(distance, pre, newPost)
    return covered
end

function Position:forceForward(distance, pre, post)
    post = post or doNothing
    function newPost(success)
        if success then
            if self.dir == 0 then
                self.y = self.y + 1
            elseif self.dir == 1 then
                self.x = self.x + 1
            elseif self.dir == 2 then
                self.y = self.y - 1
            elseif self.dir == 3 then
                self.x = self.x - 1
            end
        end
        post()
    end
    local covered = move.forceForward(distance, pre, newPost)
    return covered
end

function Position:back(distance, pre, post)
    post = post or doNothing
    function newPost(success)
        if success then
            if self.dir == 0 then
                self.y = self.y - 1
            elseif self.dir == 1 then
                self.x = self.x - 1
            elseif self.dir == 2 then
                self.y = self.y + 1
            elseif self.dir == 3 then
                self.x = self.x + 1
            end
        end
        post()
    end
    local covered = move.back(distance, pre, newPost)
    return covered
end

function Position:forceBack(distance, pre, post)
    post = post or doNothing
    function newPost(success)
        if success then
            if self.dir == 0 then
                self.y = self.y - 1
            elseif self.dir == 1 then
                self.x = self.x - 1
            elseif self.dir == 2 then
                self.y = self.y + 1
            elseif self.dir == 3 then
                self.x = self.x + 1
            end
        end
        post()
    end
    local covered = move.forceBack(distance, pre, newPost)
    return covered
end

function Position:up(distance, pre, post)
    post = post or doNothing
    function newPost(success)
        if success then
            self.z = self.z + 1
        end
        post()
    end
    local covered = move.up(distance, pre, newPost)
    return covered
end

function Position:forceUp(distance, pre, post)
    post = post or doNothing
    function newPost(success)
        if success then
            self.z = self.z + 1
        end
        post()
    end
    local covered = move.forceUp(distance, pre, newPost)
    return covered
end

function Position:down(distance, pre, post)
    post = post or doNothing
    function newPost(success)
        if success then
            self.z = self.z - 1
        end
        post()
    end
    local covered = move.down(distance, pre, newPost)
    return covered
end

function Position:forceDown(distance, pre, post)
    post = post or doNothing
    function newPost(success)
        if success then
            self.z = self.z - 1
        end
        post()
    end
    local covered = move.forceDown(distance, pre, newPost)
    return covered
end

function Position:turnRight(turns, pre, post)
    post = post or doNothing
    function newPost(success)
        if success then
            self.dir = (self.dir + 1) % 4
        end
        post()
    end
    local covered = move.turnRight(turns, pre, newPost)
    return covered
end

function Position:turnLeft(turns, pre, post)
    post = post or doNothing
    function newPost(success)
        if success then
            self.dir = (self.dir - 1) % 4
        end
        post()
    end
    local covered = move.turnLeft(turns, pre, newPost)
    return covered
end

function Position:turnTo(direction, pre, post)
    return self:turnRight((direction - self.dir) % 4, pre, post)
end


function Position:clearPath(dir)
    dir = dir or "forward"
    pre = pre or doNothing
    post = post or doNothing
    if dir == "forward" then
        while turtle.detect() do
            turtle.dig()
        end
    elseif dir == "back" then
        turtle.turnLeft(2)
        while turtle.detect() do
            turtle.dig()
        end
        turtle.turnLeft(2)
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

function Position:forceMove(dir, distance, pre, post)
    dir = dir or "forward"
    pre = pre or doNothing
    function newPre()
        self:clearPath(dir)
        pre()
    end

    if dir == "forward" then
        return self:forward(distance, newPre, post)
    elseif dir == "back" then
        return self:back(distance, newPre, post)
    elseif dir == "up" then
        return self:up(distance, newPre, post)
    elseif dir == "down" then
        return self:down(distance, newPre, post)
    end
end

function Position:savePos()
    self.x_store = self.x
    self.y_store = self.y
    self.z_store = self.z
    self.dir_store = self.dir
end

function Position:nestedSave(key)
    local key = key or "default"
    self[key.."_x_store"] = self.x
    self[key.."_y_store"] = self.y
    self[key.."_z_store"] = self.z
    self[key.."_dir_store"] = self.dir
    self.x = 0
    self.y = 0
    self.z = 0
    self.dir = 0
    -- print("Save! "..key)
    -- print("store "..tostring(self[key.."_y_store"]))
    -- print("curr  "..tostring(self.y))
    -- os.sleep(5)
end

function Position:nestedLoad(key)
    local key = key or "default"
    -- print("Load! "..key)
    -- print("store y "..tostring(self[key.."_y_store"]))
    local temp_x = self.x
    local temp_y = self.y
    if self[key.."_dir_store"] == 0 then
        -- print("curr y+ "..tostring(temp_y))
        self.x = (self[key.."_x_store"] or 0) + temp_x
        self.y = (self[key.."_y_store"] or 0) + temp_y
    elseif self[key.."_dir_store"] == 1 then
        -- print("curr x- "..tostring(temp_x))
        self.x = (self[key.."_x_store"] or 0) + temp_y
        self.y = (self[key.."_y_store"] or 0) - temp_x
    elseif self[key.."_dir_store"] == 2 then
        -- print("curr y- "..tostring(temp_y))
        self.x = (self[key.."_x_store"] or 0) - temp_x
        self.y = (self[key.."_y_store"] or 0) - temp_y
    elseif self[key.."_dir_store"] == 3 then
        -- print("curr x+ "..tostring(temp_x))
        self.x = (self[key.."_x_store"] or 0) - temp_y
        self.y = (self[key.."_y_store"] or 0) + temp_x
    end
    self.z = (self[key.."_z_store"] or 0) + self.z
    self.dir = ((self[key.."_dir_store"] or 0) + self.dir) % 4
    -- print("load    "..tostring(self.y))
    -- os.sleep(5)
end

function Position:goToPos(x, y, z, dir, pre, post)

    while x ~= self.x or y ~= self.y or z ~= self.z or dir ~= self.dir do
        -- Go to the right height
        if z > self.z then -- up
            self:forceMove("up", z - self.z, pre, post)
        else -- down
            self:forceMove("down", self.z - z, pre, post)
        end

        -- Turn and move in x
        if x > self.x then -- right, dir 1
            self:turnTo(1)
            self:forceMove("forward", x - self.x)
        else -- left, dir 3
            self:turnTo(3)
            self:forceMove("forward", self.x - x)
        end

        -- Turn and move in y
        if y > self.y then -- forward, dir 0
            self:turnTo(0)
            self:forceMove("forward", y - self.y)
        else -- backward, dir 2
            self:turnTo(2)
            self:forceMove("forward", self.y - y)
        end
        self:turnTo(dir)
    end
end

function Position:loadPos(pre, post)
    pre = pre or doNothing
    post = post or doNothing
    return self:goToPos(self.x_store, self.y_store, self.z_store, self.dir_store, pre, post)
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

function Position:coverGridAndReturn(initial_forward_dist, depth, left, right, pre, post, withdraw, deposit)
    pre = pre or doNothing
    post = post or doNothing
    withdraw = withdraw or doNothing
    deposit = deposit or doNothing
    initial_forward_dist = initial_forward_dist or 0
    local width = left + right + 1
    withdraw()
    self:turnRight(2)
    self:forward(initial_forward_dist - 1)
    if initial_forward_dist > 0 then
        self:forward(1, pre, post) -- Now at end of hall, facing forward
    else
        post(false)
    end

    if left > 0 then
        self:turnLeft()
        self:forward(left, pre, post)
        self:turnRight()
    end -- Now at front left, facing forward

    for i=1,depth-1 do
        self:forward(1, pre, post)
        if i%2 == 1 then
            self:turnRight()
            self:forward(width-2, pre, post)
            self:turnLeft()
        else
            self:turnLeft()
            self:forward(width-2, pre, post)
            self:turnRight()
        end
    end -- Now at back left or 1-off-right, facing forward

    self:turnRight()
    if (depth-1) % 2 == 0 then
        self:forward(width-2)
    end
    self:forward(1, pre, post)
    self:turnRight() -- Now at back right, facing backward

    self:forward(depth - 1, pre, post)
    if right > 0 then
        self:turnRight()
        self:forward(right-1, pre, post)
        self:forward(1)
        self:turnLeft()
    end -- Now at end of hall, facing backward
    
    self:forward(initial_forward_dist)
    deposit()
end
