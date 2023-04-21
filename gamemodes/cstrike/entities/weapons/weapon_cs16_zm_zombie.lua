if CLIENT then
	SWEP.PrintName			= "Knife"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/knife_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_zm_zombie", "cs/sprites/knife_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 2
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_KNIFE_WEIGHT
SWEP.HoldType			= "knife"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true
SWEP.ZombieWeapon 		= true
SWEP.IsZombieClaws 		= true

--SWEP.PModel				= Model("models/weapons/cs16/p_knife.mdl")
SWEP.PModel				= Model("models/cs/p_knife.mdl")
SWEP.WModel				= Model("models/cs16/w_knife.mdl")
--SWEP.VModel				= Model("models/v_knife_zombie.mdl")
SWEP.VModel				= Model("models/weapons/cs16/zombie_mod/v_knife_zombie.mdl")
--SWEP.VModel				= Model("models/cs/v_knife.mdl")

SWEP.PModelShield		= Model("models/weapons/cs16/shield/p_shield_knife.mdl")
SWEP.VModelShield		= Model("models/weapons/cs16/shield/v_shield_knife.mdl")

SWEP.ViewModelFlipHack	= true
SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 118

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Automatic		= true
SWEP.Secondary.Automatic	= true

SWEP.AnimPrefix 			= "knife"
SWEP.MaxSpeed 				= 325

if !gmod.GetGamemode().IsCStrike then
	SWEP.Slot			= 0
	SWEP.SlotPos		= 0
	SWEP.PModel			= Model("models/weapons/cs16/player/p_knife.mdl")
end

local function _Length2D(vec)
	return math.sqrt(vec.x * vec.x + vec.y * vec.y)
end
local function DotProduct2D(vec, vec2)
	return vec.x * vec2.x + vec.y * vec2.y
end
local function Normalize2D(vec)
	return Vector(vec.x / _Length2D(vec), vec.y / _Length2D(vec), 0)
end

function FindHullIntersection(vecSrc, tr, pflMins, pfkMaxs, pEntity)
	local	i, j, k
	local trTemp
	local flDistance = 1000000
	local pflMinMaxs = { pflMins, pfkMaxs }
	local vecHullEnd    = tr.HitPos

	vecHullEnd = vecSrc + ((vecHullEnd - vecSrc) * 2)
	trTemp = util.TraceLine({start = vecSrc, endpos = vecHullEnd, mask = MASK_SOLID, filter = pEntity})

	if trTemp.Fraction < 1 then
		tr = trTemp
		return
	end

	for i = 1 , 2 do
		for j = 1 , 2 do
			for k = 1 , 2 do
				local vecEnd = Vector()
				vecEnd.x = vecHullEnd.x + pflMinMaxs[i].x
				vecEnd.y = vecHullEnd.y + pflMinMaxs[j].y
				vecEnd.z = vecHullEnd.z + pflMinMaxs[k].z

				trTemp = util.TraceLine({start = vecSrc, endpos = vecEnd, mask = MASK_SOLID, filter = pEntity})

				if trTemp.Fraction < 1 then
					local flThisDistance = (trTemp.HitPos - vecSrc):Length()

					if flThisDistance < flDistance then
						tr = trTemp
						flDistance = flThisDistance
					end
				end
			end
		end
	end
end

function SWEP:DrawWorldModel()
end

function SWEP:OnSetupDataTables()
	self:NetworkVar("Int", 1, "Swing")
end

function SWEP:OnDeploy()
	if self.Owner:HasShield() then
		self.ViewModel = self.VModelShield
		self.Owner:GetViewModel():SetWeaponModel(self.ViewModel, self)
	else
		self.ViewModel = self.VModel
		self.Owner:GetViewModel():SetWeaponModel(self.ViewModel, self)
	end

	local vm = self.Owner:GetViewModel()

	vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_DRAW))

	self:SetSwing(0)
	self:SetTimeWeaponIdle(CurTime() + 4)
end

function SWEP:Swing(first)
	local DidHit = false

	local vecSrc = self.Owner:GetShootPos()
	local vecEnd = vecSrc + self.Owner:EyeAngles():Forward() * 48

	local tracedata = {}
	tracedata.start = vecSrc
	tracedata.endpos = vecEnd
	tracedata.filter = self.Owner
	tracedata.mask = MASK_SOLID
	local tr = util.TraceLine(tracedata)

	if tr.Fraction >= 1 then
		local tracedata = {}
		tracedata.start = vecSrc
		tracedata.endpos = vecEnd
		tracedata.mins = Vector(-16, -16, -18)
		tracedata.maxs = Vector(16, 16, 18)
		tracedata.filter = self.Owner
		tracedata.mask = MASK_SOLID
		tr = util.TraceHull(tracedata)

		if tr.Fraction < 1 then
			if !tr.Entity or tr.Entity:GetSolid() == SOLID_BSP then
				FindHullIntersection(vecSrc, tr, self.Owner:OBBMins(), self.Owner:OBBMaxs(), self.Owner)
			end

			vecEnd = tr.HitPos
		end
	end

	local vm = self.Owner:GetViewModel()

	if tr.Fraction >= 1 then
		if first then
			self:SetSwing(self:GetSwing() + 1)

			if !self.Owner:HasShield() then
				--local anim = (self:GetSwing() % 2) == 1 and "midslash2" or "midslash1"

				--vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))

				self:SetNextPrimaryFire(CurTime() + 0.35)
				self:SetNextSecondaryFire(CurTime() + 0.5)
			else
				--vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_MISSCENTER))

				self:SetNextPrimaryFire(CurTime() + 1)
				self:SetNextSecondaryFire(CurTime() + 1.2)
			end

			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			self.Owner:SetAnimation(PLAYER_ATTACK1)

			self:SetTimeWeaponIdle(CurTime() + 2)

			self:EmitSound(Sound("OldKnife.Slash"))
		end
	else
		DidHit = true

		self:SetSwing(self:GetSwing() + 1)
		if !self.Owner:HasShield() then
			local anim = (self:GetSwing() % 2) == 1 and "midslash2" or "midslash1"

			--vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))

			self:SetNextPrimaryFire(CurTime() + 0.4)
			self:SetNextSecondaryFire(CurTime() + 0.5)
		else
			--vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_HITCENTER))

			self:SetNextPrimaryFire(CurTime() + 1)
			self:SetNextSecondaryFire(CurTime() + 1.2)
		end

		self:SetTimeWeaponIdle(CurTime() + 2)

		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
		self.Owner:SetAnimation(PLAYER_ATTACK1)

		local info = DamageInfo()
		info:SetAttacker(self.Owner)
		info:SetInflictor(self)
		info:SetDamage(15)
		info:SetDamageType(bit.bor(DMG_BULLET , DMG_NEVERGIB))

		info:SetDamagePosition(tr.HitPos)
		info:SetDamageForce(Vector(0,0,23))
		tr.Entity:DispatchTraceAttack(info, tr, vForward)

		local flVol = 1

		if !tr.HitWorld and tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
			if tr.Entity:Armor() >= 50 then
				self:EmitSound("cstrike/player/bhit_kevlar-1.wav")
			else
				self:EmitSound(Sound("OldKnife.Hit"))
			end

			if tr.Entity:IsPlayer() and !tr.Entity:Alive() then
				return true
			end
		else
			self:EmitSound(Sound("OldKnife.HitWall"))
		end
	end

	return DidHit
end

function SWEP:Stab(first)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
	local DidHit = false
	local vecSrc = self.Owner:GetShootPos()
	local vecEnd = vecSrc + self.Owner:EyeAngles():Forward() * 32

	local tracedata = {}
	tracedata.start = vecSrc
	tracedata.endpos = vecEnd
	tracedata.filter = self.Owner
	tracedata.mask = MASK_SOLID
	local tr = util.TraceLine(tracedata)

	if tr.Fraction >= 1 then
		local tracedata = {}
		tracedata.start = vecSrc
		tracedata.endpos = vecEnd
		tracedata.mins = Vector(-16, -16, -18)
		tracedata.maxs = Vector(16, 16, 18)
		tracedata.filter = self.Owner
		tracedata.mask = MASK_SOLID
		tr = util.TraceHull(tracedata)

		if tr.Fraction < 1 then
			if !tr.Entity or tr.Entity:GetSolid() == SOLID_BSP then
				FindHullIntersection(vecSrc, tr, self.Owner:OBBMins(), self.Owner:OBBMaxs(), self.Owner)
			end

			vecEnd = tr.HitPos
		end
	end

	if tr.Fraction >= 1 then
		if first then
			--self:SendWeaponAnim(ACT_VM_MISSCENTER)

			self:SetNextAttack(CurTime() + 1)
			self:SetTimeWeaponIdle(CurTime() + 2)

			self:EmitSound(Sound("OldKnife.Slash"))
			self.Owner:SetAnimation(PLAYER_ATTACK1)
		end
	else
		DidHit = true

		--self:SendWeaponAnim(ACT_VM_HITCENTER2)

		self:SetNextAttack(CurTime() + 1.1)
		self:SetTimeWeaponIdle(CurTime() + 2)

		--self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
		self.Owner:SetAnimation(PLAYER_ATTACK1)

		local info = DamageInfo()
		info:SetAttacker(self.Owner)
		info:SetInflictor(self)
		info:SetDamage(65)

		info:SetDamagePosition(tr.HitPos)
		info:SetDamageForce(Vector(0,0,23))
		--if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
			--local vec2LOS = Vector()
			--local vecForward = self.Owner:EyeAngles():Forward()

			--vec2LOS = Vector(vecForward.x, vecForward.y, 0)
			--vec2LOS = Normalize2D(vec2LOS)
			--if DotProduct2D(vec2LOS, Vector(vecForward.x, vecForward.y, 0)) > 0.8 then
				--info:ScaleDamage(3)
			--end
		--end
		info:SetDamageType(bit.bor(DMG_BULLET , DMG_NEVERGIB))
		tr.Entity:DispatchTraceAttack(info, tr, vForward)

		local flVol = 1

		if !tr.HitWorld and tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
			self:EmitSound(Sound("OldKnife.Stab"))

			if tr.Entity:IsPlayer() and !tr.Entity:Alive() then
				return true
			end
		else
			self:EmitSound(Sound("OldKnife.HitWall"))
			
			self:SendWeaponAnim(ACT_VM_MISSCENTER)
			self.Owner:SetAnimation(PLAYER_ATTACK1)
		end
	end

	return DidHit
end

function SWEP:Reload()
	return false
end

function SWEP:PrimaryAttack()
	if self.Owner:IsShieldDrawn() then return end
	
	self.Owner:LagCompensation(true)
		self:Swing(true)
	self.Owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()
	if !self:ShieldSecondaryAttack() then
		self.Owner:LagCompensation(true)
			self:Swing(true)
			--self:Stab(true)
		self.Owner:LagCompensation(false)
	end
end

function SWEP:OnHolster()
	self:SetNextAttack(CurTime() + 1)
end

function SWEP:WeaponIdle()
	if self:GetTimeWeaponIdle() > CurTime() then
		return
	end

	if self.Owner:IsShieldDrawn() then
		return
	end
	
	self:SetTimeWeaponIdle(CurTime() + 20)
	
	if IsValid(self.Owner:GetViewModel()) and self.Owner:GetViewModel():GetSequence() != 0 then -- a bit hacky
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end

function SWEP:CanDrop()
	return false
end