
local meta_player = FindMetaTable("Player")

function meta_player:CalculateSpeeds()
    local ply = self
    local frozen = ply.frozen_for > CurTime()
    if frozen or ply.ArmingC4 > CurTime() or (SUBGAMEMODE.CONFIG.PREPARING_FREEZE and game_state == GAMESTATE_PREPARING) then
        new_walk_speed = 2
        new_jump_power = 2
        --ply:SetLocalVelocity(Vector(0,0,0))
        return new_walk_speed, new_jump_power
    end

    local new_walk_speed = ply.speed_walking
    local new_jump_power = ply.jump_power
    local on_ground = ply:IsOnGround()
    if SUBGAMEMODE.CONFIG.JUMP_PENTALY_ENABLED then
        if !on_ground and ply.jumped then
            local jumpVel = ply:GetVelocity():Length()
            if ply.maxJumpVel < jumpVel then
                ply.maxJumpVel = jumpVel
            end
        end

        if ply.jumpPenaltyStage == 1 then
            new_walk_speed = ply.jumpPenaltyMinSpeed
            new_jump_power = ply.jumpPenaltyMinSpeed
            if ply.jumpPenaltyUntil < CurTime() then
                ply.jumpPenaltyUntil = CurTime() + 2
                ply.jumpPenaltyStage = 2
                return new_walk_speed, new_jump_power
            end
        elseif ply.jumpPenaltyStage == 2 then
            new_walk_speed = ply:GetWalkSpeed()
            --print('stage 2'..new_walk_speed)
            if ply.jumpPenaltyUntil < CurTime() then
                new_walk_speed = SUBGAMEMODE.CONFIG.DEFAULT_WALK_SPEED
                ply.jumpPenaltyStage = 0
                ply:SetNWFloat("jumpPenalty", 0)
            elseif ply.jumpPenaltyMaxSpeed > new_walk_speed then
                new_walk_speed = new_walk_speed + 5
            end
        end


        if !on_ground and !ply.jumped and ply:KeyDown(IN_JUMP) then
            ply.jumped = CurTime()
            ply.maxJumpVel = 0
            --ply:PrintMessage(HUD_PRINTTALK, "jumped")
        elseif on_ground and ply.jumped and CurTime() - ply.jumped > 0.5 and ply.maxJumpVel > 150 then
            local land_strength = math.Clamp(ply.maxJumpVel / 900, 0, 1)
            --ply:PrintMessage(HUD_PRINTTALK, "landed after: " .. CurTime() - ply.jumped.. " with maxJumpVel: "..ply.maxJumpVel)
            if ply.maxJumpVel > 350 and ply.jumped > 0.65 then
                ply.jumpPenaltyUntil = CurTime() + 0.15
                ply.jumpPenaltyStage = 1
                ply.jumpPenaltyMaxSpeed = SUBGAMEMODE.CONFIG.DEFAULT_WALK_SPEED
                ply.jumpPenaltyMinSpeed = 25
                --ply:ViewPunch(Angle(0, 0, math.Rand(0,5)))
                new_walk_speed = 5
                ply:SetNWFloat("jumpPenalty", land_strength)
            /*
            elseif ply.maxJumpVel > 250 and ply.jumped > 0.55 then
                ply.jumpPenaltyUntil = CurTime() + 0.1
                ply.jumpPenaltyStage = 1
                ply.jumpPenaltyMaxSpeed = SUBGAMEMODE.CONFIG.DEFAULT_WALK_SPEED
                ply.jumpPenaltyMinSpeed = SUBGAMEMODE.CONFIG.DEFAULT_WALK_SPEED * 0.5
                new_walk_speed = SUBGAMEMODE.CONFIG.DEFAULT_WALK_SPEED * 0.5
            */
            end
            ply.jumped = nil
            ply.maxJumpVel = 0
            --ply:SetNWFloat("jumpPenalty", land_strength)
        end
    end
    if ply:KeyDown(IN_SPEED) or ply:KeyDown(IN_WALK) or ply.slow_down > CurTime() then
        new_walk_speed = math.Clamp(new_walk_speed, 1, SUBGAMEMODE.CONFIG.DEFAULT_WALK_SPEED_SHIFT)
    end

    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep.GetMaxSpeed then
        new_walk_speed = math.Clamp(new_walk_speed, 1, wep:GetMaxSpeed())
    end

    return new_walk_speed, new_jump_power
end

print("Gamemode loaded sv_speeds.lua")