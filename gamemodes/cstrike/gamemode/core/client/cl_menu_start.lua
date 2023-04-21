

current_start_menu = "server_info"
firststartmenu = false
pressed_bind = nil


function CreateStartMenu()
	if !GM_INITIALIZED then return end

    if IsValid(startmenu_frame) then
        startmenu_frame:Remove()
    end
    timer.Remove("model_selection_delay")

	local client = LocalPlayer()

    local our_team = nil
    if force_model_team then
        our_team = force_model_team
    elseif client.CS16Team then
        our_team = client:CS16Team()
    end

	local scrw = ScrW()
	local scrh = ScrH()
	local size_mul = math.Clamp(scrh / 1080, 0.5, 1.2)

    local start_menu_w = scrw * 0.7
    local start_menu_h = scrh * 0.9
    local bg_color = Color(15, 15, 15, 220)

    local font_info = {
        font = "Verdana",
        extended = false,
        size = 18 * size_mul,
        weight = 700,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = true,
        additive = false,
        outline = false,
    }

    surface.CreateFont("cs_menu_start_2", font_info)
    font_info.size = 38 * size_mul
    font_info.weight = 700
    surface.CreateFont("cs_menu_start_1", font_info)
    font_info.size = 20 * size_mul
    font_info.weight = 700
    surface.CreateFont("cs_menu_start_4", font_info)
    font_info.size = 36 * size_mul
    font_info.weight = 0
    font_info.font = "Arial"
    surface.CreateFont("cs_menu_start_3", font_info)


    startmenu_frame = vgui.Create("DFrame")
    startmenu_frame:SetSize(start_menu_w, start_menu_h)
    startmenu_frame:Center()
    startmenu_frame:SetTitle("")
    startmenu_frame:SetDraggable(false)
    startmenu_frame:ShowCloseButton(false)
    startmenu_frame.Paint = function(self, w, h) end
    startmenu_frame.OnRemove = function(self)
        force_model_team = nil
    end
    
    local up_panel_size = start_menu_h / 8
    local down_panel_size = start_menu_h - up_panel_size - 2

    local up_menu = vgui.Create("DPanel", startmenu_frame)
    up_menu:SetSize(start_menu_w, up_panel_size)
    up_menu:SetPos(0, 0)
    up_menu.DefaultPaint = function(self, w, h)
        draw.RoundedBoxEx(18, 0, 0, w, h, bg_color, true, true, false, false)
    end
    up_menu.Paint = up_menu.DefaultPaint

    local down_menu = vgui.Create("DPanel", startmenu_frame)
    down_menu:SetSize(start_menu_w, down_panel_size)
    down_menu:SetPos(0, up_panel_size + 2)
    down_menu.DefaultPaint = function(self, w, h)
        draw.RoundedBoxEx(18, 0, 0, w, h, bg_color, false, false, true, true)
    end
    down_menu.Paint = down_menu.DefaultPaint
    
    function func_open_select_teams(up_menu, down_menu)
        if firststartmenu then
            current_start_menu = "select_team"
            start_menus[current_start_menu].func(up_menu, down_menu)
        else
            startmenu_frame:Remove()
        end
    end

    function startmenu_frame.func_open_select_model()
        current_start_menu = "select_model"
        start_menus[current_start_menu].func(up_menu, down_menu)
    end

    local down_main_content_w = start_menu_w * 0.8
    local down_main_content_x = (start_menu_w - down_main_content_w) / 2
    local down_main_content_y = 94 * size_mul

    start_menus = {
        server_info = {
            func = function(up_menu, down_menu)
            for k,v in pairs(down_menu:GetChildren()) do
                v:Remove()
            end

            up_menu.Paint = function(self, w, h)
                up_menu.DefaultPaint(self, w, h)
                
                draw.Text({
                    text = GAMEMODE:GetHostName(),
                    pos = {128 * size_mul, h / 2},
                    font = "cs_menu_start_1",
                    color = cs16_main_color,
                    xalign = TEXT_ALIGN_LEFT,
                    yalign = TEXT_ALIGN_CENTER
                })
            end
            
            down_menu.Paint = function(self, w, h)
                down_menu.DefaultPaint(self, w, h)
            end

            -- uncomment to enable enter closing the menu
            /*
            up_menu.Think = function(self)
                if input.LookupBinding("+attack", false) == "ENTER" and input.IsKeyDown(KEY_ENTER) then
                    func_open_select_teams(up_menu, down_menu)
                    return
                end
            end
            */

            local text_info = {
                font = "cs_menu_start_2",
                color = cs16_main_color,
                xalign = TEXT_ALIGN_LEFT,
                yalign = TEXT_ALIGN_TOP
            }

            local sm8 = 8 * size_mul
            local sm16 = 16 * size_mul
            local sm24 = 24 * size_mul
            local last_y = sm8
            local text_size = 19 * size_mul
            local texts = {
                cs16_main_color,
                {"You are playing Counter-Strike v1.6", 0},
                {"Ported to Garry's Mod by Kanade", 0},
                {"Special thanks to Moon for helping with map porting", 0},
                {"Visit the official CS web site @", 0},
                {"www.counter-strike.net", 0},
                {false, 0}, -- website link
                --true,
                --true,
                --cs16_main_color,
                --{"Use the line below in your console (~) to bind gamemode commands", 0},
                --color_white,
                --{"bind m chooseteam ; bind b buy ; bind g drop ; bind n nightvision", 0},
                true,
                cs16_main_color,
                {"Use the line below in your console (~) to apply optimal voice-chat settings", 0},
                color_white,
                {"voice_maxgain 4", 0},
            }
            for i,v in ipairs(texts) do
                if IsColor(v) then
                    continue
                end
                if istable(v) then
                    v[2] = last_y
                end
                last_y = last_y + text_size
            end

            local margin = 6 * size_mul

            local text_content_h = down_panel_size * 0.6

            local text_content_bg = vgui.Create("DPanel", down_menu)
            text_content_bg:SetSize(down_main_content_w, text_content_h)
            text_content_bg:SetPos(down_main_content_x, down_main_content_y)

            local text_content = vgui.Create("RichText", text_content_bg)
            text_content:Dock(FILL)
            text_content:DockMargin(margin, margin, margin, margin)
            
            for k,v in pairs(texts) do
                if IsColor(v) then
                    text_content:InsertColorChange(v.r, v.g, v.b, v.a)
                    continue
                end
                if istable(v) and isstring(v[1]) then
                    text_content:AppendText(v[1].."\n")
                else
                    text_content:AppendText("\n")
                end
            end
            
            text_content_bg.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 255))
            end

            function text_content.web()
                text_content.Paint = function(self, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, Color(45, 45, 45, 255))

                    draw.Text({
                        text = "-113",
                        pos = {sm24, sm24},
                        font = "cs_menu_start_3",
                        color = color_white,
                        xalign = TEXT_ALIGN_LEFT,
                        yalign = TEXT_ALIGN_TOP
                    })
                end
            end

            function text_content:PerformLayout()
                self:SetFontInternal("cs_menu_start_2")
            end

            for k,v in pairs(texts) do
                if istable(v) and v[1] == false then
                    local website_link = vgui.Create("DButton", text_content)
                    website_link:SetSize(down_main_content_w, text_size * 1.5)
                    website_link:SetPos(margin - (3 * size_mul), v[2])
                    website_link:SetText("")
                    website_link.double_clicked = false
                    website_link.next_web = 0
                    website_link.Think = function(self)
                        if self.double_clicked and self.next_web < CurTime() then
                            texts = {}
                            website_link.Paint = function() end
                            text_content.web()
                        end
                    end
                    website_link.DoDoubleClick = function(self)
                        if !self.double_clicked then
                            self.next_web = CurTime() + 1.5
                            self.double_clicked = true
                        end
                    end
                    local link_text = "Visit www.Counter-Strike.net"
                    website_link.Paint = function(self, w, h)
                        draw.Text({
                            text = link_text,
                            pos = {0, 0},
                            font = "cs_menu_start_2",
                            color = color_white,
                            xalign = TEXT_ALIGN_LEFT,
                            yalign = TEXT_ALIGN_TOP
                        })
                        if self:IsHovered() then
                            surface.SetDrawColor(255, 255, 255, 255)
                            surface.DrawLine(sm8, sm16, surface.GetTextSize(link_text) + sm8, sm16)
                        end
                    end
                end
            end
            
            CreateCS16Button(down_main_content_x, text_content_h + ((ui_button_h * 2.5) * size_mul), down_menu, size_mul, "OK", TEXT_ALIGN_CENTER, function()
                func_open_select_teams(up_menu, down_menu)
            end)
        end},
        select_team = {
            func = function(up_menu, down_menu)
            for k,v in pairs(down_menu:GetChildren()) do
                v:Remove()
            end
            
            up_menu.Paint = function(self, w, h)
                up_menu.DefaultPaint(self, w, h)
                
                draw.Text({
                    text = "SELECT TEAM",
                    pos = {128 * size_mul, h / 2},
                    font = "cs_menu_start_1",
                    color = cs16_main_color,
                    xalign = TEXT_ALIGN_LEFT,
                    yalign = TEXT_ALIGN_CENTER
                })
            end
            
            local key_tab = { KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_10 }
            local binds = {}

            local num = 0
            for i,v in ipairs(SUBGAMEMODE.CONFIG.MENU_SelectPlayerTeams) do
                num = num + 1
                if istable(v) then
                    binds[i] = {key_tab[num], v.func}
                else
                    num = num + v
                end
            end

            local clicked_next = false
            local function next()
                timer.Remove("model_selection_delay")
                if !clicked_next and current_start_menu == "select_team" then
                    clicked_next = true
                    startmenu_frame:Remove()
                end
            end

            up_menu.Think = function(self)
                if pressed_bind then
                    if !input.IsKeyDown(pressed_bind) then
                        pressed_bind = nil
                    end
                else
                    for k,v in pairs(binds) do
                        if input.IsKeyDown(v[1]) then
                            v[2]()
                            timer.Create("model_selection_delay", 0.15, 1, next)
                            pressed_bind = v[1]
                        end
                    end
                end
            end

            down_menu.Paint = function(self, w, h)
                down_menu.DefaultPaint(self, w, h)
            end

            local last_i = 0
            local last_y = down_main_content_y
            for i,v in ipairs(SUBGAMEMODE.CONFIG.MENU_SelectPlayerTeams) do
                last_i = last_i + 1
                if isnumber(v) then
                    last_i = last_i + v
                else
                    CreateCS16Button(down_main_content_x, last_y, down_menu, size_mul, last_i.." "..v.text, TEXT_ALIGN_LEFT, function()
                        v.func()
                        timer.Create("model_selection_delay", 0.15, 1, next)
                        return
                    end)
                end
                last_y = last_y + ((ui_button_h * 1.5) * size_mul)
            end

            local bw = (ui_button_w * 1.2) * size_mul
            local text_content_h = down_main_content_w * 0.6
            local text_content2 = vgui.Create("DPanel", down_menu)
            text_content2:SetSize(down_main_content_w - bw, text_content_h)
            text_content2:SetPos(down_main_content_x + bw, down_main_content_y)
            text_content2.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, color_black)
                surface.SetDrawColor(cs16_main_color.r, cs16_main_color.g, cs16_main_color.b, 25)
                surface.DrawLine(0, 0, w, 0)
                surface.DrawLine(0, 0, 0, h)
                surface.DrawLine(w-1, 0, w-1, h)
                surface.DrawLine(0, h-1, w, h-1)
            end

            local gap = 4 * size_mul
            local richtext = vgui.Create("RichText", text_content2)
            richtext:Dock(FILL)
            richtext:DockMargin(gap, gap, gap, gap)
            richtext:InsertColorChange(cs16_main_color.r, cs16_main_color.g, cs16_main_color.b, 255)
            richtext:AppendText(SUBGAMEMODE.CONFIG.MENU_MapDescription())
            function richtext:PerformLayout()
                self:SetFontInternal("cs_menu_start_2")
            end
        end},
        select_model = {
            func = function(up_menu, down_menu)
                if (client:CS16Team() != TEAM_T and client:CS16Team() != TEAM_CT) and force_model_team == nil then return end
                for k,v in pairs(down_menu:GetChildren()) do
                    v:Remove()
                end
                
                up_menu.Paint = function(self, w, h)
                    up_menu.DefaultPaint(self, w, h)
                    
                    draw.Text({
                        text = "SELECT MODEL",
                        pos = {128 * size_mul, h / 2},
                        font = "cs_menu_start_1",
                        color = cs16_main_color,
                        xalign = TEXT_ALIGN_LEFT,
                        yalign = TEXT_ALIGN_CENTER
                    })
                end
                
                local key_tab = { KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_10 }
                local binds = {}
    
                local model_list = SUBGAMEMODE.CONFIG.MENU_SelectModels[our_team]
                local num = 0
                for i,v in ipairs(model_list) do
                    num = num + 1
                    if istable(v) then
                        binds[i] = {key_tab[num], v}
                    else
                        num = num + v
                    end
                end
    
                local function next(tab)
                    net.Start("cs16_change_model")
                        net.WriteString(tab.mdl)
                        net.WriteInt(our_team or client:CS16Team(), 4)
                    net.SendToServer()
                    startmenu_frame:Remove()
                end

                up_menu.Think = function(self)
                    if pressed_bind then
                        if !input.IsKeyDown(pressed_bind) then
                            pressed_bind = nil
                        end
                    else
                        for k,v in pairs(binds) do
                            if input.IsKeyDown(v[1]) then
                                next(v[2])
                                pressed_bind = v[1]
                            end
                        end
                    end
                end
    
                down_menu.Paint = function(self, w, h)
                    down_menu.DefaultPaint(self, w, h)
                end

                local selected_model = model_list[1]

                local icon_bg = vgui.Create("DPanel", down_menu)
                local icon = vgui.Create("DImage", icon_bg)
                local text_content3 = vgui.Create("RichText", down_menu)

                local last_i = 0
                local last_y = down_main_content_y
                for i,v in ipairs(model_list) do
                    if !isnumber(v) then
                        last_i = last_i + 1
                        CreateCS16Button(down_main_content_x, last_y, down_menu, size_mul, last_i.." "..v.name, TEXT_ALIGN_LEFT, function()
                            next(v)
                        end, nil, function()
                            if selected_model != v then
                                selected_model = v
                                icon:SetMaterial(selected_model.icon)
                                text_content3:SetText(selected_model.desc)
                            end
                        end)
                    end
                    last_y = last_y + ((ui_button_h * 1.5) * size_mul)
                end
    
                local bw = (ui_button_w * 1.2) * size_mul
                local text_content_h = down_main_content_w * 0.39
                icon_bg:SetSize(down_main_content_w - bw, text_content_h)
                icon_bg:SetPos(down_main_content_x + bw, down_main_content_y)
                icon_bg.Paint = function(self, w, h)
                    draw.RoundedBox(0, 0, 0, w, h, color_black)
                    surface.SetDrawColor(cs16_main_color.r, cs16_main_color.g, cs16_main_color.b, 25)
                    surface.DrawLine(0, 0, w, 0)
                    surface.DrawLine(0, 0, 0, h)
                    surface.DrawLine(w-1, 0, w-1, h)
                    surface.DrawLine(0, h-1, w, h-1)
                end
                icon:Dock(FILL)
                local margin = 4 * size_mul
                icon:DockMargin(margin, margin, margin, margin)
                icon:SetMaterial(selected_model.icon)

                text_content3:SetPos(down_main_content_x + bw, (down_main_content_y + text_content_h) * 1.15)
                text_content3:SetSize(down_main_content_w - bw, 150 * size_mul)
                --text_content3.Paint = function()
                --end
                --text_content3:InsertColorChange(cs16_main_color.r, cs16_main_color.g, cs16_main_color.b, 255)
                local textcolor = Color(cs16_main_color.r, cs16_main_color.g, cs16_main_color.b, 175)
                text_content3:SetText(selected_model.desc)
                function text_content3:PerformLayout()
                    self:SetFontInternal("cs_menu_start_2")
                    self:SetFGColor(textcolor)
                end
            end
        }
    }

    start_menus[current_start_menu].func(up_menu, down_menu)

    startmenu_frame:MakePopup()
end

concommand.Add("chooseteam", function()
    current_start_menu = "select_team"
    CreateStartMenu()
end)

print("Gamemode loaded cl_menu_start.lua")