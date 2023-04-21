/*
util.AddNetworkString("cs16_killfeed")


function SendDeathNotice(victim, inflictor_class, attacker)
	net.Start("cs16_killfeed")
        -- Victim data
        if (victim:IsPlayer()) then
            net.WriteString(victim:Name())
            net.WriteColor(team.GetColor(victim:Team()))
        else
            net.WriteString(victim:GetClass())
            net.WriteColor(Color(255, 0, 0))
        end
        net.WriteBool(victim.csshud_headshot or false)

        -- Attacker data
        if (IsValid(attacker) and attacker:GetClass() != nil and attacker != victim) then
            if (attacker:IsPlayer() or attacker:IsNPC()) then
                -- Name
                if attacker:IsPlayer() then
                    net.WriteString(attacker:Name())
                    net.WriteColor(team.GetColor(attacker:Team()))
                else
                    net.WriteString(attacker:GetClass())
                    net.WriteColor(Color(255, 0, 0))
                end

                -- Weapon
                if IsValid(attacker:GetActiveWeapon()) then
                    net.WriteString(attacker:GetActiveWeapon():GetClass())
                else
                    net.WriteString(inflictor_class)
                end
            else
                net.WriteString(inflictor_class)
                net.WriteColor(Color(255, 0, 0))
            end
        else
            net.WriteString("")
            net.WriteColor(Color(255, 0, 0))
            net.WriteString("")
        end
	net.Broadcast()
end

-- Detect headshots
hook.Add("ScalePlayerDamage", "csshud_headshot", function(player, hitgroup, dmginfo)
	player.csshud_headshot = hitgroup == HITGROUP_HEAD
end)

hook.Add("ScaleNPCDamage", "csshud_headshot_npc", function(npc, hitgroup, dmginfo)
	npc.csshud_headshot = hitgroup == HITGROUP_HEAD
end)

-- Send death notice
hook.Add("PlayerDeath", "csshud_death", function(player, infl, attacker)
	SendDeathNotice(player, infl, attacker)
end)

hook.Add("OnNPCKilled", "csshud_death_npc", function(npc, attacker, infl)
	SendDeathNotice(npc, infl, attacker)
end)

-- Reset buffer data
hook.Add("PlayerSpawn", "csshud_spawn", function(player)
	player.csshud_headshot = nil
end)

*/