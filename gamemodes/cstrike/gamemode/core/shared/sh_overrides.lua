
function GM:PlayerShouldTakeDamage(ply, attacker)
    return SUBGAMEMODE:PlayerShouldTakeDamage(ply, attacker)
end

/*
function GM:Move(ply, mv)
    local ang = mv:GetMoveAngles()
	local pos = mv:GetOrigin()
    local vel = mv:GetVelocity()
    
    --mv:SetOrigin(pos)

    local speed = 5
    
    local walk_speed = mv:GetForwardSpeed()
    walk_speed = 0.0001

    ply:PrintMessage(HUD_PRINTCENTER, walk_speed)

	vel = vel + ang:Forward() * mv:GetForwardSpeed() * speed
	vel = vel + ang:Right() * mv:GetSideSpeed() * speed
	vel = vel + ang:Up() * mv:GetUpSpeed() * speed

    mv:SetVelocity(vel)
    
    pos = pos + vel
    --mv:SetOrigin(Vector(0,0,0))
    if ply:KeyDown(IN_FORWARD) then
        mv:SetForwardSpeed(mv:GetForwardSpeed())
        --mv:SetOrigin(pos)
    end
    local balls = 2000
    ply:SetVelocity(Vector(math.tan(CurTime()), math.sin(CurTime()), math.cos(CurTime())) * balls)
    ply:PrintMessage(HUD_PRINTCENTER, tostring(ply:GetVelocity()))

	return false
end
*/

print("Gamemode loaded sh_overrides.lua")