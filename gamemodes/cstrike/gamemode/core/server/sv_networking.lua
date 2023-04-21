
util.AddNetworkString("cs16_planted_c4")
util.AddNetworkString("cs16_change_team")
util.AddNetworkString("cs16_change_model")
util.AddNetworkString("cs16_updateallteams")
util.AddNetworkString("cs16_dropweapon")
util.AddNetworkString("cs16_droppedweapon")
util.AddNetworkString("cs16_oldprintmessage")
util.AddNetworkString("cs16_greennotification")
util.AddNetworkString("cs16_notification")
util.AddNetworkString("cs16_sprayer")
util.AddNetworkString("cs16_usesound")
util.AddNetworkString("cs16_freezeplayer")
util.AddNetworkString("cs16_cloakplayer")
util.AddNetworkString("cs16_togglenvg")
util.AddNetworkString("cs16_pmchanged")
util.AddNetworkString("cs16_chooseclass")

net.Receive("cs16_chooseclass", function(len, ply)
    local class = net.ReadString()
    local class_tab = SUBGAMEMODE.CONFIG.CLASSES[class]
    if class_tab then
        ply.cs16_class = class
        ply:OldPrintMessage("Your class will be changed next spawn")
    else
        ply:OldPrintMessage("Could not find class: "..class)
    end
end)

net.Receive("cs16_togglenvg", function(len, ply)
    if ply:Alive() and !ply:IsSpectator() and ply:GetNWBool("HasNVG") then
        net.Start("cs16_togglenvg")
            net.WriteEntity(ply)
            net.WriteBool(net.ReadBool() or false)
        net.Broadcast()
    end
end)

net.Receive("cs16_sprayer", function(len, ply)
    if ply.nextSprayer < CurTime() then
        local startpos = ply:EyePos()
        local endpos = startpos + ply:GetAimVector() * 150
        local tr = util.TraceLine({
            start = startpos,
            endpos = endpos,
            mask = MASK_SOLID_BRUSHONLY
        })
        if tr.HitWorld then
            ply:SprayDecal(startpos, endpos)
            sound.Play("cstrike/player/sprayer.wav", tr.HitPos, 100, 100, 1)
            ply.nextSprayer = CurTime() + 5
        end
    end
end)

net.Receive("cs16_dropweapon", function(len, ply)
    SUBGAMEMODE:DropCurrentWeapon(ply)
end)

net.Receive("cs16_change_team", function(len, ply)
    local team_id = net.ReadInt(16)
    SUBGAMEMODE:TeamChange(ply, team_id)
end)

net.Receive("cs16_change_model", function(len, ply)
    local mdl = net.ReadString()
    local team_id = net.ReadInt(4)
    if team_id == nil or team_id == 0 then
        team_id = ply:CS16Team()
    end
    SUBGAMEMODE:ModelChange(ply, mdl, team_id)
end)

print("Gamemode loaded sv_networking.lua")