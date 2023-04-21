-- MODULE CONFIG
local corpse_velocity_multiplier = 1.5

-- MODULE INFO
--  Adds serverside function:
--   CreatePlayersRagdoll(victim, attacker, dmgtype, distance)



-- MODULE: Better corpse ragdolls
if SERVER then
    util.AddNetworkString("ColorPlayerCorpse")

    function CreatePlayersRagdoll(victim, attacker, dmgtype, distance)
        if !IsValid(victim) then return nil end

        local rag = ents.Create("prop_ragdoll")
        rag:SetPos(victim:GetPos())
        rag:SetModel(victim:GetModel())
        rag:SetAngles(victim:GetAngles())
        
        rag:Spawn()
        rag:Activate()
        
        rag:SetNWString("RagdollNick", victim:Nick())
        rag:SetNWInt("RagdollTeam", victim:Team())

        local group = COLLISION_GROUP_DEBRIS_TRIGGER
        rag:SetCollisionGroup(group)
        timer.Simple(1, function() if IsValid(rag) then rag:CollisionRulesChanged() end end)
        
        local num = rag:GetPhysicsObjectCount() - 1
        local v = victim:GetVelocity() * 0.35
        
        for i=0, num do
            local bone = rag:GetPhysicsObjectNum(i)
            if IsValid(bone) then
                local bp, ba = victim:GetBonePosition(rag:TranslatePhysBoneToBone(i))
                if bp and ba then
                    bone:SetPos(bp)
                    bone:SetAngles(ba)
                end
                bone:SetVelocity(v * corpse_velocity_multiplier)
            end
        end
        --victim:Spectate(OBS_MODE_IN_EYE)
        --victim:SpectateEntity(rag)
        return rag
    end

    hook.Add("DoPlayerDeath", "CorpseSystem_DoPlayerDeath", function(ply, attacker, dmginfo)
        ply.next_corpse_info = {attacker, dmginfo}
    end)

    hook.Add("PostPlayerDeath", "CorpseSystem_PostPlayerDeath", function(ply)
        local closest_corpse = nil
        for k,v in pairs(ents.FindByClass("hl2mp_ragdoll")) do
            local dist = v:GetPos():Distance(ply:GetPos())
            if closest_corpse == nil or dist < closest_corpse[2] then
                closest_corpse = {v, dist}
            end
        end
        if closest_corpse then
            closest_corpse[1]:Remove()
        end

        if ply.next_corpse_info then
            local attacker = ply.next_corpse_info[1]
            local dmginfo = ply.next_corpse_info[2]
            local dist = 0
            if IsValid(attacker) then
                dist = ply:GetPos():Distance(attacker:GetPos())
            end
            ply.corpse = CreatePlayersRagdoll(ply, attacker, dmginfo:GetDamageType(), dist)

            SUBGAMEMODE:DoCorpseDeathSound(ply, ply.corpse)
        end
    end)
end

print("Gamemode loaded module: Better corpse ragdolls")