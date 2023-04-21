ENT.Base = "base_entity"
ENT.Type = "brush"
ENT.TeamNum = 0

local TEAMS_NONE = 0
local TEAMS_ALL = 1
local TEAMS_T = 2
local TEAMS_CT = 3

function ENT:Initialize()
end

function ENT:StartTouch(ply)
	if ply:IsPlayer() and !ply.purchase_notif_fired then
		ply:GreenNotification("Press the BUY key to purchase items.")
		ply.purchase_notif_fired = true
	end
end

function ENT:EndTouch(entity)
	if entity:IsPlayer() then
		entity.InBuyZone = CurTime() - 1
		entity:SetNWBool("CanBuy", false)
	end
end

function ENT:Touch(entity)
	if self.TeamNum and self.TeamNum > TEAMS_NONE and entity:IsPlayer() and entity.InBuyZone < CurTime() then
		if self.TeamNum == TEAMS_ALL or
			(self.TeamNum == TEAMS_T and entity:Team() == TEAM_T) or
			(self.TeamNum == TEAMS_CT and entity:Team() == TEAM_CT)
		then
			entity:SetNWBool("CanBuy", true)
			entity.BuyZone = self
		end
		entity.InBuyZone = CurTime() + 1
	end
end

function ENT:PassesTriggerFilters(entity)
	return true
end

function ENT:KeyValue(key, value)
	if key == "TeamNum" then
		self.TeamNum = tonumber(value)
	elseif key == "team" then
		self.Team = tonumber(value)
	end
end

function ENT:Think()
end

function ENT:OnRemove()
end