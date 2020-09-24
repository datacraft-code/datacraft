local function doNothing()

end

function includes(table, value)
    for i, val in ipairs(table) do
        if value == val then
            return true
        end
    end
    return false
end

function push(table, value)
    table[#table+1] = value
    return table
end

function pop(table)
    return table.remove(table, #table)
end

function concat(table1, table2)
    for i, value in ipairs(table2) do
        push(table1, value)
    end
    return table1
end

function findInInventory(item)
    for i = 1,16 do
        local itemDetail = turtle.getItemDetail(i)
        if itemDetail and itemDetail.name == item then
            return i
        end
    end
    return -1
end

function countInInventory(item)
    local number_found = 0
    for i = 1,16 do
        local itemDetail = turtle.getItemDetail(i)
        if itemDetail and itemDetail.name == item then
            number_found = number_found + turtle.getItemCount(i) 
        end
    end
    return number_found
end

function countFreeSlots()
    local total = 0
    for i = 1,16 do
        if not turtle.getItemDetail(i) then
            total = total + 1
        end
    end
    return total
end

function depositInChest(item, min_left, max, dir)
    max = max or 64*16*16
    min_left = min_left or 0
    dir = dir or "front"
    local oldInventorySlot = turtle.getSelectedSlot() 
    local totalInInv = countInInventory(item)
    local leftToPlace = math.min(totalInInv - min_left, max)
    while true do
        local invSlot = findInInventory(item)
        if invSlot == -1 then break end
        local amountThere = turtle.getItemCount(invSlot)
        local amountToDrop = math.min(amountThere, leftToPlace)
        turtle.select(invSlot)
        if dir == "front" then
            turtle.drop(amountToDrop)
        elseif dir == "up" then
            turtle.dropUp(amountToDrop)
        elseif dir == "down" then
            turtle.dropDown(amountToDrop)
        end
        leftToPlace = leftToPlace - amountToDrop
        if leftToPlace == 0 then break end
    end
    turtle.select(oldInventorySlot)
end

function interactWithEnderChest(chest_slot, handler)
    local turns = 0
    while turns < 4 do
        if not turtle.inspect() then
            local old_inventory_slot = turtle.getSelectedSlot() 
            turtle.select(chest_slot)
            turtle.place()
            turtle.select(1)
            handler()
            turtle.select(chest_slot)
            turtle.dig()
            turtle.select(old_inventory_slot)
            break
        end
        turtle.turnRight()
        turns = turns + 1
    end
    turns = turns % 4
    for i=1,turns do
        turtle.turnLeft()
    end
end

function withdrawFuelEnderChest(count)
    local fuel_chest_slot = 15
    local function withdrawFuel()
        turtle.select(1)
        turtle.suck(count)
    end

    interactWithEnderChest(fuel_chest_slot, withdrawFuel)
end

function depositItemsEnderChestExcept(blacklist_)
    local deposit_chest_slot = 16
    local blacklist = {"enderstorage:ender_storage", "minecraft:torch"}
    if type(blacklist_) == "string" then
        push(blacklist, blacklist_)
    elseif type(blacklist_) == "table" then
        concat(blacklist, blacklist_)
    end

    local function depositItems()
        for i=1,16 do
            item = turtle.getItemDetail(i)
            if item and not includes(blacklist, item.name) then
                turtle.select(i)
                turtle.drop()
            end
        end
    end

    interactWithEnderChest(deposit_chest_slot, depositItems)
end

function takeFromChest(dir)
    dir = dir or "front"
    if dir == "front" then
        turtle.suck()
    elseif dir == "up" then
        turtle.suckUp()
    elseif dir == "down" then
        turtle.suckDown()
    end
end

function tryRefuel(fuelType, fuelLimit)
    local fuelType = fuelType or "quark:charcoal_block"
    local fuelLimit = fuelLimit or 250
    local fuelCount = countInInventory(fuelType)
    if fuelCount == 0 and fuelType ~= "minecraft:coal_block" then
        return tryRefuel("minecraft:coal_block", fuelLimit)
    end
    if fuelCount < 3 then
        local fuel_slot = findInInventory(fuelType)
        if fuel_slot ~= -1 then
            turtle.select(fuel_slot)
        else
            turtle.select(1)
        end
        withdrawFuelEnderChest(4)
    end
    local oldInventorySlot = turtle.getSelectedSlot() 
    while turtle.getFuelLevel() < fuelLimit do
        local inventorySlot = findInInventory(fuelType)
        if inventorySlot == -1 then return end
        turtle.select(inventorySlot)
        turtle.refuel(1)
    end
    turtle.select(oldInventorySlot)
end

function countdown(time)
    local oldLabel = os.getComputerLabel()
    for i = time, 1, -1 do
        local newLabel = oldLabel.." "
        local acc = i

        local hours = math.floor(acc / 3600)
        if hours > 0 then newLabel = newLabel..hours..":" end
        acc = acc - 3600 * hours

        local minutes = math.floor(acc / 60)
        if minutes > 0 then newLabel = newLabel..string.format("%02d", minutes)..":" end
        acc = acc - 60 * minutes

        newLabel = newLabel..string.format("%02d", acc)
        os.setComputerLabel(newLabel)
        os.sleep(1)
    end
    os.setComputerLabel(oldLabel)
end

function moveItemFromEverywhere(item, dest)
    local oldInventorySlot = turtle.getSelectedSlot() 
    for i = 1,16 do
        local itemDetail = turtle.getItemDetail(i)
        if 1 ~= dest and itemDetail and itemDetail.name == item then
            turtle.select(i)
            turtle.transferTo(dest)
        end
    end
    turtle.select(oldInventorySlot)
end

function moveOne(source, dest)
    local oldInventorySlot = turtle.getSelectedSlot()
    turtle.select(source)
    turtle.transferTo(dest, 1)
    turtle.select(oldInventorySlot)
end

function getSetting(setting)
    local path = "settings/"..setting..".lua"
    if fs.exists(path) then
        h = fs.open(path, "r")
        return h.readAll()
    else
        return nil
    end
end

ore_blocks = {
    "minecraft:iron_ore",
    "minecraft:gold_ore",
    "minecraft:coal_ore",
    "railcraft:ore_metal",
    "railcraft:ore_metal_poor",
    "thermalfoundation:ore",
    "forestry:resources",
}

basic_blocks = {
    "minecraft:cobblestone",
    "minecraft:dirt",
    "minecraft:andesite",
    "minecraft:granite",
    "minecraft:diorite",
    "quark:slate",
    "minecraft:gravel",
}

function placeTorch(dir)
    placeBlock(dir, "minecraft:torch")
end

function placeBlock(dir, blocks)
    dir = dir or "forward"
    local allowedBlocks = {}
    if type(blocks) == "string" then
        push(allowedBlocks, blocks)
    elseif type(blocks) == "table" then
        allowedBlocks = blocks
    end
    
    local block_slot = -1
    for i, value in ipairs(allowedBlocks) do
        local slot = findInInventory(value)
        if slot ~= -1 then
            block_slot = slot
            break
        end
    end
    if block_slot == -1 then
        return
    end
    local oldInventorySlot = turtle.getSelectedSlot()
    turtle.select(block_slot)
    if dir == "forward" then
        turtle.place()
    elseif dir == "back" then
        turtle.turnLeft()
        turtle.turnLeft()
        turtle.place()
        turtle.turnLeft()
        turtle.turnLeft()
    elseif dir == "left" then
        turtle.turnLeft()
        turtle.place()
        turtle.turnRight()
    elseif dir == "right" then
        turtle.turnRight()
        turtle.place()
        turtle.turnLeft()
    elseif dir == "up" then
        turtle.placeUp()
    elseif dir == "down" then
        turtle.placeDown()
    end
    turtle.select(oldInventorySlot)
end