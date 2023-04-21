
function ZM_RoundType()
    return CS16_ZM_ROUNDTYPES[CS16_ZM_CurrentRoundType]
end

if CS16_NEXT_SPECIAL_ROUND == 0 then
    CS16_NEXT_SPECIAL_ROUND = 4
end

CS16_ZM_SPECIAL_ROUNDTYPES = {
    "nemesis",
    "survivor",
    "swarm",
    "multiple_infections",
    "plague"
}

CS16_ZM_ROUNDTYPES = {
    default = {
        allow_zombie_spawning = true,
        zombies_infect = true,
        zombies_claw_damage_mul = 1,
        last_human_enabled = true,
        kill_last_human = true,
        min_players = 0,
        first_zombie_hp_mul = 1.3,
        beam_survivors = false,
        beam_nemesis = false,
        zombie_buymenu_enabled = true,
        zombie_classes_work = true,
        sv_post_round_start = function()
            local all_players = GAMEMODE:GetPlayers()
            local all_possible_zombies = {}
            for k,v in pairs(all_players) do
                if v:Alive() and !v:IsSpectator() then
                    v:SetTeam(TEAM_CT)
                    v.is_nemesis = false
                    table.ForceInsert(all_possible_zombies, v)
                end
            end

            local patient_zero = all_possible_zombies[math.random(#all_possible_zombies)]
            Notification("upper", 2, GetLangRep("NOTICE_FIRST", {{"%s", patient_zero:Nick()}}), Color(255,0,0, 200))
            patient_zero.is_nemesis = false
            patient_zero:SetZombie(true, false)

            patient_zero:ReturnSpentMoney()
        end,
        cl_post_round_start = function()
        end
    },
    nemesis = {
        allow_zombie_spawning = false,
        zombies_infect = false,
        zombies_claw_damage_mul = 2,
        last_human_enabled = true,
        kill_last_human = false,
        min_players = 6,
        first_zombie_hp_mul = 1, -- nemesis has its own health scaling
        beam_survivors = false,
        beam_nemesis = true,
        zombie_buymenu_enabled = false,
        zombie_classes_work = false,
        sv_post_round_start = function()
            local all_players = GAMEMODE:GetPlayers()
            local all_possible_zombies = {}
            for k,v in pairs(all_players) do
                if v:Alive() and !v:IsSpectator() then
                    v:SetTeam(TEAM_CT)
                    v.is_nemesis = false
                    table.ForceInsert(all_possible_zombies, v)
                end
            end
            
            local nemesis = all_possible_zombies[math.random(#all_possible_zombies)]
--nemesis = Entity(1)
            Notification("upper", 2, GetLangRep("NOTICE_NEMESIS", {{"%s", nemesis:Nick()}}), Color(255,0,0, 200))
            nemesis.is_nemesis = true
            nemesis:SetZombie(true, true)

            nemesis:ReturnSpentMoney()

            BeamPlayer(nemesis, 500, Color(255,0,0))
        end,
        cl_post_round_start = function()
            surface.PlaySound(GetCS16Sound("ROUND_NEMESIS"))
        end
    },
    survivor = {
        allow_zombie_spawning = false,
        zombies_infect = false,
        zombies_claw_damage_mul = 1,
        last_human_enabled = false,
        kill_last_human = false,
        min_players = 6,
        first_zombie_hp_mul = 1,
        beam_survivors = true,
        beam_nemesis = false,
        zombie_buymenu_enabled = false,
        zombie_classes_work = true,
        sv_post_round_start = function()
            local all_players = GAMEMODE:GetPlayers()
            local all_possible_survivors = {}
            for k,v in pairs(all_players) do
                if v:Alive() and !v:IsSpectator() then
                    table.ForceInsert(all_possible_survivors, v)
                end
            end
            
            local survivor = all_possible_survivors[math.random(#all_possible_survivors)]
--survivor = Entity(1)
            survivor:SetSurvivor()

            for k,v in pairs(all_possible_survivors) do
                if v != survivor then
                    v.is_nemesis = false
                    v:SetZombie(true, true)
                end
            end

            local notif_color = cs16_notif_human_color
            notif_color.a = 200
            Notification("upper", 2, GetLangRep("NOTICE_SURVIVOR", {{"%s", survivor:Nick()}}), notif_color)
            BeamPlayer(survivor, 500, cs16_survivor_beam_color)
        end,
        cl_post_round_start = function()
            surface.PlaySound(GetCS16Sound("ROUND_SURVIVOR"))
        end
    },
    swarm = {
        allow_zombie_spawning = true,
        zombies_infect = false,
        zombies_claw_damage_mul = 2,
        last_human_enabled = true,
        kill_last_human = true,
        min_players = 6,
        first_zombie_hp_mul = 1.3,
        beam_survivors = false,
        beam_nemesis = false,
        zombie_buymenu_enabled = false,
        zombie_classes_work = true,
        sv_post_round_start = function()
            local all_players = GAMEMODE:GetPlayers()
            local num_of_swarms = math.Round(math.Clamp(#all_players / 3, 2, 6))

            local all_possible_zombies = {}
            for k,v in pairs(all_players) do
                if v:Alive() and !v:IsSpectator() then
                    v:SetTeam(TEAM_CT)
                    v.is_nemesis = false
                    table.ForceInsert(all_possible_zombies, v)
                end
            end

            for i=1, num_of_swarms do
                local rnd_swarm = table.Random(all_possible_zombies)
                table.RemoveByValue(all_possible_zombies, rnd_swarm)

                rnd_swarm:SetZombie(true, true)
                rnd_swarm:ReturnSpentMoney()
            end

            Notification("upper", 2, GetLang("NOTICE_SWARM"), Color(0,255,0, 200))
        end,
        cl_post_round_start = function()
            surface.PlaySound(GetCS16Sound("ROUND_SWARM"))
        end
    },
    multiple_infections = {
        allow_zombie_spawning = true,
        zombies_infect = true,
        zombies_claw_damage_mul = 1,
        last_human_enabled = true,
        kill_last_human = true,
        min_players = 7,
        first_zombie_hp_mul = 1,
        beam_survivors = false,
        beam_nemesis = false,
        zombie_buymenu_enabled = true,
        zombie_classes_work = true,
        sv_post_round_start = function()
            local all_players = GAMEMODE:GetPlayers()
            local num_of_infections = math.Round(math.Clamp(#all_players / 4, 2, 5))

            local all_possible_zombies = {}
            for k,v in pairs(all_players) do
                if v:Alive() and !v:IsSpectator() then
                    v:SetTeam(TEAM_CT)
                    v.is_nemesis = false
                    table.ForceInsert(all_possible_zombies, v)
                end
            end

            for i=1, num_of_infections do
                local rnd_zombie = table.Random(all_possible_zombies)
                table.RemoveByValue(all_possible_zombies, rnd_swarm)

                rnd_zombie:SetZombie(false, true)
                rnd_zombie:ReturnSpentMoney()
            end

            Notification("upper", 2, GetLang("NOTICE_MULTI"), Color(0,255,0, 200))
        end,
        cl_post_round_start = function()
            surface.PlaySound(GetCS16Sound("ROUND_MULTI"))
        end
    },
    plague = {
        allow_zombie_spawning = true,
        zombies_infect = false,
        zombies_claw_damage_mul = 1,
        last_human_enabled = true,
        kill_last_human = true,
        min_players = 8,
        first_zombie_hp_mul = 1.3,
        beam_survivors = true,
        beam_nemesis = true,
        zombie_buymenu_enabled = false,
        zombie_classes_work = false,
        sv_post_round_start = function()
            local all_players = GAMEMODE:GetPlayers()
            local num_of_infections = math.Round(math.Clamp(#all_players / 3, 2, 5))

            local all_plys = {}
            for k,v in pairs(all_players) do
                if v:Alive() and !v:IsSpectator() then
                    v:SetTeam(TEAM_CT)
                    v.is_nemesis = false
                    table.ForceInsert(all_plys, v)
                end
            end

            for i=1, num_of_infections do
                local rnd_zombie = table.Random(all_plys)
                table.RemoveByValue(all_plys, rnd_swarm)

                rnd_zombie:SetZombie(true, true)
                rnd_zombie:ReturnSpentMoney()
            end

            local nemesis = table.Random(all_plys)
            table.RemoveByValue(all_plys, nemesis)
            nemesis.is_nemesis = true
            nemesis:SetZombie(true, true)
            nemesis:ReturnSpentMoney()

            local num_of_survivors = 1
            if #all_players > 10 then
                num_of_survivors = 2
            end

            for i=1, num_of_survivors do
                local survivor = table.Random(all_plys)
                table.RemoveByValue(all_plys, survivor)
                survivor:SetHuman()
                survivor:SetSurvivor(true, true)
                survivor:ReturnSpentMoney()
                survivor:AfterSetHuman()
            end

            Notification("upper", 2, GetLang("NOTICE_PLAGUE"), Color(0,255,0, 200))
        end,
        cl_post_round_start = function()
            surface.PlaySound(GetCS16Sound("ROUND_PLAGUE"))
        end
    },
}

print("Gamemode loaded gamemodes/zombie_mod/sh_round_types.lua")