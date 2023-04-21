if CLIENT then
	SWEP.PrintName			= "CV-47"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/ak47_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_ak47", "cs/sprites/ak47_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_AK47_WEIGHT
SWEP.HoldType			= "ar2"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_ak47.mdl")
SWEP.PModel				= Model("models/cs/p_ak47.mdl")
SWEP.WModel				= Model("models/cs16/w_ak47.mdl")
SWEP.VModel				= Model("models/weapons/cs16/v_ak47.mdl")
--SWEP.VModel				= Model("models/cs/v_ak47.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldAK47.Shot1")
SWEP.Primary.EmptySound		= Sound("OldRifle.DryFire")
SWEP.Primary.ClipSize		= CS16_AK47_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_AK47_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_762NATO"
SWEP.Primary.Automatic		= true

SWEP.AnimPrefix 			= "ak47"
SWEP.MaxSpeed 				= CS16_AK47_MAX_SPEED

if !gmod.GetGamemode().IsCStrike then
	SWEP.Slot			= 2
	SWEP.SlotPos		= 0
	SWEP.PModel			= Model("models/weapons/cs16/player/p_ak47.mdl")
end

function SWEP:OnDeploy()
	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetAccuracy(0.2)
	self:SetTimeWeaponIdle(CurTime() + 1.5)
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:AK47Fire(0.04 + (0.4 * self:GetAccuracy()), 0.0955)
	elseif self.Owner:GetVelocity():Length2D() > 140 then
		self:AK47Fire(0.04 + (0.07 * self:GetAccuracy()), 0.0955)
	else
		self:AK47Fire(0.0275 * self:GetAccuracy(), 0.0955)
	end
end

function SWEP:FireAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:RecalculateAccuracy()
	self:SetAccuracy(0.35 + ((self:GetShotsFired() * self:GetShotsFired() * self:GetShotsFired()) / 200))
end

function SWEP:AK47Fire(flSpread, flCycleTime)
	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	self:SetDelayFire(true)
	self:SetShotsFired(self:GetShotsFired() + 1)
	self:RecalculateAccuracy()

	if self:GetAccuracy() > 1.25 then
		self:SetAccuracy(1.25)
	end

	self:FireAnimation()
	self:TakePrimaryAmmo(1)

	self:CS16_MuzzleFlash(22, 40)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	local vecDir = self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_AK47_DISTANCE, CS16_AK47_PENETRATION, "CS16_762NATO", CS16_AK47_DAMAGE, CS16_AK47_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())

	self:EmitSound(self.Primary.Sound)

	self:CreateShell(1, "1")

	self:SetNextAttack(CurTime() + flCycleTime)
	self:SetTimeWeaponIdle(CurTime() + 1.9)

	if !self.Owner:IsOnGround() then
		self:KickBack(2.0, 1.0, 0.5, 0.35, 9.0, 6.0, 5)
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack(1.5, 0.45, 0.225, 0.05, 6.5, 2.5, 7)
	elseif self.Owner:Crouching() then
		self:KickBack(0.9, 0.35, 0.15, 0.025, 5.5, 1.5, 9)
	else
		self:KickBack(1.0, 0.375, 0.175, 0.0375, 5.75, 1.75, 8)
	end
end

function SWEP:Reload()
	if self:GetInReload() then
		return 
	end

	if CLIENT and !IsFirstTimePredicted() then 
		return 
	end

	if self:CS16_DefaultReload(CS16_AK47_MAX_CLIP, ACT_VM_RELOAD, CS16_AK47_RELOAD_TIME) then
		self:SetAccuracy(0.2)
		self:SetShotsFired(0)
		self:SetDelayFire(false)
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

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 20, -8, self.ViewModelFlip and 10 or -10, false)

		return ShellOrigin, ShellVelocity, angles.y
	end
end