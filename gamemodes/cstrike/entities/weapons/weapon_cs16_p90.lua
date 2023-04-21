if CLIENT then
	SWEP.PrintName			= "ES C90"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/p90_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_p90", "cs/sprites/p90_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_P90_WEIGHT
SWEP.HoldType			= "smg"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_p90.mdl")
SWEP.PModel				= Model("models/cs/p_p90.mdl")
SWEP.WModel				= Model("models/cs16/w_p90.mdl")
SWEP.VModel				= Model("models/weapons/cs16/c_p90.mdl")
--SWEP.VModel				= Model("models/cs/v_p90.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldP90.Shot1")
SWEP.Primary.EmptySound		= Sound("OldRifle.DryFire")
SWEP.Primary.ClipSize		= CS16_P90_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_P90_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_57MM"
SWEP.Primary.Automatic		= true

SWEP.AnimPrefix 			= "carbine"
SWEP.MaxSpeed 				= CS16_P90_MAX_SPEED
SWEP.Price 					= 2350

if !gmod.GetGamemode().IsCStrike then
	SWEP.Slot			= 2
	SWEP.SlotPos		= 0
	SWEP.PModel			= Model("models/weapons/cs16/player/p_p90.mdl")
end

function SWEP:OnDeploy()
	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetAccuracy(0.2)
	self:SetTimeWeaponIdle(CurTime() + 1.5)
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:P90Fire(0.3  * self:GetAccuracy(), 0.066)
	elseif self.Owner:GetVelocity():Length2D() > 170 then
		self:P90Fire(0.115 * self:GetAccuracy(), 0.066)
	else
		self:P90Fire(0.045 * self:GetAccuracy(), 0.066)
	end
end

function SWEP:FireAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:RecalculateAccuracy()
	self:SetAccuracy(((self:GetShotsFired() * self:GetShotsFired()) / 175) + 0.45)
end

function SWEP:P90Fire(flSpread, flCycleTime)
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

	self:CS16_MuzzleFlash(12, 40)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_P90_DISTANCE, CS16_P90_PENETRATION, "CS16_57MM", CS16_P90_DAMAGE, CS16_P90_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())

	self:EmitSound(self.Primary.Sound)

	self:CreateShell(1, "1")

	self:SetNextAttack(CurTime() + flCycleTime)
	self:SetTimeWeaponIdle(CurTime() + 2)

	if !self.Owner:IsOnGround() then
		self:KickBack(0.9, 0.45, 0.35, 0.04, 5.25, 3.5, 4)
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack(0.45, 0.3, 0.2, 0.0275, 4.0, 2.25, 7)
	elseif self.Owner:Crouching() then
		self:KickBack(0.275, 0.2, 0.125, 0.02, 3.0, 1.0, 9)
	else
		self:KickBack(0.3, 0.225, 0.125, 0.02, 3.25, 1.25, 8)
	end
end

function SWEP:Reload()
	if self:GetInReload() then
		return 
	end

	if CLIENT and !IsFirstTimePredicted() then 
		return 
	end

	if self:CS16_DefaultReload(CS16_P90_MAX_CLIP, ACT_VM_RELOAD, CS16_P90_RELOAD_TIME) then
		self:SetAccuracy(0.2)
		self:SetShotsFired(0)
	end
end

function SWEP:WeaponIdle()
	if self:GetTimeWeaponIdle() > CurTime() then
		return
	end

	self:SetTimeWeaponIdle(CurTime() + 20)
	self:SendWeaponAnim(ACT_VM_IDLE)
end

if CLIENT then
	function SWEP:GetShellDir(attach)
		local ShellVelocity, ShellOrigin = Vector(), Vector()
		local velocity = self.Owner:GetVelocity()
		local punchangle = self.Owner:CS16_GetViewPunch()
		local angles = self.Owner:EyeAngles()
		angles.x = punchangle.x + angles.x
		angles.y = punchangle.y + angles.y

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 35, -16, self.ViewModelFlip and 22 or -22, true)

		return ShellOrigin, ShellVelocity, angles.y
	end
end