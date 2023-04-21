if CLIENT then
	SWEP.PrintName			= "KM Sub-Machine Gun"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/mp5navy_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_mp5navy", "cs/sprites/mp5navy_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_MP5N_WEIGHT
SWEP.HoldType			= "ar2"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_mp5.mdl")
SWEP.PModel				= Model("models/cs/p_mp5.mdl")
SWEP.WModel				= Model("models/cs16/w_mp3.mdl")
SWEP.VModel				= Model("models/weapons/cs16/v_mp5.mdl")
--SWEP.VModel				= Model("models/cs/v_mp5.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldMP5.Shot1")
SWEP.Primary.EmptySound		= Sound("OldRifle.DryFire")
SWEP.Primary.ClipSize		= CS16_MP5N_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_MP5N_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_9MM"
SWEP.Primary.Automatic		= true

SWEP.AnimPrefix 			= "mp5"
SWEP.MaxSpeed 				= CS16_MP5N_MAX_SPEED
SWEP.Price 					= 1500

if !gmod.GetGamemode().IsCStrike then
	SWEP.Slot			= 2
	SWEP.SlotPos		= 0
	SWEP.PModel			= Model("models/weapons/cs16/player/p_mp5.mdl")
end

function SWEP:OnDeploy()
	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetAccuracy(0)
	self:SetTimeWeaponIdle(CurTime() + 4)
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:MP5NFire(0.2  * self:GetAccuracy(), 0.075)
	else
		self:MP5NFire(0.04 * self:GetAccuracy(), 0.075)
	end
end

function SWEP:FireAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:RecalculateAccuracy()
	self:SetAccuracy(((self:GetShotsFired() * self:GetShotsFired()) / 220.1) + 0.45)
end

function SWEP:MP5NFire(flSpread, flCycleTime)
	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	self:SetDelayFire(true)
	self:SetShotsFired(self:GetShotsFired() + 1)
	self:RecalculateAccuracy()

	if self:GetAccuracy() > 0.75 then
		self:SetAccuracy(0.75)
	end

	self:FireAnimation()
	self:TakePrimaryAmmo(1)

	self:CS16_MuzzleFlash(11, 30)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	self.Owner:FireBullets3(self, self.Owner:GetShootPos(), self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_MP5N_DISTANCE, CS16_MP5N_PENETRATION, "CS16_9MM", CS16_MP5N_DAMAGE, CS16_MP5N_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())

	self:EmitSound(self.Primary.Sound)

	self:CreateShell(0, 1)

	self:SetNextAttack(CurTime() + flCycleTime)
	self:SetTimeWeaponIdle(CurTime() + 2)

	if !self.Owner:IsOnGround() then
		self:KickBack(0.9, 0.475, 0.35, 0.0425, 5.0, 3.0, 6)
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:KickBack(0.5, 0.275, 0.2, 0.03, 3.0, 2.0, 10)
	elseif self.Owner:Crouching() then
		self:KickBack(0.225, 0.15, 0.1, 0.015, 2.0, 1.0, 10)
	else
		self:KickBack(0.25, 0.175, 0.125, 0.02, 2.25, 1.25, 10)
	end
end

function SWEP:Reload()
	if self:GetInReload() then
		return 
	end

	if CLIENT and !IsFirstTimePredicted() then 
		return 
	end

	if self:CS16_DefaultReload(CS16_MP5N_MAX_CLIP, ACT_VM_RELOAD, CS16_MP5N_RELOAD_TIME) then
		self:SetAccuracy(0)
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

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 36, -10, self.ViewModelFlip and 11 or -11, false)

		return ShellOrigin, ShellVelocity, angles.y
	end
end