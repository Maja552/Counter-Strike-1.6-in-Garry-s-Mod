if CLIENT then
	SWEP.PrintName			= "Ingram MAC-10"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/mac10_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_mac10", "cs/sprites/mac10_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_MAC10_WEIGHT
SWEP.HoldType			= "smg"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_mac10.mdl")
SWEP.PModel				= Model("models/cs/p_mac10.mdl")
SWEP.WModel				= Model("models/cs16/w_mac10.mdl")
SWEP.VModel				= Model("models/weapons/cs16/v_mac10.mdl")
--SWEP.VModel				= Model("models/cs/v_mac10.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldMAC10.Shot1")
SWEP.Primary.EmptySound		= Sound("OldRifle.DryFire")
SWEP.Primary.ClipSize		= CS16_MAC10_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_MAC10_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_45ACP"
SWEP.Primary.Automatic		= true

SWEP.AnimPrefix 			= "pistol"
SWEP.MaxSpeed 				= CS16_MAC10_MAX_SPEED

if !gmod.GetGamemode().IsCStrike then
	SWEP.Slot			= 2
	SWEP.SlotPos		= 0
	SWEP.PModel			= Model("models/weapons/cs16/player/p_mac10.mdl")
end

function SWEP:OnDeploy()
	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetAccuracy(0.15)
	self:SetTimeWeaponIdle(CurTime() + 1)
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:MAC10Fire(0.375  * self:GetAccuracy(), 0.07)
	else
		self:MAC10Fire(0.03 * self:GetAccuracy(), 0.07)
	end
end

function SWEP:FireAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:RecalculateAccuracy()
	self:SetAccuracy(((self:GetShotsFired() * self:GetShotsFired() * self:GetShotsFired()) / 200) + 0.6)
end

function SWEP:MAC10Fire(flSpread, flCycleTime)
	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	self:SetDelayFire(true)
	self:SetShotsFired(self:GetShotsFired() + 1)
	self:RecalculateAccuracy()

	if self:GetAccuracy() > 1.65 then
		self:SetAccuracy(1.65)
	end

	self:FireAnimation()

	self:TakePrimaryAmmo(1)

	self:CS16_MuzzleFlash(11, 10)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_MAC10_DISTANCE, CS16_MAC10_PENETRATION, "CS16_45ACP", CS16_MAC10_DAMAGE, CS16_MAC10_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())

	self:EmitSound(self.Primary.Sound)

	self:CreateShell(0, "1")

	self:SetNextAttack(CurTime() + flCycleTime)
	self:SetTimeWeaponIdle(CurTime() + 2)

	if !self.Owner:IsOnGround() then
		self:KickBack(1.3, 0.55, 0.4, 0.05, 4.75, 3.75, 5)
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack(0.9, 0.45, 0.25, 0.035, 3.5, 2.75, 7)
	elseif self.Owner:Crouching() then
		self:KickBack(0.75, 0.4, 0.175, 0.03, 2.75, 2.5, 10)
	else
		self:KickBack(0.775, 0.425, 0.2, 0.03, 3.0, 2.75, 9)
	end
end

function SWEP:Reload()
	if self:GetInReload() then
		return 
	end

	if CLIENT and !IsFirstTimePredicted() then 
		return 
	end

	if self:CS16_DefaultReload(CS16_MAC10_MAX_CLIP, ACT_VM_RELOAD, CS16_MAC10_RELOAD_TIME) then
		self:SetAccuracy(0.15)
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

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 32, -9, self.ViewModelFlip and 11 or -11, false)

		return ShellOrigin, ShellVelocity, angles.y
	end
end