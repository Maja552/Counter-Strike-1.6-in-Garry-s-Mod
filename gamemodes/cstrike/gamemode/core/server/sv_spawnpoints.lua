
function GM:GetSpawnPointsFor(team_id, ply)
	if SUBGAMEMODE.CONFIG.UNIFIED_SPAWNPOINTS then
		return ents.FindByClass(SUBGAMEMODE.CONFIG.SPAWNPOINTS)

	elseif SUBGAMEMODE.CONFIG.SPAWNPOINTS[team_id] then
		return ents.FindByClass(SUBGAMEMODE.CONFIG.SPAWNPOINTS[team_id])
	end
    return nil
end

function GM:GetSuitableSpawnPoints(team_id)
	local suitable_spawns = {}
end

function GM:PlayerSelectTeamSpawn(team_id, ply)
	local all_spawn_points = self:GetSpawnPointsFor(team_id, ply)
	if !all_spawn_points or table.IsEmpty(all_spawn_points) then return end

	local shuffled_spawnpoints = {}

	local num_of_all_spawnpoints = #all_spawn_points
	local aall_spawn_points = table.Copy(all_spawn_points)

	for i=1, num_of_all_spawnpoints do
		local rnd_spawn_point = all_spawn_points[math.random(#all_spawn_points)]
		table.ForceInsert(shuffled_spawnpoints, rnd_spawn_point)
		table.remove(all_spawn_points, i)
	end

	local suitable_spawns = {}

	for i,v in ipairs(shuffled_spawnpoints) do
		--if hook.Call("IsSpawnpointSuitable", GAMEMODE, ply, v, i == num_of_all_spawnpoints)  then
		if hook.Call("IsSpawnpointSuitable", GAMEMODE, ply, v, false)  then
			/*
			if i == num_of_all_spawnpoints then
				print("BALLSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS")
				print("")
			end
			return v
			*/
			table.ForceInsert(suitable_spawns, v)
		end
	end

	print("")
	print("		"..ply:Nick(), "team_id: "..team_id, "spawns: "..table.Count(aall_spawn_points), "suitable: "..table.Count(suitable_spawns), "team size: "..table.Count(team.GetPlayers(team_id)))
	print("")

	return suitable_spawns[math.random(#suitable_spawns)]
end


function GM:IsSpawnpointEntSuitable(ply, spawn_point_ent)
	local pos = spawnpointent:GetPos()
	local all_ents = ents.FindInBox(pos + Vector(-16, -16, 0), pos + Vector(16, 16, 64))
	for k,v in pairs(all_ents) do
		if IsValid(v) and v != ply and v:IsPlayer() and v:Alive() and !v:IsSpectator() then
			return false
		end
	end
	return true
end

function GM:IsSpawnpointSuitable(ply, spawnpointent, force_spawn)
	local pos = spawnpointent:GetPos()
	local all_ents = ents.FindInBox(pos + Vector(-16, -16, 0), pos + Vector(16, 16, 64))

	if ply:Team() == TEAM_SPECTATOR then return true end

	local blockers = 0

	for k, v in pairs(all_ents) do
		if IsValid(v) and v != ply and v:IsPlayer() and v:Alive() and !v:IsSpectator() then
			blockers = blockers + 1

			if force_spawn then
				print(v, "IM BLOOOOOOOOOOOOOOOOOOOOOOOOKING")
				v:Kill()
			end
		end
	end

	if force_spawn then return true end
	if blockers > 0 then return false end
	return true
end

all_spawnpoint_classes = {
	"info_player_deathmatch",
	"info_player_combine",
	"info_player_rebel",
	"info_player_counterterrorist",
	"info_player_terrorist",
	"info_player_axis",
	"info_player_allies",
	"gmod_player_start",
	"info_player_teamspawn",
	"ins_spawnpoint",
	"aoc_spawnpoint",
	"dys_spawn_point",
	"info_player_pirate",
	"info_player_viking",
	"info_player_knight",
	"diprip_start_team_blue",
	"diprip_start_team_red",
	"info_player_red",
	"info_player_blue",
	"info_player_coop",
	"info_player_human",
	"info_player_zombie",
	"info_player_zombiemaster",
	"info_player_fof",
	"info_player_desperado",
	"info_player_vigilante",
	"info_survivor_rescue"
}
round_first_spawns = {}

local cached_all_spawnpoints = 2137

function GM:GetRandomSpawnPoint()
	local all_spawnpoints = {}
	if istable(cached_all_spawnpoints) then
		all_spawnpoints = cached_all_spawnpoints
	else
		for k,v in pairs(ents.GetAll()) do
			if table.HasValue(all_spawnpoint_classes, v:GetClass()) then
				table.ForceInsert(all_spawnpoints, v)
			end
		end
		cached_all_spawnpoints = table.Copy(all_spawnpoints)
	end
	return all_spawnpoints[math.random(#all_spawnpoints)]
end

function GM:ShuffleFirstTeamPlayerSpawns()
	round_first_spawns = {}
	if SUBGAMEMODE.CONFIG.UNIFIED_SPAWNPOINTS then
		round_first_spawns = table.Copy(ents.FindByClass(SUBGAMEMODE.CONFIG.SPAWNPOINTS))
	else
		for k,v in pairs(SUBGAMEMODE.CONFIG.SPAWNPOINTS) do
			round_first_spawns[k] = table.Copy(ents.FindByClass(v))
		end
	end
end

function GM:GetRandomAfterSpawnpoint(ply)
	local spawns_tab = true
	if SUBGAMEMODE.CONFIG.UNIFIED_SPAWNPOINTS then
		spawns_tab = table.Copy(ents.FindByClass(SUBGAMEMODE.CONFIG.SPAWNPOINTS))
	else
		spawns_tab = {}
		for k,v in pairs(SUBGAMEMODE.CONFIG.SPAWNPOINTS) do
			spawns_tab[k] = table.Copy(ents.FindByClass(v))
		end
	end

	if istable(spawns_tab) then
		local possible_spawns = {}
		for k, spawn in pairs(spawns_tab) do
			local blockers = 0
			for k2,pl in pairs(ents.FindInSphere(spawn:GetPos(), 68)) do
				if pl:IsPlayer() and pl != ply and pl:Alive() and !pl:IsSpectator() then
					blockers = blockers + 1
				end
			end
			if blockers == 0 then
				table.ForceInsert(possible_spawns, spawn)
			end
		end
		return possible_spawns[math.random(#possible_spawns)]
	end
end

function GM:PlayerSelectSpawn(ply)
	local spawns_tab = true
	if SUBGAMEMODE.CONFIG.UNIFIED_SPAWNPOINTS then
		spawns_tab = round_first_spawns
	else
		spawns_tab = round_first_spawns[ply:Team()]
	end

	if round_spawning and spawns_tab then
		local rnd_spawn = math.random(1, table.Count(spawns_tab))
		local ent = spawns_tab[rnd_spawn]
		table.remove(spawns_tab, rnd_spawn)
		return ent
	else
		return
	end
end

print("Gamemode loaded sv_spawnpoints.lua")