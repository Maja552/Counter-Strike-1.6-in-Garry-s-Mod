
killicons_new = {}

if NewKillIcons == nil then
    NewKillIcons = {}
end

local TYPE_FONT 	= 0
local TYPE_TEXTURE 	= 1

function killicons_new.AddFont( name, font, character, color )

	NewKillIcons[name] = {}
	NewKillIcons[name].type 		= TYPE_FONT
	NewKillIcons[name].font 		= font
	NewKillIcons[name].character 	= character
	NewKillIcons[name].color 		= color

end

function killicons_new.Add( name, material, color )

	NewKillIcons[name] = {}
	NewKillIcons[name].type 		= TYPE_TEXTURE
	NewKillIcons[name].texture		= surface.GetTextureID( material )
	NewKillIcons[name].color 		= color

end

function killicons_new.AddAlias( name, alias )

	NewKillIcons[name] = NewKillIcons[alias]

end

function killicons_new.Exists( name )

	return NewKillIcons[name] != nil

end

function killicons_new.GetSize( name )

	if (!NewKillIcons[name]) then 
		Msg("Warning: killicon not found '"..name.."'\n")
		NewKillIcons[name] = NewKillIcons["default"]
	end
	
	local t = NewKillIcons[name]
	
	-- Cached
	if (t.size) then
		return t.size.w, t.size.h
	end
	
	local w, h = 0
	
	if ( t.type == TYPE_FONT ) then
	
		surface.SetFont( t.font )
		w, h = surface.GetTextSize( t.character )
		
	end
	
	if ( t.type == TYPE_TEXTURE ) then
	
		-- Estimate the size from the size of the font
		surface.SetFont( "HL2MPTypeDeath" )
		w, h = surface.GetTextSize( "0" )
		
		-- Fudge it slightly
		h = h * 0.75
		
		-- Make h/w 1:1
		local tw, th = surface.GetTextureSize( t.texture )
		w = tw * (h / th)
		
	end
	
	t.size = {}
	t.size.w = w or 32
	t.size.h = h or 32
	
	return w, h

end

local max_h = 28

function killicons_new.Draw( x, y, name, alpha )
	alpha = alpha or 255

	if !NewKillIcons[name] then 
		Msg("Warning: killicon not found '"..name.."'\n")
		NewKillIcons[name] = NewKillIcons["default"]
	end
	
	local t = NewKillIcons[name]
	
	if ( !t.size ) then	killicons_new.GetSize( name )	end
	
	local w = t.size.w
	local h = t.size.h

    if h > max_h then
        w = w * (max_h / h)
        h = max_h
    end


	x = x - w * 0.5
	
	
	if t.type == TYPE_FONT then
	
		y = y - h * 0.1
		surface.SetTextPos( x, y )
		surface.SetFont( t.font )
		surface.SetTextColor( t.color.r, t.color.g, t.color.b, alpha )
		surface.DrawText( t.character )

	end
	
	if t.type == TYPE_TEXTURE then
	
		y = y - h * 0.3
        y = y + 3
		surface.SetTexture( t.texture )
		surface.SetDrawColor( t.color.r, t.color.g, t.color.b, alpha )
		surface.DrawTexturedRect( x, y, w, h )

	end
	
end

--AddFont( "default", "HL2MPTypeDeath", "6", Color( 255, 240, 10, 255 ) )

local Color_Icon = Color( 255, 80, 0, 255 ) 

killicons_new.Add( "default", "HUD/killicons/default", Color_Icon )
killicons_new.AddAlias( "suicide", "default" )

print("Gamemode loaded cl_killicons.lua")