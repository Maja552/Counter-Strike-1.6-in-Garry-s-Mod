
local meta_player = FindMetaTable("Player")

util.AddNetworkString("cs16_getmoney")
function meta_player:UpdateMoney()
    net.Start("cs16_getmoney")
        net.WriteEntity(self)
        net.WriteInt(self.cs16_money, 16)
    net.Broadcast()
end

function GM:UpdateAllMoney()
	for k,v in pairs(player.GetAll()) do
		v:UpdateMoney()
	end
end

function meta_player:SetMoney(amount, update)
    self.cs16_money = amount
    if update then
        self:UpdateMoney()
    end
    --self:SetNWInt("CS16_Money", self.cs16_money)
end

function meta_player:AddMoney(amount, update)
    self.cs16_money = math.Clamp(self.cs16_money + amount, 0, SUBGAMEMODE.CONFIG.MAX_MONEY)
    if update then
        self:UpdateMoney()
    end
    --self:SetNWInt("CS16_Money", self.cs16_money)
end

function give_wanted_item(name, cost, ply)
    if ply:HasWeapon(name) then
        ply:OldPrintMessage("You already have that weapon.")
        return
    end

    local wep = ply:Give(name)
    if !IsValid(wep) then return end

    hook.Call("CS16_OnPlayerBought", GAMEMODE, ply, name, cost)

    for k,v in pairs(ply:GetWeapons()) do
        local candrop = true
        if isfunction(wep.CanDrop) then
            candrop = wep:CanDrop()
        end
        if v:GetClass() != name and v.Slot == wep.Slot and candrop then
            --ply:StripWeapon(v:GetClass())
            ply:DropWep(v)
            v:SetPos(ply:EyePos() - Vector(0,0,20))
            ply:Give(name)
        end
    end
    ply:AddMoney(cost, true)
end

util.AddNetworkString("cs16_trytobuy")
net.Receive("cs16_trytobuy", function(len, ply)
    if ply:Alive() and !ply:IsSpectator() and SUBGAMEMODE:PlayerCanBuy(ply) then
        if !SUBGAMEMODE.CONFIG.CAN_BUY_ANYWHERE then
            local buytime = cvars.Number("cs16_time_buyphase", DEFAULT_CVAR_VALUES["cs16_time_buyphase"])
            if (CurTime() - game_state_preparing_timestamp) > buytime then
                ply:OldPrintMessage({buytime.." seconds have passed.", "You can't buy anything now!"})
                return
            end
        end

        local name_got = net.ReadString()
        for k,v in pairs(SUBGAMEMODE.CONFIG.CS16_SHOP_ITEMS) do
            if v[1] == name_got then
                local cost = SUBGAMEMODE.CONFIG.CS16_PRICES[name_got]
                if cost == nil then
                    cost = 0
                elseif cost > ply.cs16_money then
                    ply:OldPrintMessage("You have insufficient funds!")
                    return
                end
                if isfunction(v[2]) then
                    local successful, should_count = v[2](ply, name_got, -cost)
                    if successful then
                        hook.Call("CS16_OnPlayerBought", GAMEMODE, ply, name_got, cost, should_count)
                    end
                else
                    give_wanted_item(name_got, -cost, ply)
                end
                return
            end
        end
        print("COULD NOT FIND ITEM: ", name_got)
    end
end)

print("Gamemode loaded sv_menu_buy.lua")