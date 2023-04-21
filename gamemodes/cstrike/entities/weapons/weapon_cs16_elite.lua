if CLIENT then
	SWEP.PrintName			= ".40 Dual Elites"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/elite_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_elite", "cs/sprites/elite_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 1
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_ELITE_WEIGHT
SWEP.HoldType			= "duel"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_elite.mdl")
SWEP.PModel				= Model("models/cs/p_elite.mdl")
SWEP.WModel				= Model("models/cs16/w_elite.mdl")
SWEP.VModel				= Model("models/weapons/cs16/c_elites.mdl")
--SWEP.VModel				= Model("models/cs/v_elite.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldElites.Shot1")
SWEP.Primary.EmptySound		= Sound("OldPistol.DryFire")
SWEP.Primary.ClipSize		= CS16_ELITE_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_ELITE_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_9MM"

SWEP.AnimPrefix 			= "dual"
SWEP.MaxSpeed 				= CS16_ELITE_MAX_SPEED

--if !gmod.GetGamemode().IsCStrike then
	--SWEP.PModel			= Model("models/weapons/cs16/player/p_elite.mdl")
--end

function SWEP:OnSetupDataTables()
	self:NetworkVar("Bool", 5, "LeftMode")
end

function SWEP:OnDeploy()
	if bit.band(self:Clip1(), 1) == 0 then
		self:SetLeftMode(true)
	end

	self:SendWeaponAnim(ACT_VM_DRAW)
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)

	self:SetAccuracy(0.88)
	self:SetTimeWeaponIdle(CurTime() + 1)
end

function SWEP:PrimaryAttack()
	if !self.Owner:IsOnGround() then
		self:ELITEFire(1.3 * (1 - self:GetAccuracy()), 0.2)
	elseif self.Owner:GetVelocity():Length2D() > 0 then
		self:ELITEFire(0.175 * (1 - self:GetAccuracy()), 0.2)
	elseif self.Owner:Crouching() then
		self:ELITEFire(0.08 * (1 - self:GetAccuracy()), 0.2)
	else
		self:ELITEFire(0.1 * (1 - self:GetAccuracy()), 0.2)
	end
end

local shoot_leftlast = "shoot_leftlast"
local shoot_rightlast = "shoot_rightlast"
function SWEP:FireAnimation(left)
	local vm = self.Owner:GetViewModel()
	local empty = self:GetLeftMode() and vm:LookupSequence(shoot_leftlast) or vm:LookupSequence(shoot_rightlast)
	local shoot = self:GetLeftMode() and vm:SelectWeightedSequence(ACT_VM_SECONDARYATTACK) or vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK)
	local anim = (self:Clip1() == 1 or self:Clip1() == 2) and empty or shoot

	vm:SendViewModelMatchingSequence(anim)
end

function SWEP:ELITEFire(flSpread, flCycleTime)
	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	flCycleTime = flCycleTime - 0.125

	self:SetShotsFired(self:GetShotsFired() + 1)

	if self:GetShotsFired() > 1 then
		return
	end

	if self:GetLastFire() != 0 then
		self:SetAccuracy(math.Clamp(self:GetAccuracy() - (0.325 - (CurTime() - self:GetLastFire())) * 0.275, 0.55, 0.88))
	end

	self:SetLastFire(CurTime())
	self:FireAnimation(self:GetLeftMode())
	self:TakePrimaryAmmo(1)

	self:SetNextAttack(CurTime() + flCycleTime)

	if self:GetLeftMode() then
		self:CS16_MuzzleFlash(11, 15)
		self.Owner:SetAnimation(PLAYER_ATTACK1)

		self:SetLeftMode(false)

		self.Owner:FireBullets3(self, self.Owner:GetShootPos() + self.Owner:GetRight() * 5, self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_ELITE_DISTANCE, CS16_ELITE_PENETRATION, "CS16_9MM", CS16_ELITE_DAMAGE, CS16_ELITE_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())
		self:CreateShell("pshell", "2")
	else
		self:CS16_MuzzleFlash(11, 15, 2, 2)
		self.Owner:DoAnimationEvent(551)

		self:SetLeftMode(true)

		self.Owner:FireBullets3(self, self.Owner:GetShootPos() - self.Owner:GetRight() * 5, self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch(), flSpread, CS16_ELITE_DISTANCE, CS16_ELITE_PENETRATION, "CS16_9MM", CS16_ELITE_DAMAGE, CS16_ELITE_RANGE_MODIFER, self.Owner, true, self.Owner:EntIndex())
		self:CreateShell(0, "3")
	end
	
	self:EmitSound(self.Primary.Sound)

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

	if self:CS16_DefaultReload(CS16_ELITE_MAX_CLIP, ACT_VM_RELOAD, CS16_ELITE_RELOAD_TIME) then
		self:SetAccuracy(0.88)
	end
end

local idle_leftempty = "idle_leftempty"
local idle = "idle"
function SWEP:WeaponIdle()
	if self:GetTimeWeaponIdle() > CurTime() then
		return
	end

	if self:Clip1() != 0 then 
		local vm = self.Owner:GetViewModel()
		local anim = self:Clip1() == 1 and idle_leftempty or idle

		self:SetTimeWeaponIdle(CurTime() + 3.0625)
		vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
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

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 35, -11, (self:GetLeftMode() and 16 or -16), false)

		return ShellOrigin, ShellVelocity, angles.y
	end
end