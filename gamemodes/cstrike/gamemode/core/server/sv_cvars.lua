function gm_addcvar(name, value, helptext)
    if !ConVarExists(name) then
        if not value then
            value = tostring(DEFAULT_CVAR_VALUES[name]) or "0"
        end
        CreateConVar(name, value, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, helptext)
    end
end

--hook.Add("Initialize", "CS16_Init_create_cvars", function()
    gm_addcvar("cs16_time_preparing", "5", "Preparing time")
    gm_addcvar("cs16_time_buyphase", "60", "Buy phase time")
    gm_addcvar("cs16_time_round", "300", "Round time")
    gm_addcvar("cs16_time_postround", "5", "Post-round time")
--end)

function gm_getcvar(name)
	local cvar = GetConVar(name)
	if cvar == nil then return nil end
	return cvar:GetInt()
end

print("Gamemode loaded sv_cvars.lua")