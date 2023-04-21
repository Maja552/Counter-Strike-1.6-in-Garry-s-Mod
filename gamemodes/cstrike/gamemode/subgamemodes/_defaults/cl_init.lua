
include("shared.lua")

local round_start_sounds = {
    "cstrike/radio/go.wav",
    "cstrike/radio/letsgo.wav",
    "cstrike/radio/locknload.wav",
    "cstrike/radio/moveout.wav"
    --vip.wav
}

net.Receive("cs16_roundstart", function(len)
    surface.PlaySound(round_start_sounds[math.random(#round_start_sounds)])

    system.FlashWindow()
end)

net.Receive("cs16_postroundstart", function(len)
    local win_id = net.ReadInt(8)
    if win_id and SUBGAMEMODE.CONFIG.WinConditions[win_id] then
        SUBGAMEMODE.CONFIG.WinConditions[win_id].on_win_cl()
    end
end)

GM.DEFAULT_HUD_Spect_PlayerLists = {
    function() return "Counter-Terrorists : "..team.GetScore(TEAM_CT) end,
    function() return "Terrorists : "..team.GetScore(TEAM_T) end,
}

local cached_map_desc = nil
GM.DEFAULT_MENU_MapDescription = function()
    if cached_map_desc then return cached_map_desc end
    local str = "cstrike/map_descriptions/"..game.GetMap()..".txt"
    local desc = file.Read(str, "LUA")
    if !desc then
        str = string.Replace(str, "_cs16", "")
        desc = file.Read(str, "LUA")
    end
    if desc then
        cached_map_desc = desc
    end
    return desc or SUBGAMEMODE.CONFIG.DEFAULT_MOTD or ""
end

function GM:DEFAULT_CL_ScalePlayerDamage(ply, hitgroup, dmginfo)
    -- prevent blood particles
    if IsValid(attacker) and attacker:IsPlayer() and ply:Team() == attacker:Team() then
        return true
    end
end

--NVG STUFF
function GM:DEFAULT_NVG_EFFECTS()
    local client = LocalPlayer()
    local nvg_info = {
        contrast = 1,
        colour = 1,
        brightness = 0,
        clr_r = 0,
        clr_g = 0,
        clr_b = 0,
        add_r = 0,
        add_g = 0,
        add_b = 0
    }
    if client:GetNWBool("HasNVG", false) and client:GetNWBool("NVGEnabled", false) then
        nvg_info.contrast = 2
        nvg_info.add_g = 0.15
        nvg_info.clr_g = 0.9
        nvg_info.brightness = -0.2
        return nvg_info
    end
end

-- AFTER LOAD
include("cl_hud_buy_items.lua")
include("cl_hud_scoreboard.lua")
include("cl_hud_select_model.lua")
include("cl_hud_select_team.lua")

print("Gamemode loaded gamemodes/_defaults/cl_init.lua")