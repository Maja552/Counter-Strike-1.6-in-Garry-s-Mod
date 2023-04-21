
net.Receive("cs16_zm_roundstart", function(len)
    --CS16_ZM_CurrentRoundType = net.ReadString()
    --CS16_ZM_ROUNDTYPES[CS16_ZM_CurrentRoundType]["cl_post_round_start"]()

    RunConsoleCommand("gsrchud_theme", "Counter-Strike")
    RunConsoleCommand("fov", "100")

    --surface.PlaySound(round_start_sounds[math.random(#round_start_sounds)])
    system.FlashWindow()
end)

net.Receive("cs16_zm_prepstart", function(len)
    local tab = net.ReadTable()

    for k,v in pairs(tab) do
        v[1].cs16_team = v[2]
    end

    force_remove_buymenu()
    for k,ply in pairs(player.GetAll()) do
        reset_player(ply)
        --SPECT_PMChanged(ply)
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
    local attacker = net.ReadEntity()
    local infected_is_nemesis = net.ReadBool()
    --infected.is_nemesis = infected_is_nemesis
    create_zombie_dlight(infected:GetPos() + Vector(0,0,50), infected, 0.3)

    --SPECT_PMChanged(infected) ????

    if IsValid(attacker) and attacker:IsPlayer() then
        GAMEMODE:AddDeathNotice(attacker:Nick(), TEAM_T, attacker:GetActiveWeapon():GetClass(), infected:Nick(), TEAM_CT)
    end
end)

print("Gamemode loaded gamemodes/zombie_plague/cl_networking.lua")