if CLIENT then
	SWEP.PrintName			= "CS Base"
	SWEP.Author				= "Schwarz Kruppzo"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 0
	SWEP.ViewModelFOV		= 100
	SWEP.ViewModelFlip    	= true
	SWEP.DrawAmmo 			= false
	SWEP.DrawCrosshair		= true
end

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.Weight				= -1

SWEP.HoldType			= "shotgun"

SWEP.Category			= "Counter-Strike"
SWEP.UseHands			= true
SWEP.Spawnable			= false
SWEP.PaintballGun 		= false
SWEP.ZombieWeapon 		= false

SWEP.Primary.Sound			= nil
SWEP.Primary.Damage			= 1
SWEP.Primary.NumShots		= 1
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Automatic      = false 

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Automatic	= false

SWEP.EmptySound				= Sound("weapons/357_cock1.wav")

SWEP.IsCS16 = true

if SERVER then
	CreateConVar("cs16_sv_impact", 1, FCVAR_NOTIFY + FCVAR_REPLICATED + FCVAR_ARCHIVE)

	util.AddNetworkString("CS16_BulletImpact")
else
	CreateConVar("cs16_sv_impact", 1, FCVAR_REPLICATED)
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "ShotsFired")
	self:NetworkVar("Float", 1, "DecreaseShotsFired")
	self:NetworkVar("Bool", 2, "DelayFire")
	self:NetworkVar("Float", 3, "Accuracy")
	self:NetworkVar("Float", 4, "TimeWeaponIdle")
	self:NetworkVar("Bool", 3, "InReload")
	self:NetworkVar("Bool", 4, "Direction")
	self:NetworkVar("Float", 5, "LastFire")
	self:OnSetupDataTables()
end

function SWEP:MakeSolid()
	local tr = util.QuickTrace(self:GetPos(), Vector(0, 0, 1), self)

	self:PhysicsDestroy()
	self:SetSolid(SOLID_BBOX)
	self:AddSolidFlags(FSOLID_NOT_SOLID)
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
	self:SetCollisionBounds(Vector(-1, -1, 0), Vector(1, 1, 1))
	self:UseTriggerBounds(true, 16)
	self:SetGravity(1)
	self:SetFriction(0.5)
	self:SetElasticity(0.5)
	self:SetTrigger(true)
	self:SetPos(tr.HitPos)
end

function SWEP:Initialize()
	if !self:GetOwner() or !IsValid(self:GetOwner()) then
		
		--if self.WModel then
		--	self.WorldModel = self.WModel
		--	self:SetModel(self.WModel)
		--end
		

		
		if SERVER then
			self:MakeSolid()
		end
		
	end
	
	self:SetHoldType(self.HoldType)
	if SERVER then
		self:CheckViewModel()
	end
	self.ViewModelFlipDefault = self.ViewModelFlip
end

function SWEP:Deploy()
	self:CheckWorldModel()
	self:SetNextAttack(CurTime() + 0.5)

	self:OnDeploy()
	self.Owner:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)

	return true
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end



function SWEP:Think()
	self:SetHoldType(self.HoldType)
	self:OnThink()

	local infinite_ammo = SUBGAMEMODE.CONFIG.INFINITE_AMMO

	if self:GetInReload() and self:GetNextPrimaryFire() <= CurTime() then
		local iClip = self:Clip1()
		local ammo_to_give = 0
		
		if infinite_ammo then
			ammo_to_give = self.Primary.ClipSize
		else
			self.Owner:RemoveAmmo(self.Primary.ClipSize - iClip, self.Primary.Ammo)
			ammo_to_give = math.min((self:Ammo1() + iClip), self.Primary.ClipSize)
		end
		self:SetClip1(ammo_to_give)

		self:SetInReload(false)
	end

	if CurTime() > self:GetTimeWeaponIdle() and !self:GetInReload() then
		self:WeaponIdle()
	end

	if !self.Owner:KeyDown(IN_ATTACK) and !self.Owner:KeyDown(IN_ATTACK2) then
		if self:GetDelayFire() then
			self:SetDelayFire(false)

			if self:GetShotsFired() > 15 then
				self:SetShotsFired(15)
			end

			self:SetDecreaseShotsFired(CurTime() + 0.4)
		end

		if self:GetShotsFired() > 0 then
			self:OnDecreaseShotsFired()
		end

		if self:Clip1() == 0 and (infinite_ammo or self.Owner:GetAmmoCount(self.Primary.Ammo) > 0) and !self:GetInReload() and CurTime() > self:GetNextPrimaryFire() and self:CanAutoReload() and IsFirstTimePredicted() then 
			self:Reload()
		end
	end
end

function SWEP:Holster(pWeapon)
	if self == pWeapon then
		return
	end

	self.Owner:SetShieldDrawnState(false)
	self:SetInReload(false)
	self:OnHolster()
	self:OnRemove()

	return true
end

function SWEP:FireAnimationEvent(vPos, aAngle, nEvent, sOptions)
	if nEvent == 5001 or nEvent == 20 or nEvent == 5011 then
		return true
	end
end

function SWEP:CanAutoReload()
	return true
end

function SWEP:SetNextAttack(flTime)
	self:SetNextPrimaryFire(flTime)
	self:SetNextSecondaryFire(flTime)
end

function SWEP:CS16_DefaultReload(iClipSize, anim, flDelay, useAnother)
	if self.Owner:IsShieldDrawn() then
		return false
	end

	if CurTime() <= self:GetNextSecondaryFire() or CurTime() <= self:GetNextPrimaryFire() then 
		return false 
	end

	if self.Owner:KeyDown(IN_ATTACK) or self.Owner:KeyDown(IN_ATTACK2) then 
		return false 
	end

	local infinite_ammo = SUBGAMEMODE.CONFIG.INFINITE_AMMO
	
	if !infinite_ammo then
		if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then 
			return false
		end

		local j = math.min(iClipSize - self:Clip1(), self:Ammo1())
		if j == 0 then 
			return false 
		end
	end

	self:SetNextAttack(CurTime() + flDelay)

	if useAnother then
		local vm = self.Owner:GetViewModel()

		vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(anim))
	else
		self:SendWeaponAnim(anim)
	end

	self.Owner:SetAnimation(PLAYER_RELOAD)

	self:SetTimeWeaponIdle(CurTime() + flDelay + 0.5)
	self:SetInReload(true)

	return true
end

function SWEP:KickBack(up_base, lateral_base, up_modifier, lateral_modifier, up_max, lateral_max, direction_change)
	if !IsFirstTimePredicted() then 
		return 
	end

	local front, side

	if self:GetShotsFired() == 1 then
		front = up_base
		side = lateral_base
	else
		front = self:GetShotsFired() * up_modifier + up_base
		side  = self:GetShotsFired() * lateral_modifier + lateral_base
	end

	local angles = self.Owner:CS16_GetViewPunch()

	angles.p = angles.p + -front
	if angles.p <= -up_max then
		angles.p = -up_max
	end

	if self:GetDirection() then
		angles.y = angles.y + side

		if angles.y >= lateral_max then
			angles.y = lateral_max
		end
	else
		angles.y = angles.y + -side

		if angles.y <= -lateral_max then
			angles.y = -lateral_max
		end
	end

	if math.random(0, direction_change) == 0 then
		self:SetDirection(!self:GetDirection())
	end

	self.Owner:CS16_SetViewPunch(angles)
end

function SWEP:ShieldSecondaryAttack()
	if self.Owner:HasShield() then
		if SERVER then  
			local vm = self.Owner:GetViewModel()

			self.Owner:SetShieldDrawnState(!self.Owner:IsShieldDrawn())

			if self.Owner:IsShieldDrawn() then
				vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_SHIELD_UP))
			else
				vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_SHIELD_DOWN))
			end
		end

		self:SetNextAttack(CurTime() + 0.4)

		return true
	end

	return false
end

function SWEP:CheckViewModel()
	if !IsValid(self.Owner) then 
		return 
	end

	local vm = self.Owner:GetViewModel()
	local bHands = self.Owner:GetInfoNum("cs16_cl_chands", 0) == 1 and true or false

	if bHands then
		vm:SetBodygroup(1, 0)
		self.UseHands = true
	else
		vm:SetBodygroup(1, 1)
		self.UseHands = false
	end
end

function SWEP:CheckWorldModel()
	/*
	if !IsValid(self.Owner) then 
		return 
	end
	
	if self.Owner:HasShield() then
		if self.PModelShield then
			if self.WorldModel != self.PModelShield then
				self.WorldModel = self.PModelShield
			end
		end
	else
		if self.PModel then
			if self.WorldModel != self.PModel then
				self.WorldModel = self.PModel
			end
		end
	end
	*/
end

function SWEP:GetMaxSpeed()
	return self.MaxSpeed or 250
end

function SWEP:CreateShell(shell, attachment, client, p1, p2)
	if !IsValid(self.Owner) then return end
	if SERVER and !game.SinglePlayer() then
		local filter = RecipientFilter()
		filter:AddPlayer(self.Owner)

		for k, v in pairs(player.GetAll()) do
			if !v:IsObserver() then continue end
			if v == self.Owner then continue end
			if v:GetObserverTarget() != self.Owner then continue end
			filter:AddPlayer(v)
		end

		umsg.Start("CS16_CreateShell", filter)
			umsg.String(shell)
			umsg.String(attachment)
			umsg.Entity(self)
		umsg.End()

		return
	elseif (CLIENT and client) or game.SinglePlayer() then
		if !IsValid(self.Owner) then return end
		local vm = self.Owner:GetViewModel()

		if IsValid(vm) then
			local fx = EffectData()
			local attach = vm:GetAttachment(attachment)
			
			if attach then
				fx:SetEntity(self)
				fx:SetSurfaceProp(tonumber(shell) or 0)
				fx:SetAttachment(attachment)
				fx:SetMagnitude(1)
				fx:SetScale(1)
				fx:SetOrigin(attach.Pos)
				fx:SetNormal(attach.Ang:Forward())
				util.Effect("cs16_shell", fx)
			end
		end
	end
end

function SWEP:CS16_MuzzleFlash(type_vm, type_wm, attach_vm, attach_wm)
	if !IsFirstTimePredicted() or !IsValid(self.Owner) or self.Owner:WaterLevel() >= 3 then return end
	
	local fx = EffectData()
	fx:SetEntity(self)
	fx:SetOrigin(self.Owner:GetShootPos())
	fx:SetNormal(self.Owner:GetAimVector())
	fx:SetStart(Vector(type_vm, type_wm, attach_wm or 1))
	fx:SetScale(1)
	fx:SetAttachment(attach_vm or 1)

	util.Effect("cs16_muzzle", fx)
end

function SWEP:RecalculateAccuracy() end

function SWEP:WeaponIdle() end

function SWEP:OnSetupDataTables() end

function SWEP:OnDeploy() end

function SWEP:OnHolster() end

function SWEP:OnThink() end

function SWEP:OnDecreaseShotsFired()
	if CurTime() > self:GetDecreaseShotsFired() then
		self:SetShotsFired(self:GetShotsFired() - 1)
		self:RecalculateAccuracy()
		self:SetDecreaseShotsFired(CurTime() + 0.0225)
	end
end

function SWEP:OnRemove() end

function SWEP:DoImpactEffect(pTrace, iDamageType)
	if cvars.Bool("cs16_sv_impact") then
		CS16_BulletCallBack(self.Owner, pTrace)

		return true
	else
		return false
	end
end

if CLIENT then
	function SWEP:PreDrawViewModel()
		if true then return end
		self:CheckViewModel()

		local flip = cvars.Number("cs16_cl_viewmodelflip", 0) != 1
		local shouldflip = self.ViewModelFlipDefault

		if !flip then
			shouldflip = !self.ViewModelFlipDefault
		end

		if self.Owner:HasShield() then
			self.ViewModelFlip = !shouldflip
		else
			self.ViewModelFlip = shouldflip
		end

		self:OnPreDrawViewModel()
	end

	function SWEP:CalcViewModelView(vm, oldPos, oldAng, pos, ang)
		--oldPos.z = oldPos.z - 3
		if self.Owner.CalcBob then
			local bob_int = self.Owner:CalcBob()
			oldPos = oldPos + ((oldAng:Forward() - oldAng:Right() * 0.05 + oldAng:Up() * 0.1) * bob_int * 0.4) - Vector(0, 0, 1 - bob_int)
		end
		return oldPos, oldAng
	end

	
	function SWEP:CalcView(ply, pos, ang, fov)
		if !self.Owner:ShouldDrawLocalPlayer() then
			local bob_int = ply:CalcBob()

			pos[3] = pos[3] + bob_int
			
			ang = ang + self.Owner:CS16_GetViewPunch()
		end

		fov = self:OnCalcView(ply, pos, ang, 74) or 74

		return pos, ang, fov
	end
	

	function SWEP:GetShellDir(attach, ang)
		return nil, Vector(), -attach.Ang:Forward() + ang:Up() * math.Rand(1.7, 2.5) + ang:Forward() * math.Rand(0.5, 2)
	end

	function SWEP:OnCalcView(ply, pos, ang, fov) end

	function SWEP:OnPreDrawViewModel() end

	function SWEP:DoDrawCrosshair()
		local noshow = hook.Run("CS16SWEPs_NoDrawCrosshair")
		if !noshow then
			CS16_DrawCrosshair(self)
		end
		
		return true
	end


	local function CS16_CreateShell(data)
		local shell = data:ReadString()
		local attachment = data:ReadString()
		local weapon = data:ReadEntity()

		if IsValid(weapon) and weapon.IsCS16 and weapon.CreateShell then
			weapon:CreateShell(shell, attachment, true)
		end
	end

	usermessage.Hook("CS16_CreateShell", CS16_CreateShell)
end

local meta = FindMetaTable("Player")
local ImpactSoundsConcrete = {
	Sound("weapons/ric1.wav"),
	Sound("weapons/ric2.wav"),
	Sound("weapons/ric3.wav"),
	Sound("weapons/ric4.wav"),
	Sound("weapons/ric5.wav"),
	Sound("weapons/ric_conc-1.wav"),
}
local ImpactSoundsMetal = {
	Sound("weapons/ric_metal-1.wav"),
	Sound("weapons/ric_metal-2.wav")
}
local TextureSounds = {
	[MAT_WOOD]= {Sound("physics/wood/wood_plank_break1.wav"), Sound("physics/wood/wood_plank_break2.wav"), Sound("physics/wood/wood_plank_break3.wav")},
	[MAT_COMPUTER] = {Sound("physics/glass/glass_cup_break1.wav"), Sound("physics/glass/glass_cup_break2.wav"), Sound("physics/glass/glass_cup_break3.wav")},
	[MAT_GLASS] = {Sound("physics/glass/glass_cup_break1.wav"), Sound("physics/glass/glass_cup_break2.wav"), Sound("physics/glass/glass_cup_break3.wav")},
	[MAT_FLESH] = {Sound("weapons/bullet_hit1.wav"), Sound("weapons/bullet_hit2.wav")}
}
local TextureSoundsVolume = {
	[MAT_VENT] = 0.5,
	[MAT_TILE] = 0.8,
	[MAT_COMPUTER] = 0.2,
	[MAT_GLASS] = 0.2,
	[MAT_FLESH] = 1
}

function CS16_PlayTextureSound(pos, mat)
	if TextureSounds[mat] then
		local sounds = TextureSounds[mat]
		sound.Play(sounds[math.random(1, #sounds)], pos, 75, 100, TextureSoundsVolume[mat] or 0.9, CHAN_STATIC)
	end

	if math.random(0, 0x7FFF) < (0x7FFF/2) then
		if mat == MAT_VENT or mat == MAT_METAL then
			sound.Play(ImpactSoundsMetal[math.random(1, 2)], pos, 75, 100, 1, CHAN_BODY)
		else
			sound.Play(ImpactSoundsConcrete[math.random(1, 6)], pos, 75, 100, 1, CHAN_BODY)
		end
	end
end

function CS16_BulletCallBack(pPlayer, pTrace)
	if IsValid(pTrace.Entity) then
		if pTrace.Entity:IsPlayer() or pTrace.Entity:IsNPC() then
			return
		end
	end

	if SERVER then
		CS16_PlayTextureSound(pTrace.HitPos, pTrace.MatType)

		util.Decal("hl.impact", pTrace.HitPos + pTrace.HitNormal, pTrace.HitPos - pTrace.HitNormal)

		net.Start("CS16_BulletImpact")
			net.WriteVector(pTrace.HitPos)
			net.WriteVector(pTrace.HitNormal)
			net.WriteInt(pTrace.MatType, 32)
		net.Broadcast()
	end
end

if CLIENT then
	net.Receive("CS16_BulletImpact", function()
		local pos = net.ReadVector()
		local normal = net.ReadVector()
		local mat = net.ReadInt(32)

		if pos and normal and mat then
			local data = EffectData()
			data:SetOrigin(pos)
			util.Effect("cs16_impact", data) 
			ParticleEffect("cs16_impact", pos + normal, Angle())

			local spark = true
			local smoke = "cs16_impact_smoke"
			if mat == MAT_WOOD then
				spark = false
				smoke = "cs16_impact_smoke_w"
			elseif mat == MAT_CONCRETE then
				smoke = "cs16_impact_smoke_c"
			end

			ParticleEffect(smoke, pos - normal, normal:Angle() + Angle(90, 0, 0))

			if spark then
				ParticleEffect("cs16_impact_spark", pos + normal, Angle())
			end
		end
	end)
end

local function create_muzzle_dlight(pos, wep)
    wep.Dlight = DynamicLight(wep:EntIndex())
    wep.Dlight.pos = pos
    wep.Dlight.r = 255
    wep.Dlight.g = 234
    wep.Dlight.b = 0
    wep.Dlight.brightness = 10
    wep.Dlight.Decay = 1000
    wep.Dlight.Size = 128
    wep.Dlight.DieTime = CurTime() + 1
end

function meta:FireBullets3(swep, vecSrc, shootAngles, flSpread, flDistance, iPenetration, strAmmoType, iDamage, flRangeModifier, attacker, bPistol, shared_rand)
	if !IsFirstTimePredicted() then return end
	if SERVER and SUBGAMEMODE.CONFIG.INFINITE_AMMO == false and (self:GetAmmoCount(strAmmoType) + swep:Clip1()) == 0 and (CurTime() - game_state_preparing_timestamp) <= cvars.Number("cs16_time_buyphase", DEFAULT_CVAR_VALUES["cs16_time_buyphase"]) then
		self:GreenNotification({"You are out of ammunition", "Return to a buy zone to purchase more."})
	end

	local vecDirShooting, vecRight, vecUp 
	shootAngles = shootAngles + self:CS16_GetViewPunch()
	vecDirShooting = shootAngles:Forward()
	vecRight = shootAngles:Right()
	vecUp = shootAngles:Up()

	if CLIENT then
		create_muzzle_dlight(swep.Owner:GetShootPos(), swep)
	end

	local originalPenetration = iPenetration
	local penetrationPower = 0
	local penetrationDistance = 0

	local currentDamage = iDamage
	local currentDistance = 0

	local hitMetal = false

	if CS16_Penetration_Info[strAmmoType] then
		penetrationPower = CS16_Penetration_Info[strAmmoType].power
		penetrationDistance = CS16_Penetration_Info[strAmmoType].distance
	else
		penetrationPower = 0
		penetrationDistance = 0
	end

	if !attacker then attacker = self end

	local x, y, z = 0, 0, 0

	if self:IsPlayer() then
		x = util.SharedRandom("SpreadX1", -0.5, 0.5) + util.SharedRandom("SpreadX2", -0.5, 0.5)
		y = util.SharedRandom("SpreadY1", -0.5, 0.5) + util.SharedRandom("SpreadY2", -0.5, 0.5)
	end

	local vecDir = vecDirShooting + (x * flSpread * vecRight) + (y * flSpread * vecUp)
	vecDir:Normalize()
	local vecEnd = vecSrc + vecDir * flDistance

	local damageModifier = 0.5
	while iPenetration != 0 do
		local tracedata = {}
		tracedata.start = vecSrc
		tracedata.endpos = vecEnd
		tracedata.mask = MASK_SHOT
		tracedata.filter = self
		local tr = util.TraceLine(tracedata)

		if CS16_Bullet_Mat_Info[tr.MatType] then
			local tbl = CS16_Bullet_Mat_Info[tr.MatType]

			hitMetal = tbl.metal
			penetrationPower = tbl.power and (penetrationPower * tbl.power) or penetrationPower
			damageModifier = tbl.damageMul and tbl.damageMul or damageModifier
		end

		if tr.Fraction != 1.0 then
			local ent = tr.Entity

			iPenetration = iPenetration - 1

			currentDistance = tr.Fraction * flDistance
			currentDamage = currentDamage * math.pow(flRangeModifier, currentDistance / 500)

			if currentDistance > penetrationDistance then
				iPenetration = 0
			end

			if tr.HitGroup == HITGROUP_SHIELD and ent.HasShield and ent:HasShield() then
				iPenetration = 0
			end

			local distanceModifier = 0

			if tr.Entity:GetSolid() != SOLID_BSP and iPenetration == 0 then
				penetrationPower = 42
				distanceModifier = 0.75
				damageModifier = 0.75
			else
				distanceModifier = 0.75
			end
			
			local bullet = {}
			bullet.Num = 1
			bullet.Src = vecSrc
			bullet.Dir = vecDir
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Damage = currentDamage
			bullet.AmmoType = strAmmoType
			bullet.Force = 1
			bullet.Callback = cvars.Number("cs16_sv_impact") == 1 and CS16_BulletCallBack or nil
			
			vecSrc = tr.HitPos + (vecDir * penetrationPower)
			flDistance = (flDistance - currentDistance) * distanceModifier
			vecEnd = vecSrc + (vecDir * flDistance)

			self:FireBullets(bullet)

			currentDamage = currentDamage * damageModifier
		else
			iPenetration = 0
		end
	end

	return Vector(x * flSpread, y * flSpread, 0)
end