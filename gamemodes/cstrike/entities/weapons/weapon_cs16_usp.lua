if CLIENT then
	SWEP.PrintName			= "KM .45 Tactical"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/usp_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_usp", "cs/sprites/usp_killicon", Color(255, 255, 255, 255))
end


SWEP.Slot				= 1
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_USP_WEIGHT
SWEP.HoldType			= "pistol"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_usp.mdl")
SWEP.PModel				= Model("models/cs/p_usp.mdl")
SWEP.WModel				= Model("models/cs16/w_usp.mdl")
SWEP.VModel				= Model("models/weapons/cs16/c_usp.mdl")
--SWEP.VModel				= Model("models/cs/v_usp.mdl")

SWEP.PModelShield		= Model("models/weapons/cs16/shield/p_shield_usp.mdl")
SWEP.VModelShield		= Model("models/weapons/cs16/shield/v_shield_usp.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldUSP.Shot1")
SWEP.Primary.EmptySound		= Sound("OldPistol.DryFire")
SWEP.Primary.ClipSize		= CS16_USP_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_USP_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_45ACP"

SWEP.Secondary.Sound		= Sound("OldUSP.Shot1_Silenced")

SWEP.AnimPrefix 			= "pistol"
SWEP.MaxSpeed 				= CS16_USP_MAX_SPEED
SWEP.Price 					= 500

if !gmod.GetGamemode().IsCStrike then
	SWEP.PModel			= Model("models/weapons/cs16/player/p_usp.mdl")
end

function SWEP:OnSetupDataTables()
	self:NetworkVar("Bool", 5, "Silenced")
end

function SWEP:OnDeploy()
	if self.Owner:HasShield() then
		self:SetSilenced(false)
		self.ViewModel = self.VModelShield
		self.Owner:GetViewModel():SetWeaponModel(self.ViewModel, self)
	else
		self.ViewModel = self.VModel
		self.Owner:GetViewModel():SetWeaponModel(self.ViewModel, self)
	end

	local vm = self.Owner:GetViewModel()
	local anim = self:GetSilenced() and ACT_VM_DRAW_SILENCED or ACT_VM_DRAW

	vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(anim))

	self:SetAccuracy(0.92)
	self:SetTimeWeaponIdle(CurTime() + 4)
end

function SWEP:PrimaryAttack()
	if self.Owner:IsShieldDrawn() then return end
	
	if self:GetSilenced() then
		if !self.Owner:IsOnGround() then
			self:USPFire(1.3 * (1 - self:GetAccuracy()), 0.225)
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:USPFire(0.25 * (1 - self:GetAccuracy()), 0.225)
		elseif self.Owner:Crouching() then
			self:USPFire(0.125 * (1 - self:GetAccuracy()), 0.225)
		else
			self:USPFire(0.15 * (1 - self:GetAccuracy()), 0.225)
		end
	else
		if !self.Owner:IsOnGround() then
			self:USPFire(1.2 * (1 - self:GetAccuracy()), 0.225)
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:USPFire(0.225 * (1 - self:GetAccuracy()), 0.225)
		elseif self.Owner:Crouching() then
			self:USPFire(0.08 * (1 - self:GetAccuracy()), 0.225)
		else
			self:USPFire(0.1 * (1 - self:GetAccuracy()), 0.225)
		end
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire() then 
		return
	end

	if self:ShieldSecondaryAttack() then
		return
	end

	if self:GetSilenced() then
		self:SetSilenced(false)
		self:SendWeaponAnim(ACT_VM_DETACH_SILENCER)
	else
		self:SetSilenced(true)
		self:SendWeaponAnim(ACT_VM_ATTACH_SILENCER)
	end

	self:SetTimeWeaponIdle(CurTime() + 3)
	self:SetNextAttack(CurTime() + 3)
end

function SWEP:FireAnimation()
	local vm = self.Owner:GetViewModel()
	local anim_empty = self:GetSilenced() and ACT_VM_DRYFIRE_SILENCED or ACT_VM_DRYFIRE
	local anim_shoot = self:GetSilenced() and ACT_VM_PRIMARYATTACK_SILENCED or ACT_VM_PRIMARYATTACK
	local anim = self:Clip1() == 1 and anim_empty or anim_shoot

	vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(anim))
end

function SWEP:USPFire(flSpread, flCycleTime)
	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	--flCycleTime = flCycleTime - 0.075
	flCycleTime = flCycleTime - 0.1

	self:SetShotsFired(self:GetShotsFired() + 1)

	if self:GetShotsFired() > 1 then
		return
	end

	if self:GetLastFire() != 0 then
		self:SetAccuracy(math.Clamp(self:GetAccuracy() - (0.3 - (CurTime() - self:GetLastFire())) * 0.275, 0.6, 0.92))
	end

	self:SetLastFire(CurTime())
	self:FireAnimation()
	self:TakePrimaryAmmo(1)
	self:SetNextAttack(CurTime() + flCycleTime)

	local attachment = self:GetSilenced() and 1 or 3
	attachment = self.Owner:HasShield() and 1 or attachment
	self:CS16_MuzzleFlash(11, 10, attachment, 1)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_USP_DISTANCE, CS16_USP_PENETRATION, "CS16_45ACP", self:GetSilenced() and CS16_USP_DAMAGE_SIL or CS16_USP_DAMAGE, CS16_USP_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())

	local sound = self:GetSilenced() and self.Secondary.Sound or self.Primary.Sound
	self:EmitSound(sound)

	local eject = self.Owner:HasShield() and "0" or "1"
	self:CreateShell(0, eject)

	self.Owner:CS16_SetViewPunch(self.Owner:CS16_GetViewPunch() + Angle(-2, 0, 0), true)

	self:SetTimeWeaponIdle(CurTime() + 2)
end

function SWEP:Reload()
	if self:GetInReload() then
		return 
	end

	if CLIENT and !IsFirstTimePredicted() then 
		return 
	end

	local anim = self:GetSilenced() and ACT_VM_RELOAD_SILENCED or ACT_VM_RELOAD

	if self:CS16_DefaultReload(CS16_USP_MAX_CLIP, anim, CS16_USP_RELOAD_TIME, true) then
		self:SetAccuracy(0.92)
	end
end

function SWEP:WeaponIdle()
	if self:GetTimeWeaponIdle() > CurTime() then
		return
	end

	if self.Owner.HasShield and self.Owner:HasShield() then
		self:SetTimeWeaponIdle(CurTime() + 20)

		if self.Owner:IsShieldDrawn() then
			local vm = self.Owner:GetViewModel()

			vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_SHIELD_UP_IDLE))
		end
	elseif self:Clip1() != 0 then 
		local anim = self:GetSilenced() and ACT_VM_IDLE_SILENCED or ACT_VM_IDLE

		self:SetTimeWeaponIdle(CurTime() + 3.0625)
		self:SendWeaponAnim(anim)
	end
end

function SWEP:IsPistol()
	return true
end

if CLIENT then
	function SWEP:GetShellDir(attach)
		local ShellVelocity, ShellOrigin = Vector(), Vector()
		local velocity = self.Owner:GetVelocity()
		local punchangle = self.Owner:CS16_GetViewPunch()
		local angles = self.Owner:EyeAngles()
		angles.x = punchangle.x + angles.x
		angles.y = punchangle.y + angles.y

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 36, -14, self.ViewModelFlip and 14 or -14, false)

		return ShellOrigin, ShellVelocity, angles.y
	end
end