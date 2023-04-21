
util.AddNetworkString("cs16_spectply")
util.AddNetworkString("cs16_changespectmode")

net.Receive("cs16_changespectmode", function(len, ply)
    if ply:Team() == TEAM_SPECTATOR and ply:Alive() then
        local new_obs_mode = net.ReadInt(8)
        if new_obs_mode == OBS_MODE_ROAMING or new_obs_mode == OBS_MODE_CHASE or new_obs_mode == OBS_MODE_IN_EYE then
            ply:Spectate(new_obs_mode)

            if new_obs_mode == OBS_MODE_IN_EYE then
                local obs_target = ply:GetObserverTarget()
                if IsValid(obs_target) then
                    ply:SetupHands(obs_target)
                end
            end
        end
    end
end)

net.Receive("cs16_spectply", function(len, ply)
    local ent = net.ReadEntity()
    if ply:Team() == TEAM_SPECTATOR and ply:Alive() and IsValid(ent) then
        if ply:GetObserverMode() == OBS_MODE_ROAMING then
            ply:SetPos(ent:GetPos() + Vector(0,0,60) - (ent:EyeAngles():Forward() * 25))
            ply:SetEyeAngles(ent:EyeAngles())
            
        elseif ent:Alive() and !ent:IsSpectator() then
            ply:SpectateEntity(ent)
        end
        ply:SetupHands(ent)
    end
end)

local function can_spect_player(client, ply)
    return (ply != client and ply:Team() != TEAM_SPECTATOR and ply:Team() != TEAM_UNASSIGNED and ply:Alive() and ply:CS16Team() != TEAM_SPECTATOR)
end

hook.Add("Tick", "CS16_SpectateTick", function()
    for i,ply in ipairs(player.GetAll()) do
        if ply:Team() == TEAM_SPECTATOR and ply:Alive() then
            local obs_target = ply:GetObserverTarget()
            if IsValid(obs_target) and ply:GetObserverMode() != OBS_MODE_ROAMING then
                ply:SetPos(obs_target:GetPos())
            end
        end
    end
end)


print("Gamemode loaded sv_spectator.lua")