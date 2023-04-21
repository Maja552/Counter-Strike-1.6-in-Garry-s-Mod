
function SUBGAMEMODE:LastHuman(ply)
    if !CS16_ZM_FiredLastHuman and game_state == GAMESTATE_ROUND then
        CS16_ZM_FiredLastHuman = true
        Notification("upper", 4, GetLangRep("NOTICE_LASTHUMAN", {{"%s", ply:Nick()}}), Color(255,0,0, 200))
        for k,v in pairs(team.GetPlayers(TEAM_T)) do
            if v:Alive() and !v:IsSpectator() then
                v:StopLastRandomZSound()
                v:EmitSound(GetCS16Sound("LAST_HUMAN_LEFT"), 75, 100, 0.7)
                v.nextRandomZSound = CurTime() + 10
            end
        end
    end
end

function SUBGAMEMODE:LastHumanCheck(ply)
    if !ZM_RoundType().last_human_enabled then return end

    local humans = {}
    for k,v in pairs(team.GetPlayers(TEAM_CT)) do
        if v != ply and v:Alive() and !v:IsSpectator() then
           table.ForceInsert(humans, v)
        end
    end
    if table.Count(humans) == 1 then
        self:LastHuman(humans[1])
    end
end

-- Before the player's death
function SUBGAMEMODE:DoPlayerDeath(ply, attacker, dmginfo)
	ply:AddDeaths(1)
	if attacker:IsValid() and attacker:IsPlayer() then
		if attacker == ply or ply:Team() == attacker:Team() then
			attacker:AddFrags(-1)
			attacker:AddMoney(-500, true)
		else
			attacker:AddFrags(1)
			attacker:AddMoney(500, true)
		end
	end
	
	ply:DropAllWeapons()

    if ply:Team() == TEAM_CT then
        SUBGAMEMODE:LastHumanCheck(ply)
        if !ZM_RoundType().zombies_infect then
            ply.zombie_lives = 0
        end
    end
end

-- After the player's death
function SUBGAMEMODE:PostPlayerDeath(ply)
    --GAMEMODE:DEFAULT_PostPlayerDeath(ply)
    --if ply:Team() == TEAM_SPECTATOR then
        --ply:SetSpectator()
    --end
end

function SUBGAMEMODE:CanPlayerSuicide(ply)
    if game_state != GAMESTATE_ROUND then
        return false
    end
    return !ply:IsSpectator()
end

-- Player ded
function SUBGAMEMODE:PlayerDeath(ply, inflictor, attacker)
    GAMEMODE:DEFAULT_PlayerDeath(ply, inflictor, attacker)
    if ply:IsZombie() then
        ply.WasZombie = CurTime() + 11
    end
    if game_state == GAMESTATE_ROUND and ply:CS16Team() != TEAM_SPECTATOR and ply.zombie_lives > 0 and ZM_RoundType().allow_zombie_spawning then
        ply.NextSpawnTime = CurTime() + 10
    
        local str = "lives"
        if ply.zombie_lives == 1 then
            str = "life"
        end
        ply:OldPrintMessage(GetLangRep("NOTICE_ZOMBIESPAWN_LIVES", {{"%n", ply.zombie_lives}, {"%t", 10}, {"%s", str}}))
    else
        ply:SetTeam(TEAM_UNASSIGNED)
        ply.NextSpawnTime = CurTime() + 1
        --ply:OldPrintMessage(GetLang("NOTICE_SPAWN"))
    end
end

-- When the player is dead
function SUBGAMEMODE:PlayerDeathThink(ply)
	if not ply.NextSpawnTime or ply.NextSpawnTime > CurTime() then return end

	--if ply:IsBot() or ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP) then
        if ply.zombie_lives > 0 and game_state == GAMESTATE_ROUND and ply:CS16Team() != TEAM_SPECTATOR and ZM_RoundType().allow_zombie_spawning then
            local spawn_point = GAMEMODE:GetRandomAfterSpawnpoint(ply)
            if IsValid(spawn_point) then
                ply:SetTeam(TEAM_T)
                ply:Spawn()
                ply:SetZombie(false, false)
                --ZMTEST ply:SetPos(spawn_point:GetPos())
                ply:SetPos(spawn_point:GetPos())
                return
            else
                for i=1, 5 do
                    ErrorNoHalt("COULDNT FIND A SPAWNPOINT FOR: ".. ply:Nick())
                end
            end
        end
        ply:SetTeam(TEAM_UNASSIGNED)
        ply:Spawn()
	--end
end

-- The corpse death sound, better position
function SUBGAMEMODE:DoCorpseDeathSound(ply, corpse)
    if ply:IsZombie() then
        ply:StopLastRandomZSound()
        corpse:EmitSound(GetCS16Sound("ZOMBIE_DIE"))
        return true
    end
    return GAMEMODE:DEFAULT_DoCorpseDeathSound(ply, corpse)
end

-- The death sound
function SUBGAMEMODE:PlayerDeathSound(ply)
    return GAMEMODE:DEFAULT_PlayerDeathSound(ply)
end

print("Gamemode loaded gamemodes/zombie_mod/sv_player_death.lua")