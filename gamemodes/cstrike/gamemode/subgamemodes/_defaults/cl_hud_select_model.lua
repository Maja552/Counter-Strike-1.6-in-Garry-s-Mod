
GM.DEFAULT_MENU_SelectModels = {
    [TEAM_T] = {
        {
            name = "PHOENIX CONNEXION",
            mdl = "models/cs/playermodels/terror.mdl",
            icon = Material("vgui/cstrike/model_selection/terror"),
            desc = [[Having established a reputation for killing anyone that
gets in their way, the Phoenix Faction is one of
the most feared terrorist groups in Eastern Europe.
Formed shortly after the breakup of the USSR.
            ]]
        },
        {
            name = "ELITE CREW",
            mdl = "models/cs/playermodels/leet.mdl",
            icon = Material("vgui/cstrike/model_selection/leet"),
            desc = [[Middle Eastern fundamentalist group bent on world
domination and various other evil deeds.
            ]]
        },
        {
            name = "ARCTIC AVENGERS",
            mdl = "models/cs/playermodels/arctic.mdl",
            icon = Material("vgui/cstrike/model_selection/arctic"),
            desc = [[Swedish terrorist faction founded in 1977. Famous for
their bombing of the Canadian embassy in 1990.]]
        },
        {
            name = "GUERILLA WARFARE",
            mdl = "models/cs/playermodels/guerilla.mdl",
            icon = Material("vgui/cstrike/model_selection/guerilla"),
            desc = [[A terrorist faction founded in the Middle East, this
group has a reputation for ruthlessness. Their
disgust for the American lifestyle was demonstrated in
their 1982 bombing of a school bus full of Rock and Roll
musicians.
            ]]
        },
        1,
        {
            name = "AUTO-SELECT",
            mdl = "auto",
            icon = Material("vgui/cstrike/model_selection/t_random"),
            desc = [[Auto-Select randomly selects a character model.]]
        }
    },
    [TEAM_CT] = {
        {
            name = "SEAL TEAM 6",
            mdl = "models/cs/playermodels/urban.mdl",
            icon = Material("vgui/cstrike/model_selection/urban"),
            desc = [[ST-6 (to be known later as DEVGRU) was founded in 1980
under the command of Lieutenant-Commander Richad Marcinko.
ST-6 was placed on permanent alert to respond
to terrorist attacks against American targets worldwide.
            ]]
        },
        {
            name = "GSG-9",
            mdl = "models/cs/playermodels/gsg9.mdl",
            icon = Material("vgui/cstrike/model_selection/gsg9"),
            desc = [[GSG-9 was born out of the tragic events that led to the
death of several Israeli athletes during the
1972 Olympic games in Munich, Germany.
            ]]
        },
        {
            name = "SAS",
            mdl = "models/cs/playermodels/sas.mdl",
            icon = Material("vgui/cstrike/model_selection/sas"),
            desc = [[The world-renowned British SAS was founded in the Second
World War by a man named David Stirling. Their
role during WW2 involved gathering intelligence begind
enemy lines and executing sabotage strikes and
assasinations against key targets.
            ]]
        },
        {
            name = "GIGN",
            mdl = "models/cs/playermodels/gign.mdl",
            icon = Material("vgui/cstrike/model_selection/gign"),
            desc = [[France's elite Counter-Terrorist unit, the GIGN, was
designed to be a fast response force that could
decisively react to any large-scale terrorist incident.
Consisting of no more than 100 men, the GIGN has earned
its repupation through a history of successful ops.
            ]]
        },
        1,
        {
            name = "AUTO-SELECT",
            mdl = "auto",
            icon = Material("vgui/cstrike/model_selection/ct_random"),
            desc = [[Auto-Select randomly selects a character model.]]
        }
    }
}

print("Gamemode loaded gamemodes/_defaults/cl_hud_select_model.lua")