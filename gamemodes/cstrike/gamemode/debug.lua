/*
sv_cheats 1 ; debug_start
lua_run Entity(1):SetZombie()
*/

concommand.Add("debug_start", function(ply, cmd, args)
    RunConsoleCommand("bot_zombie", "1")
    for i=1, 32 do
        RunConsoleCommand("bot")
    end
end)

print("Gamemode loaded debug.lua")