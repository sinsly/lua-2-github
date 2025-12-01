--[[

    Author: sinsly
    License: MIT
    Github: https://github.com/sinsly

    Usage: 
    Replace "GITHUB_URL"
    Replace "GITHUB_API" 
    Replace "TOKEN" 

    * Follow the README.md for guide on how to get your token.
    * Please don't publicly expose your TOKEN people can accesss your repo(s) if public!!!

    - This script is a usage example that will call a table of localplayer username executing the script.
    - Will constantly add new names (never) remove, and ignores if name is already in table and keeps it there;
    
    Usernames = {
    "sinsly",
    etc.
    }

--]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local GITHUB_URL = "https://raw.githubusercontent.com/Username/RepoName/main/FileName.lua"
local GITHUB_API = "https://api.github.com/repos/Username/RepoName/contents/FileName.lua"
local TOKEN = "ghpTOKENHERE"

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function base64_decode(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r
    end):gsub('%d%d%d%d%d%d%d%d', function(x)
        local c=0
        for i=1,8 do c=c + (x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local function getHttpRequest()
    return syn and syn.request or
           http and http.request or
           http_request or
           fluxus and fluxus.request or
           krnl and krnl.request or
           request or
           error("No compatible HTTP request function found.")
end

local requestFunc = getHttpRequest()

local function fetchUsernames()
    local success, response = pcall(function()
        return requestFunc({Url = GITHUB_URL, Method = "GET"})
    end)
    if success and response.StatusCode == 200 then
        local content = response.Body
        local env = {}
        local f, err = loadstring(content)
        if f then
            setfenv(f, env)
            f()
            if env.Usernames then
                local cleanUsernames = {}
                for _, name in ipairs(env.Usernames) do
                    local ok, decoded = pcall(base64_decode, name)
                    if ok and decoded and decoded ~= "" then
                        table.insert(cleanUsernames, decoded)
                    else
                        table.insert(cleanUsernames, name)
                    end
                end
                return cleanUsernames
            end
        end
    end
    return {}
end

local function updateTable(usernames)
    local currentUser = LocalPlayer.Name
    for _, name in ipairs(usernames) do
        if name == currentUser then
            return usernames, false
        end
    end
    table.insert(usernames, currentUser)
    return usernames, true
end

local function uploadTable(usernames)
    local luaTableString = "Usernames = {\n"
    for _, name in ipairs(usernames) do
        luaTableString = luaTableString .. string.format('"%s",\n', name)
    end
    luaTableString = luaTableString .. "}\n"

    local encoded = (syn and syn.crypt.base64_encode(luaTableString)) or base64_encode(luaTableString)

    local sha = ""
    local shaResp = requestFunc({Url = GITHUB_API, Method = "GET"})
    if shaResp.StatusCode == 200 then
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, shaResp.Body)
        if ok then sha = decoded.sha end
    end

    local body = HttpService:JSONEncode({message = "Update usernames", content = encoded, sha = sha})
    local success, resp = pcall(function()
        return requestFunc({
            Url = GITHUB_API,
            Method = "PUT",
            Headers = {["Authorization"] = "token "..TOKEN, ["Content-Type"] = "application/json"},
            Body = body
        })
    end)
    if success then
        print("GitHub updated!")
    else
        warn("Failed to update GitHub: "..tostring(resp))
    end
end

local usernames = fetchUsernames()
local updatedTable, added = updateTable(usernames)
if added then
    uploadTable(updatedTable)
else
    print("Username already exists in the table.")
end
