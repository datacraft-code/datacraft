while true do
    a, b = turtle.inspect()
    if b.name == "ae2:quartz_cluster" then
        turtle.dig()
        for i=1,16 do
            turtle.select(i)
            turtle.dropUp()
        end
    end
    os.sleep(1)
end

