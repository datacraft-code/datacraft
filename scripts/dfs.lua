args = {...}
local targeting = args[1] or "scan"
dig.dfs(targeting, false, nil, true)