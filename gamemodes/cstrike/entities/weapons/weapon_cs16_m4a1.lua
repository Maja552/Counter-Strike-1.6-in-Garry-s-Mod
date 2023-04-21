if CLIENT then
	SWEP.PrintName			= "Maverick M4A1 Carbine"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/m4a1_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_m4a1", "cs/sprites/m4a1_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_M4A1_WEIGHT
SWEP.HoldType			= "ar2"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_m4a1.mdl")
SWEP.PModel				= Model("models/cs/p_m4a1.mdl")
SWEP.WModel				= Model("models/cs16/w_m4a1.mdl")
SWEP.VModel				= Model("models/weapons/cs16/v_m4a1.mdl")
--SWEP.VModel				= Model("models/cs/v_m4a1.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldM4A1.Shot1")
SWEP.Primary.EmptySound		= Sound("OldRifle.DryFire")
SWEP.Primary.ClipSize		= CS16_M4A1_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_M4A1_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_556NATO"
SWEP.Primary.Automatic		= true

SWEP.Secondary.Sound 		= Sound("OldM4A1.Shot1_Silenced")

SWEP.AnimPrefix 			= "rifle"
SWEP.MaxSpeed 				= CS16_M4A1_MAX_SPEED

if !gmod.GetGamemode().IsCStrike then
	SWEP.Slot			= 2
	SWEP.SlotPos		= 0
	SWEP.PModel			= Model("models/weapons/cs16/player/p_m4a1.mdl")
end

function SWEP:OnSetupDataTables()
	self:NetworkVar("Bool", 5, "Silenced")
end

function SWEP:OnDeploy()
	local vm = self.Owner:GetViewModel()
	local anim = self:GetSilenced() and "draw" or "draw_unsil"

	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))

	self:SetAccuracy(0.2)
	self:SetTimeWeaponIdle(CurTime() + 1.5)
end

function SWEP:PrimaryAttack()
	if self:GetSilenced() then
		if !self.Owner:IsOnGround() then
			self:M4A1Fire(0.035 + (0.4 * self:GetAccuracy()), 0.0875)
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:M4A1Fire(0.035 + (0.07  * self:GetAccuracy()), 0.0875)
		else
			self:M4A1Fire(0.025 * self:GetAccuracy(), 0.0875)
		end
	else
		if !self.Owner:IsOnGround() then
			self:M4A1Fire(0.035 + (0.4 * self:GetAccuracy()), 0.0875)
		elseif self.Owner:GetVelocity():Length2D() > 0 then
			self:M4A1Fire(0.035 + (0.07 * self:GetAccuracy()), 0.0875)
		else
			self:M4A1Fire(0.02 * self:GetAccuracy(), 0.0875)
		end
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire() then 
		return
	end

	local silenced = !self:GetSilenced()
	self:SetSilenced(silenced)
	self:SendWeaponAnim(silenced and ACT_VM_ATTACH_SILENCER or ACT_VM_DETACH_SILENCER)

	self:SetTimeWeaponIdle(CurTime() + 2)
	self:SetNextAttack(CurTime() + 2)
end

function SWEP:FireAnimation()
	local anim = self:GetSilenced() and ACT_VM_PRIMARYATTACK_SILENCED or ACT_VM_PRIMARYATTACK
	
	self:SendWeaponAnim(anim)
end

function SWEP:RecalculateAccuracy()
	self:SetAccuracy(((self:GetShotsFired() * self:GetShotsFired() * self:GetShotsFired()) / 220) + 0.3)
end

function SWEP:M4A1Fire(flSpread, flCycleTime)
	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	self:SetDelayFire(true)
	self:SetShotsFired(self:GetShotsFired() + 1)
	self:RecalculateAccuracy()

	if self:GetAccuracy() > 1 then
		self:SetAccuracy(1)
	end

	self:FireAnimation()
	self:TakePrimaryAmmo(1)

	local attachment = self:GetSilenced() and 1 or 3
	local muzzle_type = self:GetSilenced() and 11 or 22
	self:CS16_MuzzleFlash(muzzle_type, 30, attachment)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_M4A1_DISTANCE, CS16_M4A1_PENETRATION, "CS16_556NATO", self:GetSilenced() and CS16_M4A1_DAMAGE_SIL or CS16_M4A1_DAMAGE, self:GetSilenced() and CS16_M4A1_RANGE_MODIFER_SIL or CS16_M4A1_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())

	local snd = self:GetSilenced() and self.Secondary.Sound or self.Primary.Sound
	self:EmitSound(snd)

	self:CreateShell(1, "1")

	self:SetNextAttack(CurTime() + flCycleTime)
	self:SetTimeWeaponIdle(CurTime() + 1)

	if !self.Owner:IsOnGround() then
		self:KickBack(1.2, 0.5, 0.23, 0.15, 5.5, 3.5, 6)
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack(1.0, 0.45, 0.28, 0.045, 3.75, 3.0, 7)
	elseif self.Owner:Crouching() then
		self:KickBack(0.6, 0.3, 0.2, 0.0125, 3.25, 2.0, 7)
	else
		self:KickBack(0.65, 0.35, 0.25, 0.015, 3.5, 2.25, 7)
	end
end

function SWEP:Reload()
	if self:GetInReload() then
		return 
	end

	if CLIENT and !IsFirstTimePredicted() then 
		return 
	end

	local anim = self:GetSilenced() and ACT_VM_RELOAD_SILENCED or ACT_VM_RELOAD
	if self:CS16_DefaultReload(CS16_M4A1_MAX_CLIP, anim, CS16_M4A1_RELOAD_TIME) then
		self:SetAccuracy(0.2)
		self:SetShotsFired(0)
	end
end

function SWEP:WeaponIdle()
	if self:GetTimeWeaponIdle() > CurTime() then
		return
	end

	local anim = self:GetSilenced() and ACT_VM_IDLE_SILENCED or ACT_VM_IDLE
	self:SetTimeWeaponIdle(CurTime() + 20)
	self:SendWeaponAnim(anim)
end

if CLIENT then
	function SWEP:GetShellDir(attach)
		local ShellVelocity, ShellOrigin = Vector(), Vector()
		local velocity = self.Owner:GetVelocity()
		local punchangle = self.Owner:CS16_GetViewPunch()
		local angles = self.Owner:EyeAngles()
		angles.x = punchangle.x + angles.x
		angles.y = punchangle.y + angles.y

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 20, -8, self.ViewModelFlip and 10 or -10, false)

		return ShellOrigin, ShellVelocity, angles.y
	end
end