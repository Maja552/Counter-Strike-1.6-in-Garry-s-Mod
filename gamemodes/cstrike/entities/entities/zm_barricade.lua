AddCSLuaFile() 

ENT.PrintName = "Barricade"
ENT.Type = "anim"
ENT.Model = "models/props_junk/cardboard_box002a.mdl"
ENT.User = nil
ENT.IsBarricade = true
ENT.BlockInfectGrenade = true

function ENT:Touch(ply)
	if ply:IsPlayer() and !ply:IsZombie() then
		ply.slow_down = CurTime() + 0.1
	end
end

function ENT:Initialize()
	--self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	
	self:SetCustomCollisionCheck(true)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		--phys:Wake()
	end
	self:CollisionRulesChanged(true)
	self:SetCustomCollisionCheck(true)
	self:EnableCustomCollisions(true)

	if SERVER then
		self:SetTrigger(true)
	end
end

function ENT:Explode()
	local pos = self:GetPos()
	local data = EffectData()
	data:SetOrigin(pos)
	data:SetEntity(self)
	util.Effect("cs16_explosion_smoke", data)
	util.Effect("cs16_explosion", data)
	self:EmitSound(GetCS16Sound("BARRICADE_BREAK_SOUND"))
end

function ENT:OnTakeDamage(damage)
	local attacker = damage:GetAttacker()
	if attacker:IsPlayer() and attacker:Team() == TEAM_T and game_state == GAMESTATE_ROUND then
		self:SetHealth(self:Health() - damage:GetDamage())
		if self:Health() < 0 then
			self:Explode()
			self:Remove()
			attacker:OldPrintMessage("")
		else
			attacker:OldPrintMessage("Barricade health: "..self:Health())
		end
		if self:GetMaterialType() == MAT_WOOD then
			self:EmitSound("physics/wood/wood_plank_break"..math.random(1,3)..".wav")

		elseif self:GetMaterialType() == MAT_DIRT then
			self:EmitSound("barricades/metal"..math.random(1,5)..".wav")
		end
	end
end

