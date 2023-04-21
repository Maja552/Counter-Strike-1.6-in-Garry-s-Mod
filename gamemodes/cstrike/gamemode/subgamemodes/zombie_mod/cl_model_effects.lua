
local function sync_bones(ply, ent)
    for i=0, (ent:GetBoneCount() - 1) do
        local bp, ba = ply:GetBonePosition(i)
        if bp == ply:GetPos() then
            local matrix = ply:GetBoneMatrix(i)
            if matrix then
                local bp2 = matrix:GetTranslation()
                local ba2 = matrix:GetAngles()
                bp2.z = bp2.z + 2
                bp2 = bp2 + (matrix:GetForward() * 5)
                ent:SetBonePosition(i, bp2, ba2)
            end
            continue
        end
        bp.z = bp.z + 2
        bp = bp + (ba:Forward() * 1)
        if bp and ba then
            ent:SetBonePosition(i, bp, ba)
        end
    end
end

GM:SubGamemodeHook_Add("PrePlayerDraw" , "should_draw_player_model", function(ply)
    if ply.cloaked_til == nil then
        reset_player(ply)
    end
    if ply.cloaked_til > CurTime() or game_state == GAMESTATE_NOTSTARTED then
        return true
    end
end)

GM:SubGamemodeHook_Add("PostPlayerDraw" , "cs16_second_model", function(ply)
    --local is_surv = ply:IsSurvivor()
    if (ply.frozen_for or 0) > CurTime() then
        ply.second_model_mat = "models/effects/splodearc_sheet"

    elseif ply:IsNemesis() then
        ply.second_model_mat = "models/props_combine/tprings_globe"
    else
        return
    end
    if !IsValid(ply.second_model) then
        ply.second_model = ClientsideModel(ply:GetModel())
        ply.second_model:SetNoDraw(true)
    end
    local model = ply.second_model:GetModel()
    local ply_model = ply:GetModel()
    if model != pply_model then
        ply.second_model:SetModel(ply_model)
    end

    ply.second_model:SetMoveType(MOVETYPE_NONE) 
    ply.second_model:SetParent(ply)

    local pos = ply:GetPos()
    local ang = ply:GetAngles()

	ply.second_model:SetModelScale(1, 0)
	--ply.second_model:SetPos(pos)
    --ply.second_model:SetAngles(ang)
	--ply.second_model:SetRenderOrigin(pos)
	--ply.second_model:SetRenderAngles(ang)
    ply.second_model:SetMaterial(ply.second_model_mat)
    ply.second_model:SetupBones()
	--ply.second_model:SetRenderOrigin()
	--ply.second_model:SetRenderAngles()

    ply.second_model:SetPredictable(true) 
    
    sync_bones(ply, ply.second_model)

    ply.second_model:DrawModel()
end)

print("Gamemode loaded gamemodes/zombie_mod/cl_model_effects.lua")