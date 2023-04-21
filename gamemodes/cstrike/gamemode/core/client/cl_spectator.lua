
function SPECT_PMChanged(ply)
    local client = LocalPlayer()
    if client:IsSpectator() and client:GetObserverTarget() == ply and client:GetObserverMode() == OBS_MODE_IN_EYE then
        SPECT_NextMode()
    end
end

net.Receive("cs16_pmchanged", function(len)
    local ent = net.ReadEntity()
    SPECT_PMChanged(ent)
end)

--inputs
function SPECT_PrimaryAttack()
    local client = LocalPlayer()
    local obs_mode = client:GetObserverMode()

    if obs_mode == OBS_MODE_ROAMING then
        SPECT_SpectPlayer(true, true)
    else
        SPECT_SpectPlayer(true, false)
    end
end

function SPECT_SecondaryAttack()
    local client = LocalPlayer()
    local obs_mode = client:GetObserverMode()

    if obs_mode == OBS_MODE_ROAMING then
        SPECT_SpectPlayer(false, true)
    else
        SPECT_SpectPlayer(false, false)
    end
end

local function can_spect_player(ply)
    return (ply != LocalPlayer() and ply:Team() != TEAM_SPECTATOR and ply:Team() != TEAM_UNASSIGNED and ply:CS16Team() != TEAM_SPECTATOR and ply:Alive())
end

local next_spect_check = 0

--hooks
hook.Add("Tick", "CS16_SpectateTick", function()
    local client = LocalPlayer()
    if !GM_INITIALIZED or !client.Team then return end
    if client:Team() == TEAM_SPECTATOR and client:Alive() and next_spect_check < CurTime() then
        next_spect_check = CurTime() + 0.1
        local obs_target = client:GetObserverTarget()
        if IsValid(obs_target) and !can_spect_player(obs_target) then
            --SPECT_SpectPlayer(true, false)
            --if !IsValid(obs_target) then
                net.Start("cs16_changespectmode")
                    net.WriteInt(OBS_MODE_ROAMING, 8)
                net.SendToServer()
                next_spect_check = CurTime() + 1
            --end
        end
    end
end)

--actions
function SPECT_NextMode()
    local client = LocalPlayer()
    local obs_mode = client:GetObserverMode()
    local new_mode = nil

    if obs_mode == OBS_MODE_ROAMING then
        new_mode = OBS_MODE_CHASE
    elseif obs_mode == OBS_MODE_CHASE then
        new_mode = OBS_MODE_IN_EYE
    else
        new_mode = OBS_MODE_ROAMING
    end

    if new_mode then
        net.Start("cs16_changespectmode")
            net.WriteInt(new_mode, 8)
        net.SendToServer()
    end
end

our_spect_target = nil
next_spect_target_change = 0

function change_spect_target(ply)
    our_spect_target = ply
    next_spect_target_change = CurTime() + 0.25
end

function SPECT_SpectPlayer(next, roaming)
    local client = LocalPlayer()
    local obs_target = client:GetObserverTarget()
    local obs_mode = client:GetObserverMode()
    local plys = {}

    if obs_mode == OBS_MODE_ROAMING then
        obs_target = our_spect_target
    end

    for i,ply in ipairs(player.GetAll()) do
        if can_spect_player(ply) then
            table.ForceInsert(plys, ply)
        end
    end

    if #plys == 0 then return end

    if !IsValid(obs_target) and IsValid(plys[1]) then
        net.Start("cs16_spectply")
            net.WriteEntity(plys[1])
        net.SendToServer()
        change_spect_target(plys[1])
        return
    end

    for i,ply in ipairs(plys) do
        if ply == obs_target then
            local next_target = nil
            if next then
                if IsValid(plys[i+1]) then
                    next_target = plys[i+1]

                elseif IsValid(plys[1]) then
                    next_target = plys[1]
                end
            else
                if IsValid(plys[i-1]) then
                    next_target = plys[i-1]

                elseif IsValid(plys[#plys]) then
                    next_target = plys[#plys]
                end
            end

            if IsValid(next_target) then
                net.Start("cs16_spectply")
                    net.WriteEntity(next_target)
                net.SendToServer()
                change_spect_target(next_target)
            end
            return
        end
    end
end

print("Gamemode loaded cl_spectator.lua")