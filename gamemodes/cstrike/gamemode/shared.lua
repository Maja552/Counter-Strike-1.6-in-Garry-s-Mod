GM.Name = "Counter-Strike 1.6"
GM.Author = "Kanade552"
GM.Email = "N/A"
GM.Website = "N/A"
GM.IsCStrike = true

function GM:Initialize()
    print("GAMEMODE INITIALIZED: SHARED")
end

function GM:GetHostName()
    local text = GetHostName()
    if text == "Garry's Mod" then
        text = "Counter-Strike"
    end
    return text
end

-- enums found in sh_enums.lua
team.SetUp(TEAM_SZ, TEAM_SZ_NAME, TEAM_SZ_CLR)
team.SetUp(TEAM_CT, TEAM_CT_NAME, TEAM_CT_CLR)
team.SetUp(TEAM_T, TEAM_T_NAME, TEAM_T_CLR)

team.SetColor(TEAM_SPECTATOR, cs16_main_color)

team.SetSpawnPoint(TEAM_SZ, {"info_player_counterterrorist"})
team.SetSpawnPoint(TEAM_CT, {"info_player_counterterrorist"})
team.SetSpawnPoint(TEAM_T, {"info_player_terrorist"})


print("Gamemode loaded shared.lua")