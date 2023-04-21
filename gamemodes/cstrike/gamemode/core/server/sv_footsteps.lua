
function GM:PlayerFootstep(ply, pos, foot, sound, volume, rf)
   if CLIENT or !IsValid(ply) or ply:IsSpectator() or ply:GetNWBool("HasSilentBoots", false) then return true end

   local new_fstep = "cstrike/player/pl_step"..math.random(1,4)..".wav"

   if ply:Crouching() or ply:GetMaxSpeed() < 150 then
     -- ply:EmitSound(new_fstep, 60, 100, 0.1)
      return true
   end

   if string.find(sound, "metal") then
      new_fstep = "cstrike/player/pl_metal"..math.random(1,4)..".wav"

   elseif string.find(sound, "duct") then
      new_fstep = "cstrike/player/pl_duct"..math.random(1,4)..".wav"

   elseif string.find(sound, "ladder") then
      new_fstep = "cstrike/player/pl_ladder"..math.random(1,4)..".wav"

   elseif ply:WaterLevel() == 1 or string.find(sound, "wade") then
      new_fstep = "cstrike/player/pl_wade"..math.random(1,4)..".wav"

   --elseif string.find(sound, "tile") or string.find(sound, "concrete") then
   elseif string.find(sound, "tile") then
      new_fstep = "cstrike/player/pl_tile"..math.random(1,5)..".wav"

   elseif string.find(sound, "grass") or string.find(sound, "dirt") or string.find(sound, "sand") then
      new_fstep = "cstrike/player/pl_dirt"..math.random(1,4)..".wav"

   elseif string.find(sound, "snow") then
      new_fstep = "cstrike/player/pl_snow"..math.random(1,6)..".wav"
   end

   ply:EmitSound(new_fstep, 75, 100, volume)
   return true
end

print("Gamemode loaded sv_footsteps.lua")