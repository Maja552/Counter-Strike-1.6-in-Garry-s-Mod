local meta_player = FindMetaTable("Player")

function meta_player:CS16Team()
    --return self.cs16_team or TEAM_SPECTATOR
    return self.cs16_team
end

function GM:GetAllCS16TeamPlayers(team_id)
    local all_team_players = {}
    for k,v in pairs(player.GetAll()) do
        if v:CS16Team() == team_id then
            table.ForceInsert(all_team_players, v)
        end
    end
    return all_team_players
end

function meta_player:HasBomb()
    return self:HasWeapon("weapon_cs16_c4")
end

function meta_player:HasDefuser()
    return true
end

function meta_player:IsVIP()
    return false
end

function meta_player:GetMoney()
    return self.cs16_money or 0
end

function meta_player:IsInBombSite()
    if SERVER and self.InBombZone < CurTime() then
        self:SetNWBool("CanPlantBomb", false)
        return false
    end
    return self:GetNWBool("CanPlantBomb", false)
end

function meta_player:Notification(tab, time, text, color)
    if SERVER then
        net.Start("cs16_notification")
            net.WriteString(tab)
            net.WriteFloat(time)
            net.WriteString(text)
            net.WriteColor(color)
        net.Send(self)
    else
        StartDrawNotification(tab, time, text, color)
    end
end

function Notification(tab, time, text, color)
    if SERVER then
        net.Start("cs16_notification")
            net.WriteString(tab)
            net.WriteFloat(time)
            net.WriteString(text)
            net.WriteColor(color)
        net.Broadcast()
    else
        StartDrawNotification(tab, time, text, color)
    end
end

function meta_player:GreenNotification(texts)
    if isstring(texts) then texts = {texts} end
    if SERVER then
        net.Start("cs16_greennotification")
            net.WriteTable(texts)
        net.Send(self)
    else
        StartGreenNotification(texts)
    end
end

function GreenNotification(texts)
    if isstring(texts) then texts = {texts} end
    if SERVER then
        net.Start("cs16_greennotification")
            net.WriteTable(texts)
        net.Broadcast()
    else
        StartGreenNotification(texts)
    end
end

function meta_player:OldPrintMessage(text)
    if isstring(text) then text = {text} end
    if SERVER then
        net.Start("cs16_oldprintmessage")
            net.WriteTable(text)
        net.Send(self)
    else
        StartOldPrintMessage(text)
    end
end

function OldPrintMessage(text)
    if isstring(text) then text = {text} end
    if SERVER then
        net.Start("cs16_oldprintmessage")
            net.WriteTable(text)
        net.Broadcast()
    else
        StartOldPrintMessage(text)
    end
end

function meta_player:SetProgressBarTime()
    
end

function meta_player:IsShieldDrawn()
    return false
end

function meta_player:HasShield()
    return false
end

function meta_player:SetShieldDrawnState()
    --return false
end

function meta_player:IsEnemy(other_player)
    return self:Team() != other_player:Team()
end

function meta_player:IsEnemyTeam(team_id)
    return self:Team() != team_id
end

function meta_player:IsCS16Enemy(other_player)
    return self:CS16Team() != other_player:CS16Team()
end

function meta_player:IsCS16EnemyTeam(team_id)
    return self:CS16Team() != team_id
end

function meta_player:IsSpectator()
    return self:Team() == TEAM_SPECTATOR
end

function meta_player:IsObserver()
    return self:IsSpectator()
end

print("Gamemode loaded sh_player_ext.lua")