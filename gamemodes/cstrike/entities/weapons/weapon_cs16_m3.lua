if CLIENT then
	SWEP.PrintName			= "Leone 12 Gauge Super"
	SWEP.Author				= "Schwarz Kruppzo"
end

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("cs/sprites/m3_selecticon")
	SWEP.DrawWeaponInfoBox = false
	SWEP.BounceWeaponIcon = false
	killicons_new.Add("weapon_cs16_m3", "cs/sprites/m3_killicon", Color(255, 255, 255, 255))
end

SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Base 				= "weapon_cs_base"
SWEP.Weight				= CS16_M3_WEIGHT
SWEP.HoldType			= "shotgun"

SWEP.Category			= "Counter-Strike"
SWEP.Spawnable			= true

--SWEP.PModel				= Model("models/weapons/cs16/p_m3.mdl")
SWEP.PModel 			= Model("models/cs/p_m3.mdl")
SWEP.WModel				= Model("models/cs16/w_m3.mdl")
SWEP.VModel				= Model("models/weapons/cs16/c_m3.mdl")
--SWEP.VModel				= Model("models/cs/v_m3.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PModel

SWEP.Primary.Sound			= Sound("OldM3.Shot1")
SWEP.Primary.EmptySound		= Sound("OldRifle.DryFire")
SWEP.Primary.ClipSize		= CS16_M3_MAX_CLIP
SWEP.Primary.DefaultClip	= CS16_M3_MAX_CLIP
SWEP.Primary.Ammo			= "CS16_BUCKSHOT"
SWEP.Primary.Automatic		= true

SWEP.AnimPrefix 			= "shotgun"
SWEP.MaxSpeed 				= CS16_M3_MAX_SPEED
SWEP.Price 					= 1700

if !gmod.GetGamemode().IsCStrike then
	SWEP.Slot			= 3
	SWEP.SlotPos		= 0
	SWEP.PModel			= Model("models/weapons/cs16/player/p_m3.mdl")
end

function SWEP:OnSetupDataTables()
	self:NetworkVar("Float", 6, "EjectBrass")
	self:NetworkVar("Int", 1, "InSpecialReload")
	self:NetworkVar("Float", 7, "PumpTime")
	self:NetworkVar("Float", 8, "_nextFire")
end

function SWEP:OnDeploy()
	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetTimeWeaponIdle(CurTime() + 4)
end

function SWEP:PrimaryAttack()
	if self.Owner:WaterLevel() == 3 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.15)

		return
	end

	if CurTime() < self:Get_nextFire() then 
		return 
	end

	if self:Clip1() <= 0 then
		self:EmitSound(self.Primary.EmptySound)
		self:SetNextPrimaryFire(CurTime() + 0.2)

		return
	end

	self:SetDelayFire(true)
	self:SetShotsFired(self:GetShotsFired() + 9)
	self:FireAnimation()

	self:TakePrimaryAmmo(1)

	self:CS16_MuzzleFlash(21, 50)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + (self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch()):Forward() * 3000
	tracedata.mask = MASK_SHOT
	tracedata.filter = self.Owner
	local tr = util.TraceLine(tracedata)
	
	local currentDamage = 0
	if tr.Fraction != 1 then
		currentDamage = ((1 - tr.Fraction) * 20)
	end

	local shootAngles = self.Owner:EyeAngles() + self.Owner:CS16_GetViewPunch()
	local vecDirShooting = shootAngles:Forward()
	local vecRight = shootAngles:Right()
	local vecUp = shootAngles:Up()

	for i = 1, 9 do
		x = util.SharedRandom("SpreadX1"..i, -0.5, 0.5) + util.SharedRandom("SpreadX2"..i, -0.5, 0.5)
		y = util.SharedRandom("SpreadY1"..i, -0.5, 0.5) + util.SharedRandom("SpreadY2"..i, -0.5, 0.5)

		local vecDir = vecDirShooting + (x * CS16_VECTOR_CONE_M3.x * vecRight) + (y * CS16_VECTOR_CONE_M3.y * vecUp)
		vecDir:Normalize()

		local bullet = {}
		bullet.Num = 1
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = vecDir
		bullet.Spread = Vector(0, 0, 0)
		bullet.Distance = 3000
		bullet.Tracer = 0
		bullet.Force = 2
		bullet.Damage = currentDamage
		bullet.AmmoType = "CS16_BUCKSHOT"
		bullet.Callback = cvars.Number("cs16_sv_impact") == 1 and CS16_BulletCallBack or nil
		self.Owner:FireBullets(bullet)
	end

	self:EmitSound(self.Primary.Sound)

	if self:Clip1() > 0 then
		self:SetPumpTime(CurTime() + 0.5)
	end

	self:SetNextAttack(CurTime() + 0.875)
	self:SetTimeWeaponIdle(CurTime() + ((self:Clip1() > 0) and 2.5 or 0.875))
	self:SetInSpecialReload(0)

	if IsFirstTimePredicted() then
		local angle = self.Owner:CS16_GetViewPunch()
		angle.p = angle.p - (self.Owner:IsOnGround() and util.SharedRandom("PunchP", 4, 6) or util.SharedRandom("PunchP", 8, 11))

		self.Owner:CS16_SetViewPunch(angle)
	end

	self:SetEjectBrass(CurTime() + 0.45)
end

function SWEP:FireAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:Reload()
	local infinite_ammo = SUBGAMEMODE.CONFIG.INFINITE_AMMO
	if (!infinite_ammo and (self:Ammo1() <= 0)) or self:Clip1() == CS16_M3_MAX_CLIP then
		return false
	end
	if self:GetNextPrimaryFire() > CurTime() then 
		return false
	end

	if self:GetInSpecialReload() == 0 then
		self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
		self:SetInSpecialReload(1)

		self:SetNextAttack(CurTime() + 0.1)
		self:SetTimeWeaponIdle(CurTime() + 0.4)

	elseif self:GetInSpecialReload() == 1 then
		if self:GetTimeWeaponIdle() > CurTime() then
			return false
		end

		self:SetInSpecialReload(2)
		self:SendWeaponAnim(ACT_VM_RELOAD)

		self:SetTimeWeaponIdle(CurTime() + 0.4)
	else
		self:SetClip1(self:Clip1() + 1)
		if !infinite_ammo then
			self.Owner:RemoveAmmo(1, self.Primary.Ammo)
		end

		self:SetInSpecialReload(1)
		self:Set_nextFire(CurTime() + 0.35)
	end

	self.Owner:GetViewModel():SetPlaybackRate(1.25)

	return true
end

function SWEP:OnThink()
	if self:GetEjectBrass() != 0 and CurTime() >= self:GetEjectBrass() and IsFirstTimePredicted() then
		self:CreateShell(2, "1")
		self:SetEjectBrass(0)
	end
end

function SWEP:WeaponIdle()
	if self:GetTimeWeaponIdle() > CurTime() then
		return
	end

	if self:GetPumpTime() != 0 and self:GetPumpTime() < CurTime() then
		self:SetPumpTime(0)
	end
	
	local can_reload = (self:Ammo1() > 0 or SUBGAMEMODE.CONFIG.INFINITE_AMMO)

	if self:GetTimeWeaponIdle() < CurTime() then
		if self:Clip1() == 0 and self:GetInSpecialReload() == 0 and can_reload then
			self:Reload()
		elseif self:GetInSpecialReload() != 0 then
			if self:Clip1() != CS16_M3_MAX_CLIP and can_reload then
				self:Reload()
			else
				self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
				self:SetInSpecialReload(0)
				self:SetTimeWeaponIdle(CurTime() + 1.5)
				self:Set_nextFire(0)
			end
		else
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end
end

if CLIENT then
	function SWEP:GetShellDir(attach, ang)
		local angvel = VectorRand() * 1000

		return angvel, Vector(), -attach.Ang:Forward() * math.Rand(1, 2) + ang:Up() * math.Rand(1, 2.3) + ang:Forward() * math.Rand(1, 2)
	end
end

if CLIENT then
	function SWEP:GetShellDir(attach)
		local ShellVelocity, ShellOrigin = Vector(), Vector()
		local velocity = self.Owner:GetVelocity()
		local punchangle = self.Owner:CS16_GetViewPunch()
		local angles = self.Owner:EyeAngles()
		angles.x = punchangle.x + angles.x
		angles.y = punchangle.y + angles.y

		ShellVelocity, ShellOrigin = CS16_GetDefaultShellInfo(self.Owner, attach, velocity, ShellVelocity, ShellOrigin, angles, 16, -9, self.ViewModelFlip and 9 or -9, false)

		return ShellOrigin, ShellVelocity, angles.y
	end
end