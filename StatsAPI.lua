getgenv().sendReq = true

APIURL = "https://DiscordRobloxStats.repl.co"

local Lib = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
while not Lib.Loaded do
	game:GetService("RunService").Heartbeat:Wait();
end;

local Save = Lib.Save.Get

local Commas = Lib.Functions.Commas
local types = {}
local menus = game:GetService("Players").LocalPlayer.PlayerGui.Main.Right
for i, v in pairs(menus:GetChildren()) do
    if v.ClassName == 'Frame' and v.Name ~= 'Rank' and not string.find(v.Name, "2") then
        table.insert(types, v.Name)
    end
end
currentStats = {}
function get(thistype)
    return Save()[thistype]
end
for i,v in pairs(types) do
    spawn(function()
        local megatable = {}
        local imaginaryi = 1
        local ptime = 0
        local last = tick()
        local now = last
        local TICK_TIME = 0.5
        while (getgenv().sendReq) do
            if ptime >= TICK_TIME then
                while ptime >= TICK_TIME do ptime = ptime - TICK_TIME end
                local currentbal = get(v)
                megatable[imaginaryi] = currentbal
                local diffy = currentbal - (megatable[imaginaryi-120] or megatable[1])
                imaginaryi = imaginaryi + 1
                currentStats[v] = tostring(Commas(diffy))
            end
            task.wait(0.001)
            now = tick()
            ptime = ptime + (now - last)
            last = now
        end
    end)
end

mythicalCount = 0

spawn(function()
    Lib.Network.Fired("Open Egg"):Connect(function(egg, openTable)
        for i,v in ipairs(openTable) do
            if (Lib.Directory.Pets[v.id]["rarity"] == "Mythical") then
                mythicalCount = mythicalCount + 1
            end
        end
    end)
end)

function connect()
    print("Trying to connect")
    dataTable = {
        ["username"] = game:GetService("Players").LocalPlayer.Name,
        ["userid"] = tostring(game:GetService("Players").LocalPlayer.UserId),
        ["jobid"] = tostring(game.JobId),
        ["displayname"] = game:GetService("Players").LocalPlayer.DisplayName,
        ["totalpets"] = tostring(#Save().Pets),
        ["gems"] = tostring(Commas(math.floor(Save()["Diamonds"]))),
        ["coins"] = tostring(Commas(math.floor(Save()["Coins"]))),
        ["tech"] = tostring(Commas(math.floor(Save()["Tech Coins"]))),
        ["fantasy"] = tostring(Commas(math.floor(Save()["Fantasy Coins"]))),
        ["gingerbread"] = tostring(Commas(math.floor(Save()["Gingerbread"]))),
        ["stats"] = currentStats,
        ["discordid"] = discordId,
        ["mythicals"] = tostring(mythicalCount)
    }
    sendTable = game:GetService("HttpService"):JSONEncode(dataTable)
    local headers = {
       ["content-type"] = "application/json"
    }
    request = http_request or request or HttpPost or syn.request
    sendData = {Url = APIURL.."/newconnection", Body = sendTable, Method = "POST", Headers = headers}
    data = (request(sendData))
    if not data then
        wait(5)
        connect()
    end
    if (data["Body"] == "false") then
        getgenv().sendReq = false
        spawn(function()
            Lib.Message.New("Discord Id Invalid")
        end)
    end
end
connect()

wait(3)
while getgenv().sendReq do
	local headers = {
		["content-type"] = "application/json"
	}
    dataTable = {
        ["username"] = game:GetService("Players").LocalPlayer.Name,
        ["userid"] = tostring(game:GetService("Players").LocalPlayer.UserId),
        ["jobid"] = tostring(game.JobId),
        ["displayname"] = game:GetService("Players").LocalPlayer.DisplayName,
        ["totalpets"] = tostring(#Save().Pets),
        ["gems"] = tostring(Commas(math.floor(Save()["Diamonds"]))),
        ["coins"] = tostring(Commas(math.floor(Save()["Coins"]))),
        ["tech"] = tostring(Commas(math.floor(Save()["Tech Coins"]))),
        ["fantasy"] = tostring(Commas(math.floor(Save()["Fantasy Coins"]))),
        ["gingerbread"] = tostring(Commas(math.floor(Save()["Gingerbread"]))),
        ["stats"] = currentStats,
        ["discordid"] = discordId,
        ["mythicals"] = tostring(mythicalCount)
    }
    sendTable = game:GetService("HttpService"):JSONEncode(dataTable)
    request = http_request or request or HttpPost or syn.request
    sendData = {Url = APIURL.."/update", Body = sendTable, Method = "POST", Headers = headers}
    data = (request(sendData))
    if not data then
        wait(10)
        connect()
    end
    
    if (data["Body"] == "stop") then
        getgenv().sendReq = false
    elseif (data["Body"] == "reconnect") then
        print("Lost connection retrying")
        connect()
    end
    wait(10)
end
