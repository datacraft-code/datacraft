args = {...}
local function githubGetRequest(url)
    os.unloadAPI("/libs/secrets")
    os.loadAPI("/libs/secrets")
    local headers = {
        Authorization="token "..secrets.GITHUB_AUTH_TOKEN,
        Accept="application/vnd.github.VERSION.raw"
    }
    return http.get(url, headers)
end

local function getFileNamesIn(folder)
    local script_names = {}
    local res = githubGetRequest("https://api.github.com/repos/datacraft-code/datacraft/contents/"..folder.."?ref=Enderchestless")

    if res == nil then
        print("Error: HTTP returned nil for /"..folder)
        return script_names
    end

    if res.getResponseCode() ~= 200 then
        print("Error: Response code "..res.getResponseCode().."for /"..folder)
        return script_names
    end

    local contents = res.readAll()
    res.close()
    print("Success: Got contents of "..folder)

    for s in string.gmatch(contents, "\"name\":\s*\"([^.]+)\.lua\"") do
        table.insert(script_names, s)
    end
    return script_names
end

local function saveScripts(folder, script_names)
    for key, script_name in pairs(script_names) do
        local res = githubGetRequest("https://api.github.com/repos/datacraft-code/datacraft/contents/"..folder.."/"..script_name..".lua?ref=Enderchestless")
        local script = res.readAll()

        local h = fs.open("/"..folder.."/"..script_name, "w")
        h.write(script)
        h.close("/"..folder.."/"..script_name)

        if args[1] == "ls" then print("/"..folder.."/"..script_name) end

        if script_name == "go" then
            local h = fs.open("/go", "w")
            h.write(script)
            h.close()
        end
    end
end

local function loadLibScripts(folder, script_names)
    for key, script_name in pairs(script_names) do
        os.unloadAPI("/"..folder.."/"..script_name)
        os.loadAPI("/"..folder.."/"..script_name)
    end
end

local libs = getFileNamesIn("libs")
saveScripts("libs", libs)
loadLibScripts("libs", libs)

local scripts = getFileNamesIn("scripts")
saveScripts("scripts", scripts)

local name = util.getSetting("name")
if name then
    os.setComputerLabel(name)
end

if args[1] and args[1] ~= "ls" and fs.exists("/scripts/"..args[1], "r") then
    args[1] = "/scripts/"..args[1]
    shell.run(unpack(args))
end

-- n2NehApT