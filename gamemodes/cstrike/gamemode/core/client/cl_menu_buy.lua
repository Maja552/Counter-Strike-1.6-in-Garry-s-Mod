
surface.CreateFont("GH_BMenu_1", {
    font = "Tahoma",
    extended = false,
    size = 23,
    weight = 0,
    blursize = 0,
    scanlines = 1,
    antialias = true,
    additive = true
})

local function change_page()
    buymenu_h = buymenu_current_page.buymenu_height
    if buymenu_h == nil then
        buymenu_h = (5 + #buymenu_current_page.buttons) * 24
    end
end

function buymenu_open_next_page(name)
    buymenu_current_page = buy_menu_pages[name]
    change_page()
end

function buymenu_try_to_buy(name)
    net.Start("cs16_trytobuy")
        net.WriteString(name)
    net.SendToServer()

    timer.Simple(0.1, force_remove_buymenu)
    --force_remove_buymenu()
end

function buymenu_choose_class(name)
    net.Start("cs16_chooseclass")
        net.WriteString(name)
    net.SendToServer()

    --timer.Simple(0.1, force_remove_buymenu)
    force_remove_buymenu()
end

buymenu_current_page = nil

local buymenu_w = 300
local buymenu_h = 336
local buymenu_color1 = Color(255, 238, 0, 200)
local buymenu_color2 = Color(255, 255, 255, 255)

buymenu_enabled = false

hook.Add("HUDPaint", "CS16_BuyMenu_HUDPaint", function()
    if buymenu_enabled and (SUBGAMEMODE.CONFIG.CAN_BUY_ANYWHERE or LocalPlayer():GetNWBool("CanBuy", false)) and buymenu_current_page then
        local y_offset = ScrH() / 2.2

        draw.DrawText(buymenu_current_page.page_name, "GH_BMenu_1", 8, y_offset, buymenu_color1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        local last_y = 48 + y_offset
        local num = 0
        for k,v in pairs(buymenu_current_page.buttons) do
            if istable(v) then
                num = num + 1
                local text = v[1]
                if istable(text) then
                    draw.DrawText(num..". "..text[1], "GH_BMenu_1", 8, last_y, buymenu_color2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    local last_x = ScrW() / 5
                    for i=2, #text do
                        draw.DrawText(text[i], "GH_BMenu_1", last_x, last_y, buymenu_color1, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                        last_x = last_x + 200
                    end
                else
                    draw.DrawText(num..". "..text, "GH_BMenu_1", 8, last_y, buymenu_color2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
                
            end
            last_y = last_y + 24
        end

        if buymenu_current_page != buy_menu_pages.main then
            draw.DrawText("9. Prev", "GH_BMenu_1", 8, y_offset + buymenu_h - 48, buymenu_color2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end

        draw.DrawText("0. Exit", "GH_BMenu_1", 8, y_offset + buymenu_h - 24, buymenu_color2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end
end)

function CreateBuyMenu()
    if !LocalPlayer():GetNWBool("CanBuy", false) then
        return
    end
    
    --buy_menu_pages = table.Copy(SUBGAMEMODE.CONFIG.MENU_BuyMenuPages)
    buy_menu_pages = SUBGAMEMODE.MENU_GetBuyMenuPages()
    if buy_menu_pages == nil then return end

    buymenu_current_page = buy_menu_pages.main
    buymenu_h = buymenu_current_page.buymenu_height
    if buymenu_h == nil then
        buymenu_h = (5 + #buymenu_current_page.buttons) * 24
    end

    buymenu_w = ScrW()

    buymenu_enabled = !buymenu_enabled
    /*
    --buymenu_frame:SetPos(0, ScrH() / 2.2)
    --buymenu_frame:SetSize(buymenu_w, buymenu_h)

    buymenu_frame.Think = function(self)
        if !LocalPlayer():GetNWBool("CanBuy", false) then
            buymenu_frame:Remove()
            return
        end
    end
    */
end

function force_remove_buymenu()
    buymenu_enabled = false
    buymenu_current_page = nil
end

local function cs16_buymenu_keybinds(ply, bind, pressed)
    if pressed and buymenu_enabled and buymenu_current_page then
        if string.find(bind, "slot0") then
            force_remove_buymenu()
            return true

        elseif string.find(bind, "slot9") then
            buymenu_current_page = buy_menu_pages.main
            change_page()
            return true
        end

        local num = 0
        for k,v in pairs(buymenu_current_page.buttons) do
            if istable(v) then
                num = num + 1
                if string.find(bind, "slot"..num) then
                    if v[2] == "open_page" then
                        buymenu_open_next_page(v[3])

                    elseif v[2] == "buy" then
                        buymenu_try_to_buy(v[3])

                    elseif v[2] == "choose_class" then
                        buymenu_choose_class(v[3])
                    end
                    return true
                end
            end
        end
    end
end
hook.Add("PlayerBindPress", "hook_cs16_buymenu_keybinds", cs16_buymenu_keybinds)

concommand.Add("buy", function()
    if buymenu_enabled then
        force_remove_buymenu()
    else
        CreateBuyMenu()
    end
end)

concommand.Add("drop", function()
    net.Start("cs16_dropweapon")
    net.SendToServer()
end)

/*
local clicked_b = false
local function cs16_tick_buymenu()
    if !GM_INITIALIZED then return end

    if !LocalPlayer():IsSpectator() and LocalPlayer():Alive() then
        if input.IsKeyDown(KEY_B) then
            if clicked_b == false then
                clicked_b = true
                if buymenu_enabled then
                    force_remove_buymenu()
                else
                    if game_state == GAMESTATE_PREPARING then
                        CreateBuyMenu()
                    end
                end
            end
        else
            clicked_b = false
        end
    end
end
hook.Add("Tick", "hook_cs16_tick_buymenu", cs16_tick_buymenu)
*/

net.Receive("cs16_getmoney", function(len)
    local ent = net.ReadEntity()
    ent.cs16_money = net.ReadInt(16)
end)

print("Gamemode loaded cl_menu_buy.lua")