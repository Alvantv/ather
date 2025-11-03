local games = {
    [116605585218149] = "https://raw.githubusercontent.com/Alvantv/ather/refs/heads/main/sea1.lua",
    [106962503558742] = "https://raw.githubusercontent.com/Alvantv/ather/refs/heads/main/sea2.lua",
}

local currentID = game.PlaceId
local scriptURL = games[currentID]

if scriptURL then
    loadstring(game:HttpGet(scriptURL))()
else
    game.Players.LocalPlayer:Kick("Game Tidak Ada.")
end
