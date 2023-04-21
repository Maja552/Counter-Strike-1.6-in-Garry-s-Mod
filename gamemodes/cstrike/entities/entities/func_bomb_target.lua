ENT.Base = "base_entity"
ENT.Type = "brush"
ENT.TeamNum = 0

function ENT:Initialize()
end

function ENT:StartTouch(entity)
end

function ENT:EndTouch(entity)
	if entity:IsPlayer() then
		entity.InBombZone = CurTime() - 1
		entity:SetNWBool("CanPlantBomb", false)
	end
end

function ENT:Touch(entity)
	if entity:IsPlayer() and entity.InBombZone < CurTime() then
		if entity:CanPlantBomb() then
			entity:SetNWBool("CanPlantBomb", true)
			entity.BombZone = self
		end
		entity.InBombZone = CurTime() + 1
	end
end

function ENT:PassesTriggerFilters(entity)
	return true
end

function ENT:KeyValue(key, value)
end

function ENT:Think()
end

function ENT:OnRemove()
end