if CLIENT then
	SWEP.PrintName			= "Night Hawk .50c"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/deagle_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_zm_goldendeagle", "cs/sprites/deagle_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 1
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_DEAGLE_WEIGHT
SWEP.HoldType			= "pistol"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_deagle.mdl")
SWEP.PModel				= Model("models/cs/p_deagle.mdl")
SWEP.WModel				= Model("models/cs16/w_deagle.mdl")
SWEP.VModel				= Model("models/weapons/cs16/special/v_deagle_gold.mdl")
--SWEP.VModel				= Model("models/cs/v_deagle.mdl")

SWEP.PModelShield		= Model("models/weapons/cs16/shield/p_shield_deagle.mdl")
SWEP.VModelShield		= Model("models/weapons/cs16/shield/v_shield_deagle.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldDeagle.Shot1")
SWEP.Primary.EmptySound		= Sound("OldPistol.DryFire")
SWEP.Primary.ClipSize		= CS16_DEAGLE_MAX_CLIP + 3
SWEP.Primary.DefaultClip	= CS16_DEAGLE_MAX_CLIP + 3
SWEP.Primary.Ammo			= "CS16_50AE"

SWEP.AnimPrefix 			= "pistol"
SWEP.MaxSpeed 				= CS16_DEAGLE_MAX_SPEED
SWEP.Price 					= 650

if !gmod.GetGamemode().IsCStrike then
	SWEP.PModel			= Model("models/weapons/cs16/player/p_deagle.mdl")
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

	self:SetAccuracy(0.9)
	self:SetTimeWeaponIdle(CurTime() + 4)
end

function SWEP:PrimaryAttack()
	if self.Owner:IsShieldDrawn() then return end

	if !self.Owner:IsOnGround() then
		self:DEAGLEFire(1.5  * (1 - self:GetAccuracy()), 0.3)
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:DEAGLEFire(0.25 * (1 - self:GetAccuracy()), 0.3)
	elseif self.Owner:Crouching() then
		self:DEAGLEFire(0.115 * (1 - self:GetAccuracy()), 0.3)
	else
		self:DEAGLEFire(0.13 * (1 - self:GetAccuracy()), 0.3)
	end
end

function SWEP:FireAnimation()
	local vm = self.Owner:GetViewModel()
	local anim = self:Clip1() == 1 and ACT_VM_DRYFIRE or ACT_VM_PRIMARYATTACK

	vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(anim))
end

function SWEP:DEAGLEFire(flSpread, flCycleTime)
	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	flCycleTime = flCycleTime - 0.075

	self:SetShotsFired(self:GetShotsFired() + 1)

	if self:GetShotsFired() > 1 then
		return
	end

	if self:GetLastFire() != 0 then
		self:SetAccuracy(math.Clamp(self:GetAccuracy() - (0.4 - (CurTime() - self:GetLastFire())) * 0.35, 0.55, 0.9))
	end

	self:SetLastFire(CurTime())
	self:FireAnimation()
	self:TakePrimaryAmmo(1)

	self:CS16_MuzzleFlash(50, 15)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_DEAGLE_DISTANCE, CS16_DEAGLE_PENETRATION, "CS16_50AE", CS16_DEAGLE_DAMAGE * 1.2, CS16_DEAGLE_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())

	self:EmitSound(self.Primary.Sound)

	local eject = self.Owner:HasShield() and "0" or "1"
	self:CreateShell(0, eject)

	self.Owner:CS16_SetViewPunch(self.Owner:CS16_GetViewPunch() + Angle(-2, 0, 0), true)

	self:SetTimeWeaponIdle(CurTime() + 2)
	self:SetNextAttack(CurTime() + flCycleTime)
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire() then 
		return
	end

	if self:ShieldSecondaryAttack() then
		return
	end
end

function SWEP:Reload()
	if self:GetInReload() then
		return 
	end

	if CLIENT and !IsFirstTimePredicted() then 
		return 
	end

	if self:CS16_DefaultReload(CS16_DEAGLE_MAX_CLIP, ACT_VM_RELOAD, CS16_DEAGLE_RELOAD_TIME * 0.65, true) then
		self:SetAccuracy(0.9)
		self.Owner:GetViewModel():SetPlaybackRate(1.35)
	end
end

function SWEP:WeaponIdle()
	if self:GetTimeWeaponIdle() > CurTime() then
		return
	end

	if self.Owner.HasShield and self.Owner:HasShield() then
		local vm = self.Owner:GetViewModel()

		if self.Owner:IsShieldDrawn() then
			self:SetTimeWeaponIdle(CurTime() + 20)

			vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_SHIELD_UP_IDLE))
		end
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

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 35, -11, self.ViewModelFlip and 16 or -16, false)

		return ShellOrigin, ShellVelocity, angles.y
	end
end