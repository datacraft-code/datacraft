while true do
    a, b = turtle.inspect()
    if b.name == "ae2:quartz_cluster" then
        turtle.dig()
    end
    a, b = turtle.inspectDown()
    if b.name == "ae2:quartz_cluster" then
        turtle.digDown()
    end
    turtle.select(1)
    turtle.dropUp()
    os.sleep(1)
end

