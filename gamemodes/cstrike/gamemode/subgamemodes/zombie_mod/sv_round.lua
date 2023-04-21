
AddCSLuaFile("sh_round_types.lua")
include("sh_round_types.lua")

function SUBGAMEMODE:WinCheck()
    local all_ts_a = 0
    local all_cts_a = 0
    for k,v in pairs(GAMEMODE:GetPlayers()) do
        if v:IsSpectator() then continue end

        if v:IsZombie() or (v.WasZombie > CurTime() and v.zombie_lives > 0) then
            all_ts_a = all_ts_a + 1

        elseif v:Team() == TEAM_CT and v:Alive() then
            all_cts_a = all_cts_a + 1
        end
    end
    if all_ts_a == 0 and all_cts_a == 0 then
        return WIN_DRAW, WIN_DRAW

    elseif all_ts_a > 0 and all_cts_a == 0 then
        return TEAM_T, WIN_ELIMINATION

    elseif all_cts_a > 0 and all_ts_a == 0 then
        return TEAM_CT, WIN_ELIMINATION
    end
    return 0
end

util.AddNetworkString("cs16_postroundstart")
function SUBGAMEMODE:Post_PostRoundStart(win_id, win_reason)
    net.Start("cs16_postroundstart")
        net.WriteInt(win_id, 8)
    net.Broadcast()

    if win_reason == WIN_TIME then
        SUBGAMEMODE.CONFIG.CS16_WinRewards.time(win_id, win_reason)

    elseif win_reason == WIN_ELIMINATION then
        SUBGAMEMODE.CONFIG.CS16_WinRewards.elimination(win_id, win_reason)
    end

    SUBGAMEMODE.CONFIG.CS16_LostRewards(win_id, win_reason)
end

util.AddNetworkString("cs16_zm_roundstart")
function SUBGAMEMODE:Post_RoundStart()
    CS16_ZM_ROUNDTYPES[CS16_ZM_CurrentRoundType]["sv_post_round_start"]()

    net.Start("cs16_zm_roundstart")
        net.WriteString(CS16_ZM_CurrentRoundType)
    net.Broadcast()
end

CS16_ZM_FiredCountDown = true
CS16_ZM_FiredLastHuman = false

util.AddNetworkString("cs16_zm_prepstart")
function SUBGAMEMODE:Post_Preparing()
    --GAMEMODE:DEFAULT_Assign_Players()

    local half1 = {}
    for k,v in pairs(player.GetAll()) do
        if v.WantToPlay then
            table.ForceInsert(half1, v)
        end
    end

    local half2 = {}
    for i=1, math.Round(#half1 / 2) do
        local rnd_ply = table.Random(half1)
        table.ForceInsert(half2, rnd_ply)
        table.RemoveByValue(half1, rnd_ply)
    end

    for k,v in pairs(half1) do
        v:SetCS16Team(TEAM_T, true)
        v:SetTeam(TEAM_T)
    end
    for k,v in pairs(half2) do
        v:SetCS16Team(TEAM_CT, true)
        v:SetTeam(TEAM_CT)
    end



    local plys = GAMEMODE:GetPlayers()
    local num_of_players = #plys
    print("num_of_players: ", num_of_players)

    CS16_ZM_CurrentRoundType = "default"

    if first_round then
        CS16_NEXT_SPECIAL_ROUND = math.random(3,6)
    end

    CS16_NEXT_SPECIAL_ROUND = CS16_NEXT_SPECIAL_ROUND - 1
    if CS16_NEXT_SPECIAL_ROUND < 1 then
        local possible_special_rounds = {}
        for k,v in pairs(CS16_ZM_SPECIAL_ROUNDTYPES) do
            local round = CS16_ZM_ROUNDTYPES[v]
            if num_of_players >= round.min_players then
                table.ForceInsert(possible_special_rounds, v)
            end
        end
        local special_round = table.Random(possible_special_rounds)
        if isstring(special_round) then
            CS16_ZM_CurrentRoundType = special_round
            CS16_NEXT_SPECIAL_ROUND = math.random(3,6)
        end
    end

    -- Spawn all players, resets their things and sets the model
    for k,v in pairs(plys) do
        v:Spawn()
        v.zombie_lives = 3
        v.zm_spent = 0
        v.is_nemesis = false
        v.WasZombie = 0
		v.InBuyZone = CurTime() + 1000000
        v.barricades_places = 0
		v:SetNWBool("CanBuy", true)
        v:StripWeapon("weapon_cs16_zm_zombie")
        v:StripWeapon("weapon_cs16_zm_zombie_stealth")
        v:StripWeapon("weapon_cs16_zm_infectgrenade")
        v:StripWeapon("weapon_cs16_zm_m249")
    end

    CS16_ZM_FiredCountDown = false
    CS16_ZM_FiredLastHuman = false

    local team_tab = {}

    -- Give loadout weapons, money
    for k,v in pairs(plys) do
        local team_assign_func = GAMEMODE.DEFAULT_CONFIG.ASSIGN_TEAMS[v:Team()]
        if team_assign_func then
            team_assign_func(v)
        end

        table.ForceInsert(team_tab, {v, v:CS16Team()})

        if v:HasWeapon("weapon_cs16_zm_zombie") then
            v:StripWeapon("weapon_cs16_zm_zombie")
            --v:ConCommand("lastinv")
            v:SelectWeapon("weapon_cs16_zm_zombie")

        elseif v:HasWeapon("weapon_cs16_zm_zombie_stealth") then
            v:StripWeapon("weapon_cs16_zm_zombie_stealth")
            --v:ConCommand("lastinv")
            v:SelectWeapon("weapon_cs16_zm_zombie_stealth")
        end

        v:Give("weapon_cs16_knife")

        -- Free light nade
        local ammo_str = "CS16_SMOKEGRENADE"
        local ammo_count = v:GetAmmoCount(ammo_str)
        local light_nade = v:GetWeapon("weapon_cs16_zm_lightgrenade")
        if IsValid(light_nade) then
            if ammo_count < 1 then
                v:GiveAmmo(1, ammo_str, false)
            end
        else
            light_nade = v:Give("weapon_cs16_zm_lightgrenade")
            if ammo_count < 1 then
                v:GiveAmmo(1, game.GetAmmoName(light_nade:GetPrimaryAmmoType()), false)
            end
        end

        -- Free gun
        v:Give("weapon_cs16_usp")
        if round_id == 1 then
            v:Give(table.Random(SUBGAMEMODE.CONFIG.GUN_ON_START))
        end
    end

    -- Update the cs16_team of all players
    net.Start("cs16_updateallteams")
        net.WriteTable(team_tab)
    net.Broadcast()

    Notification("upper", 6, GetLang("NOTICE_VIRUS_FREE"), Color(0, 125, 200))

    -- Sends the money information to all clients
    GAMEMODE:UpdateAllMoney()

    RunConsoleCommand("sv_accelerate", "8")

    net.Start("cs16_zm_prepstart")
    net.Broadcast()
end

print("Gamemode loaded gamemodes/zombie_mod/sv_round.lua")