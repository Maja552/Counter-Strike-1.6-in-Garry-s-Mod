
--hook.Add("Tick", "assblastUSA", function()
--    for k,v in pairs(player.GetAll()) do
        --v:PrintMessage(HUD_PRINTCENTER, tostring(Entity(6):GetPos()))
--    end
--end)

function BeamPlayer(ply, radius, color)
    local pos = ply:GetPos()
	local width = 64

    color.a = 32
	effects.BeamRingPoint(pos, 0.2, 12, radius, width, 0, color, {
		speed = 0,
		spread = 0,
		delay = 0,
		framerate = 2,
		material = "sprites/lgtning.vmt"
	})
	-- Shockring
    color.a = 64
	effects.BeamRingPoint(pos, 0.5, 12, radius, width, 0, color, {
		speed = 0,
		spread = 0,
		delay = 0,
		framerate = 2,
		material = "sprites/lgtning.vmt"
	})
end

function SAFE_RESET_SUBGAMEMODE()
    local half = #player.GetAll() / 2
    local team_tab = {}
    for i,v in ipairs(player.GetAll()) do
        if i <= half then
            v:SetCS16Team(TEAM_CT, false)
            v:SetTeam(TEAM_CT)
            table.ForceInsert(team_tab, {v, TEAM_CT})
        else
            v:SetCS16Team(TEAM_T, false)
            v:SetTeam(TEAM_T)
            table.ForceInsert(team_tab, {v, TEAM_T})
        end
        v:StripWeapons()
        v:RemoveAllAmmo()
    end

    net.Start("cs16_updateallteams")
        net.WriteTable(team_tab)
    net.Broadcast()

    round_state_end = CurTime() + GAMEMODE:GetPreparingTime()
    round_state_start = CurTime()
    round_module.PreparingStart()
    print("1 - preparing started")
end

print("Gamemode loaded gamemodes/zombie_mod/sv_util.lua")