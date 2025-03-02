
local meta_player = FindMetaTable("Player")

CL_BOBCYCLE = 0.8
CL_BOBUP = 0.5
CL_BOB = 0.01

local bob, bobcycle = 0, 0

function meta_player:CalcBob()
    local bobtime = CurTime()

    bobcycle = bobtime - math.floor((bobtime / CL_BOBCYCLE)) * CL_BOBCYCLE
    bobcycle = bobcycle / CL_BOBCYCLE

    if bobcycle < CL_BOBUP then
        bobcycle = math.pi * bobcycle / CL_BOBUP
    else
        bobcycle = math.pi + math.pi * (bobcycle - CL_BOBUP)/ (1.0 - CL_BOBUP)
    end
    
    local bobvel = self:GetVelocity()
    bobvel[3] = 0
    
    bob = math.sqrt(bobvel[1] * bobvel[1] + bobvel[2] * bobvel[2]) * CL_BOB
    bob = bob * 0.3 + bob * 0.7 * math.sin(bobcycle)
    bob = math.Clamp(bob, -7, 4)

    return bob
end

CS16_FOV = 80

function GM:CalcView(ply, pos, ang, fov)
    if !GM_INITIALIZED then return false end
	local view = {
		origin = pos,
		angles = ang,
		fov = fov,
		drawviewer = false
	}

    
    --view.fov = CS16_FOV
    if !ply:IsSpectator() and ply:Alive() then
        if !ply:ShouldDrawLocalPlayer() then
            local bob_int = ply:CalcBob()

            --view.origin[3] = view.origin[3] - 3
            view.origin[3] = view.origin[3] + bob_int
            
            if ply.CS16_GetViewPunch then
                local viewPunchMul = 1 + ply:GetNWFloat("jumpPenalty", 0)
                view.angles = view.angles + (ply:CS16_GetViewPunch() * viewPunchMul)
            end
        end

        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep.OnCalcView then
            view.fov = wep:OnCalcView(view.ply, view.origin, view.angles, view.fov) or CS16_FOV
        end
    end

    return view
end

print("Gamemode loaded cl_view.lua")