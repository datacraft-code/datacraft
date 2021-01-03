args = {...}
left = tonumber(args[1])
right = tonumber(args[2])
up = tonumber(args[3])
down = tonumber(args[4])
length = tonumber(args[5])
should_dfs = args[6]
if should_dfs == "false" then
    dig.tunnel(left, right, up, down, length, nil, false)
else
    dig.tunnel(left, right, up, down, length, nil, true)
end
