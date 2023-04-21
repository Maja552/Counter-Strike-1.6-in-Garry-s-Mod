
SUBGAMEMODE = {}
SUBGAMEMODE.CONFIG = {}
SUBGAMEMODE.HOOKS = {}

include("shared.lua")
include("sh_config_shop_items.lua")

-- Scoreboard player lists like Terrorists, Counter-Terrorists and Spectators
SUBGAMEMODE.CONFIG.SB_PlayerLists = table.Copy(GM.DEFAULT_SB_PlayerLists)
SUBGAMEMODE.CONFIG.HUD_Spect_PlayerLists = table.Copy(GM.DEFAULT_HUD_Spect_PlayerLists)
include("cl_hud_select_team.lua")
SUBGAMEMODE.CONFIG.MENU_SelectModels = table.Copy(GM.DEFAULT_MENU_SelectModels)
SUBGAMEMODE.CONFIG.MENU_MapDescription = GM.DEFAULT_MENU_MapDescription

-- Useful for adding effects when somebody gets damaged
function SUBGAMEMODE:CL_ScalePlayerDamage(ply, hitgroup, dmginfo)
    return GAMEMODE:DEFAULT_CL_ScalePlayerDamage(ply, hitgroup, dmginfo)
end

net.Receive("cs16_zm_roundstart", function(len)
    CS16_ZM_CurrentRoundType = net.ReadString()
    CS16_ZM_ROUNDTYPES[CS16_ZM_CurrentRoundType]["cl_post_round_start"]()

    RunConsoleCommand("gsrchud_theme", "Counter-Strike")
    RunConsoleCommand("fov", "100")
end)

net.Receive("cs16_zm_prepstart", function(len)
    force_remove_buymenu()
    for k,ply in pairs(player.GetAll()) do
        reset_player(ply)
        SPECT_PMChanged(ply)
    end

    RunConsoleCommand("gsrchud_theme", "Counter-Strike")
    RunConsoleCommand("fov", "100")
end)

net.Receive("cs16_gotinfected", function(len)
    util.ScreenShake(LocalPlayer():GetPos(), 15, 5, 2, 500)
    LocalPlayer().CS16_NVG_ENABLED = false
    force_remove_buymenu()
end)

local function create_zombie_dlight(pos, ent, duration)
    ent.Dlight = DynamicLight(ent:EntIndex())
    ent.Dlight.pos = pos
    ent.Dlight.r = 0
    ent.Dlight.g = 255
    ent.Dlight.b = 0
    ent.Dlight.brightness = 3
    ent.Dlight.Decay = 1000
    ent.Dlight.Size = 512
    ent.Dlight.DieTime = CurTime() + duration
end

net.Receive("cs16_playerinfected", function(len)
    local infected = net.ReadEntity()
    local infected_is_nemesis = net.ReadBool()
    infected.is_nemesis = infected_is_nemesis
    create_zombie_dlight(infected:GetPos() + Vector(0,0,50), infected, 0.3)

    SPECT_PMChanged(infected)
end)

net.Receive("cs16_zombie_madness", function(len)
    local zomb = net.ReadEntity()
    local duration = net.ReadInt(16)
    --print("madness for ", zomb, duration)
    zomb.zombie_madness_til = CurTime() + duration
    create_zombie_dlight(zomb:GetPos(), zomb, zomb.zombie_madness_til)
end)

net.Receive("cs16_used_antidote", function(len)
    local ply = net.ReadEntity()

    Notification("left", 4, GetLangRep("NOTICE_ANTIDOTE", {{"%s", ply:Nick()}}), cs16_notif_human_color)

    create_dlight(ply, {
        b = 255,
        Size = 750,
        DieTime = CurTime() + 5
    })
end)

function reset_player(ply)
    ply.zombie_madness_til = 0
    ply.cloaked_til = 0
    ply.is_nemesis = false
    
    if ply:CS16Team() == nil then
        ply.cs16_team = team_id
    end
end

function CalcDlightSize(size, pos)
    local dist = LocalPlayer():GetPos():Distance(pos)
    return math.Clamp(size - (dist / 6), 0, size)
end

local function create_dlight(ent, tab, calcsize)
    local pos = ent:GetShootPos()
    local dlight = DynamicLight(ent:EntIndex())
    if dlight then
        dlight.pos = pos
        dlight.r = 0
        dlight.g = 0
        dlight.b = 0
        dlight.brightness = 5
        dlight.Decay = 1000
        dlight.Size = 500
        dlight.DieTime = CurTime() + 1

        for k,v in pairs(tab) do
            if calcsize and (k == "Size") then
                dlight[k] = CalcDlightSize(v, pos)
            else
                dlight[k] = v
            end
        end
    end
end

next_cloak_sound = 0

hook.Add("Tick", "CS16_ZM_TickStuff", function()
    local client = LocalPlayer()
    if !client.Nick then return end

    local skip_nvg = false
    local nvg_person = client
    if client:IsSpectator() and IsValid(client:GetObserverTarget()) and client:GetObserverMode() == OBS_MODE_IN_EYE then
        nvg_person = client:GetObserverTarget()
    end


    for k,ply in pairs(player.GetAll()) do
        if ply.ZM_Initialized == nil then
            reset_player(ply)
            ply.ZM_Initialized = true
        end

        if ply:IsZombie() and ply:Alive() then
            if ply.zombie_madness_til > CurTime() or ply.is_nemesis then
                if ply.is_nemesis and ply != nvg_person then
                    create_dlight(ply, {
                        r = 255,
                        Size = 300
                    }, true)
                else
                    create_dlight(ply, {
                        r = 15,
                        Size = 512
                    }, true)
                end
                if ply == nvg_person then
                    skip_nvg = true
                end
            end
        end
    end

    if client.cloaked_til > CurTime() then
        local time = math.abs(math.Round(CurTime() - client.cloaked_til))
        StartGreenNotification({"Cloaked for: "..tostring(time)}, true)

        if (CurTime() - next_cloak_sound) > 0 then
            surface.PlaySound("weapons/flashbang-2.wav")
            next_cloak_sound = CurTime() + 5
        end
    end

    if skip_nvg then
        return
    end

    if (nvg_person:GetNWBool("HasNVG", false) and nvg_person.CS16_NVG_ENABLED) or nvg_person:HasZombieClaws() then
        create_dlight(nvg_person, {
            g = 25,
            Size = 512,
            brightness = 3
        })
        return
    end

    if nvg_person:IsSurvivor() then
        create_dlight(nvg_person, {
            r = 55,
            g = 55,
            b = 55,
            Size = 512,
            brightness = 3
        })
    else
        create_dlight(nvg_person, {
            r = 35,
            g = 35,
            b = 35,
            Size = 256,
            brightness = 2
        })
    end
end)

--NVG STUFF
function SUBGAMEMODE:NVG_EFFECTS()
    local client = LocalPlayer()
    local nvg_person = client
    if client:IsSpectator() and IsValid(client:GetObserverTarget()) and client:GetObserverMode() == OBS_MODE_IN_EYE then
        nvg_person = client:GetObserverTarget()
    end

    if !nvg_person.zombie_madness_til then return end
    
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

    
    if nvg_person.zombie_madness_til > CurTime() or nvg_person.is_nemesis then
        nvg_info.contrast = 1.5
        nvg_info.add_r = 0.15
        nvg_info.clr_r = 0.9
        nvg_info.brightness = -0.2
        return nvg_info
    end

    local nvg_enabled = (nvg_person:GetNWBool("HasNVG", false) and nvg_person.CS16_NVG_ENABLED)
    if nvg_enabled or nvg_person:HasZombieClaws() then
        nvg_info.contrast = 2.5
        nvg_info.add_g = 0.15
        nvg_info.clr_g = 0.9
        nvg_info.brightness = -0.2
        return nvg_info
    end

    if game_state == GAMESTATE_PREPARING then
        nvg_info.contrast = 1.5
        nvg_info.brightness = 0.02
        return nvg_info
    end
end

include("cl_hud_scoreboard.lua")
include("cl_hud_buy_items.lua")
include("sh_player_ext.lua")
include("sh_round_types.lua")
include("cl_model_effects.lua")

print("Gamemode loaded gamemodes/zombie_mod/cl_init.lua")