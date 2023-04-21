
local round_system_hook_prefix = "RoundSystem_"

SetGlobalBool("m_bBombPlanted", false)

round_spawning = false

function GM:SetCT(ply)
    ply:AllowFlashlight(SUBGAMEMODE.CONFIG.FLASHLIGHT_ENABLED)
end

function GM:SetT(ply)
    ply:AllowFlashlight(SUBGAMEMODE.CONFIG.FLASHLIGHT_ENABLED)
end

function GM:GetPlayerInfo(ply)
    return {
        ent = ply,
        nick = ply:Nick(),
        steamid64 = ply:SteamID64(),
        money = ply:GetMoney(),
        team = ply:Team()
    }
end

function GM:GetPreparingTime()
    return SUBGAMEMODE:GetPreparingTime()
end

function GM:GetRoundTime()
    return SUBGAMEMODE:GetRoundTime()
end

function GM:GetPostroundTime()
    return SUBGAMEMODE:GetPostroundTime()
end

function GM:WonRoundNum(win_id, round_num)
    if GAMEMODE.RoundHistory[round_num] == nil then return false end
    return GAMEMODE.RoundHistory[round_num].postround.win_id == win_id
end

function GM:LostRoundNum(win_id, round_num)
    if GAMEMODE.RoundHistory[round_num] == nil then return false end
    return GAMEMODE.RoundHistory[round_num].postround.win_id != win_id
end

hook.Add("RoundModule_PreparingStart_Post", round_system_hook_prefix.."PreparingStart_Post", function()
    round_spawning = true

    -- If the round history table doesn't exist, create it
    -- It is used to check what happened in previous rounds
    if GAMEMODE.RoundHistory == nil then
        GAMEMODE.RoundHistory = {}
        round_id = 0
        first_round = true
    else
        first_round = false
    end
    round_id = round_id + 1
    GAMEMODE.RoundHistory[round_id] = {
        id = round_id,
        subgamemode = SUBGAMEMODE.name,
        preparing = {
            players = {}
        },
        postround = {
            players = {},
            win_id = 0,
            win_reason = 0,
        }
    }

    -- Clean up stuff from previous round
    game.CleanUpMap()
    SetGlobalBool("m_bBombPlanted", false)

    -- Shuffle all player spawns
    GAMEMODE:ShuffleFirstTeamPlayerSpawns()

    for k,v in pairs(player.GetAll()) do
        v.changed_team = false
        v.purchase_notif_fired = false
    end

    --Subgamemode does its things like spawning players
    SUBGAMEMODE:Post_Preparing()

    for i,v in ipairs(player.GetAll()) do
        if first_round then
            v:SetMoney(SUBGAMEMODE.CONFIG.STARTING_MONEY, false)
        end

        table.insert(GAMEMODE.RoundHistory[round_id].preparing.players, i, GAMEMODE:GetPlayerInfo(v))
    end

    round_spawning = false
end)

hook.Add("RoundModule_PostRoundStart", round_system_hook_prefix.."PostRoundStart", function(win_id, win_reason)
    SUBGAMEMODE:Post_PostRoundStart(win_id, win_reason)

    GAMEMODE.RoundHistory[round_id].postround.win_id = win_id
    GAMEMODE.RoundHistory[round_id].postround.win_reason = win_reason

    for i,v in ipairs(player.GetAll()) do
        table.insert(GAMEMODE.RoundHistory[round_id].postround.players, i, GAMEMODE:GetPlayerInfo(v))
    end
end)

hook.Add("RoundModule_RoundStart_Post", round_system_hook_prefix.."RoundStart_Post", function()
    SUBGAMEMODE:Post_RoundStart()
end)

hook.Add("RoundModule_WinCheck", round_system_hook_prefix.."WinCheck", function()
    return SUBGAMEMODE:WinCheck()
end)
