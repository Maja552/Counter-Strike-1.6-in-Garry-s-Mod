if CLIENT then
	SWEP.PrintName			= "M249"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/m249_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_m249", "cs/sprites/m249_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_M249_WEIGHT
SWEP.HoldType			= "smg"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_m249.mdl")
SWEP.PModel				= Model("models/cs/p_m249.mdl")
SWEP.WModel				= Model("models/cs16/w_m249.mdl")
SWEP.VModel				= Model("models/weapons/cs16/v_m249.mdl")
--SWEP.VModel				= Model("models/cs/v_m249.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldM249.Shot1")
SWEP.Primary.EmptySound		= Sound("OldRifle.DryFire")
SWEP.Primary.ClipSize		= CS16_M249_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_M249_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_556NATOBOX"
SWEP.Primary.Automatic		= true

SWEP.AnimPrefix 			= "m249"
SWEP.MaxSpeed 				= CS16_M249_MAX_SPEED
SWEP.Price 					= 5750

if !gmod.GetGamemode().IsCStrike then
	SWEP.Slot			= 2
	SWEP.SlotPos		= 0
	SWEP.PModel			= Model("models/weapons/cs16/player/p_m249.mdl")
end

function SWEP:OnDeploy()
	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetAccuracy(0.2)
	self:SetTimeWeaponIdle(CurTime() + 1.5)
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:M249Fire(0.045 + (0.5 * self:GetAccuracy()), 0.1)
	elseif self.Owner:GetVelocity():Length2D() > 140 then
		self:M249Fire(0.045 + (0.095 * self:GetAccuracy()), 0.1)
	else
		self:M249Fire(0.03 * self:GetAccuracy(), 0.1)
	end
end

function SWEP:FireAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:RecalculateAccuracy()
	self:SetAccuracy(((self:GetShotsFired() * self:GetShotsFired() * self:GetShotsFired()) / 175) + 0.4)
end

function SWEP:M249Fire(flSpread, flCycleTime)
	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	self:SetDelayFire(true)
	self:SetShotsFired(self:GetShotsFired() + 1)
	self:RecalculateAccuracy()

	if self:GetAccuracy() > 0.9 then
		self:SetAccuracy(0.9)
	end

	self:FireAnimation()
	self:TakePrimaryAmmo(1)

	self:CS16_MuzzleFlash(22, 50)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_M249_DISTANCE, CS16_M249_PENETRATION, "CS16_556NATOBOX", CS16_M249_DAMAGE, CS16_M249_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())

	self:EmitSound(self.Primary.Sound)

	self:CreateShell(1, "1")

	self:SetNextAttack(CurTime() + flCycleTime)
	self:SetTimeWeaponIdle(CurTime() + 1.6)

	if !self.Owner:IsOnGround() then
		self:KickBack(1.8, 0.65, 0.45, 0.125, 5.0, 3.5, 8)
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack(1.1, 0.5, 0.3, 0.06, 4.0, 3.0, 8)
	elseif self.Owner:Crouching() then
		self:KickBack(0.75, 0.325, 0.25, 0.025, 3.5, 2.5, 9)
	else
		self:KickBack(0.8, 0.35, 0.3, 0.03, 3.75, 3.0, 9)
	end
end

function SWEP:Reload()
	if self:GetInReload() then
		return 
	end

	if CLIENT and !IsFirstTimePredicted() then 
		return 
	end

	if self:CS16_DefaultReload(CS16_M249_MAX_CLIP, ACT_VM_RELOAD, CS16_M249_RELOAD_TIME) then
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

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 20, -10, self.ViewModelFlip and -13 or 13, false)

		return ShellOrigin, ShellVelocity, angles.y
	end
end