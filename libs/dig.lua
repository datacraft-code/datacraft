local function addOres(target_blocks)
    for i, val in ipairs(util.ore_blocks) do
        target_blocks[val] = true
    end
end

local function addInFront(target_blocks)
    local isBlock, blockData = turtle.inspect()
    if not isBlock then
        return
    end
    target_blocks[blockData.name] = true
end

function dfs(targeting, all_sides, pos, avoidRefuel)
    local pos = pos or position.Position:create()
    targeting = targeting or "scan"
    local target_blocks = {}

    if targeting == "scan_only" then
        addInFront(target_blocks)
    elseif targeting == "ore" then
        addOres(target_blocks)
    elseif targeting == "scan" then
        addInFront(target_blocks)
        addOres(target_blocks)
    end

    local path = {}
    local dir = 0 -- 0=forward, 1=right, 2=back, 3=left, 4=up, 5=down, 6=done
    local totalBlocks = 0

    function push(push_dir)
        if push_dir < 6 then
            totalBlocks = totalBlocks + 1
        end
        path[#path+1] = push_dir
    end

    function pop()
        local val = table.remove(path, #path)
        if val == nil then
            return 7
        else
            return val
        end
    end

    function scan()
        local isBlock, blockData = turtle.inspect()
        if isBlock and target_blocks[blockData.name] then
            return true
        end
        return false
    end

    function scanUp()
        local isBlock, blockData = turtle.inspectUp()
        if isBlock and target_blocks[blockData.name] then
            return true
        end
        return false
    end

    function scanDown()
        local isBlock, blockData = turtle.inspectDown()
        if isBlock and target_blocks[blockData.name] then
            return true
        end
        return false
    end

    function loop()
        -- if util.countFreeSlots() < 2 then
        --     util.depositItemsInBarrelExcept({}, 16)
        -- end
        if not avoidRefuel then
            util.tryRefuel(fuel, 500)
        end
        if dir == 6 then
            local back = pop()
            if back < 4 then
                if pos:back() == 0 then
                    pos:turnLeft(2)
                    pos:forceMove("forward")
                    pos:turnLeft(2)
                end
            elseif back == 4 then
                pos:forceMove("down")
            elseif back == 5 then
                pos:forceMove("up")
            end
            dir = back
            return
        end

        if dir < 4 then
            if scan() then
                push(dir)
                pos:forceMove("forward")
                dir = 0
                return
            end
            pos:turnRight()
        end

        if dir == 4 then
            if scanUp() then
                push(dir)
                pos:forceMove("up")
                dir = 0
                return
            end
        end

        if dir == 5 then
            if scanDown() then
                push(dir)
                pos:forceMove("down")
                dir = 0
                return
            end
        end

        dir = dir + 1
    end

    if not avoidRefuel then
        util.tryRefuel(fuel, 500)
    end
    if all_sides then
        push(7)
    else
        if not scan() then
            return
        end
        pos:forceMove("forward", 1)
        push(0)
    end

    while #path ~= 0 do
        loop()
    end
    -- if totalBlocks > 1 then
    --     util.depositItemsEnderChestExcept("thermal:charcoal_block")
    -- end
end

function tunnel(left, right, up, down, length, pos, should_dfs)
    local pos = pos or position.Position:create()
    pos:nestedSave("tunnel")

    local function tunnelPre()
        if util.countFreeSlots() < 2 then
            util.depositItemsEnderChestExcept("thermal:charcoal_block")
        end
        util.tryRefuel(fuel, 500)
        if should_dfs then
            dfs("ore", true, pos)
        end
    end
    
    local function tunnelPost()
        move.turnLeft()
        if should_dfs then
            dfs("ore", false, pos)
        end
        turtle.dig()
        move.turnLeft()
        if should_dfs then
            dfs("ore", false, pos)
        end
        move.turnLeft()
        if should_dfs then
            dfs("ore", false, pos)
        end
        turtle.dig()
        move.turnLeft()
    end

    local lastDigDepth = -1
    while pos.y < length - 1 do
        while pos.y < lastDigDepth + 3 and pos.y < length - 1 do
            pos:forceMove("forward", 1, tunnelPre)
        end
        lastDigDepth = pos.y
        pos:turnLeft()
        pos:forceMove("forward", left, tunnelPre, tunnelPost)
        local isLeft = true
        while pos.z > -down do
            pos:forceMove("down", 1, tunnelPre, tunnelPost)
            pos:turnLeft(2)
            pos:forceMove("forward", left + right - 1, tunnelPre, tunnelPost)
            isLeft = not isLeft
        end
        if isLeft then
            pos:turnLeft(2)
            pos:forceMove("forward", left + right - 1, tunnelPre, tunnelPost)
        end
        pos:forceMove("forward", 1, tunnelPre, tunnelPost)
        pos:forceMove("up", 1, tunnelPre, tunnelPost)
        if (pos.y + 1) % 9 == 0 then -- Every nine blocks, place torch
            util.placeTorch("down")
        end
        pos:forceMove("up", up + down - 1, tunnelPre, tunnelPost) -- Top right, facing right
        pos:turnLeft(2) -- Top right, facing left
        if right + left > 0 then
            pos:forceMove("forward", 1, tunnelPre, tunnelPost)
        end
        isLeft = false
        while pos.z > 0 do
            pos:forceMove("forward", left + right - 1, tunnelPre, tunnelPost)
            pos:turnLeft(2)
            pos:forceMove("down", 1, tunnelPre, tunnelPost)
            isLeft = not isLeft
        end
        if isLeft then
            pos:forceMove("forward", left, tunnelPre, tunnelPost)
            pos:turnLeft()
        else
            if right > 0 then
                pos:forceMove("forward", right - 1, tunnelPre, tunnelPost)
            elseif right + left > 0 then
                pos:turnLeft(2)
                pos:forceMove("forward", 1, tunnelPre, tunnelPost)
                pos:turnLeft(2)
            end
            pos:turnRight()
        end
    end
    pos:nestedLoad("tunnel")
end

function passage(length, steps, pos)
    local steps = steps or 0
    local pos = pos or position.Position:create()
    pos:nestedSave("passage")

    local function passagePost()
        if util.countFreeSlots() < 3 then
            -- util.depositItemsEnderChestExcept("thermal:charcoal_block")
            -- util.depositItemInBin("minecraft:cobblestone", 16)
            util.depositItemsInBarrelExcept({}, 16)
        end
        if util.countFreeSlots() < 1 then
            error("Out of inv space")
        end
        util.tryRefuel(fuel, 500)
        dfs("ore", true, pos)
    end

    -- start facing top block
    for i=1,steps do
        pos:forceMove("forward", 1, nil, passagePost)
        pos:forceMove("down", 2 + steps - i, nil, passagePost)
        util.placeBlock("down", util.basic_blocks)
        pos:forceMove("up", 2 + steps - i)
    end

    local isAtTop = true
    while pos.y < length - steps do
        pos:forceMove("forward", 1, nil, passagePost)
        if isAtTop then
            pos:forceMove("down", 1, nil, passagePost)
            util.placeBlock("down", util.basic_blocks)
        else
            util.placeBlock("down", util.basic_blocks)
            pos:forceMove("up", 1, nil, passagePost)
            if (pos.y + 4) % 5 == 0 then
                util.placeTorch("down")
            end
        end
        isAtTop = not isAtTop
    end

    if not isAtTop then
        pos:forceMove("up", 1, nil, passagePost)
    end

    for i=1,steps do
        pos:forceMove("forward", 1, nil, passagePost)
        pos:forceMove("down", 1 + i, nil, passagePost)
        util.placeBlock("down", util.basic_blocks)
        pos:forceMove("up", 1 + i)
    end
    pos:nestedLoad("passage")
end