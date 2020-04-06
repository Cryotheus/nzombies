local trace_ents = {
	["wall_buys"] = function(ent)
		local wepclass = ent:GetWepClass()
		local price = ent:GetPrice()
		local wep = weapons.Get(wepclass)
		
		if not wep then return "INVALID WEAPON" end
		
		local name = wep.PrintName or wepclass or "INVALID WEAPON"
		local ammo_price = math.Round((price - price % 10) * 0.5)
		local text = ""

		if not LocalPlayer():HasWeapon(wepclass) then text = "Press E to buy " .. name .." for " .. price .. " points."
		elseif string.lower(wep.Primary.Ammo) ~= "none" then
			if LocalPlayer():GetWeapon( wepclass ):HasNZModifier("pap") then text = "Press E to buy " .. wep.Primary.Ammo .."  Ammo refill for " .. 4500 .. " points."
			else text = "Press E to buy " .. wep.Primary.Ammo .."  Ammo refill for " .. ammo_price .. " points." end
		else text = "You already have this weapon." end

		return text
	end,
	["breakable_entry"] = function(ent)
		if ent:GetHasPlanks() and ent:GetNumPlanks() < GetConVar("nz_difficulty_barricade_planks_max"):GetInt() then
			return "Hold " .. input.LookupBinding("+use") .. " to rebuild the barricade."
		end
	end,
	["random_box"] = function(ent)
		if not ent:GetOpen() then
			local text = nzPowerUps:IsPowerupActive("firesale") and "Press " .. input.LookupBinding("+use") .. " to buy a random weapon for 10 points." or "Press " .. input.LookupBinding("+use") .. " to buy a random weapon for 950 points."
			
			return text
		end
	end,
	["random_box_windup"] = function(ent)
		if not ent:GetWinding() and ent:GetWepClass() ~= "nz_box_teddy" then
			local wepclass = ent:GetWepClass()
			local wep = weapons.Get(wepclass)
			local name = "UNKNOWN"
			
			if wep then name = wep.PrintName end
			if not name then name = wepclass end
			
			name = "Press " .. input.LookupBinding("+use") .. " to take " .. name .. " from the box."
			
			return name
		end
	end,
	["perk_machine"] = function(ent)
		local text = ""
		
		if not ent:IsOn() then text = "No Power."
		elseif ent:GetBeingUsed() then text = "Currently in use."
		else
			if ent:GetPerkID() == "pap" then
				local wep = LocalPlayer():GetActiveWeapon()
				
				if wep:HasNZModifier("pap") then
					if wep.NZRePaPText then text = "Press " .. input.LookupBinding("+use") .. " to " .. wep.NZRePaPText .. " for 2000 points."
					elseif wep:CanRerollPaP() then text = "Press " .. input.LookupBinding("+use") .. " to reroll attachments for 2000 points."
					else text = "This weapon is already upgraded." end
				else text = "Press " .. input.LookupBinding("+use") .. " to buy Pack-a-Punch for 5000 points." end
			else
				local perkData = nzPerks:Get(ent:GetPerkID())
				
				text = "Press " .. input.LookupBinding("+use") .. " to buy " .. perkData.name .. " for " .. ent:GetPrice() .. " points."
				
				if LocalPlayer():HasPerk(ent:GetPerkID()) then text = "You already own this perk." end
			end
		end

		return text
	end,
	["player_spawns"] = function() if nzRound:InState(ROUND_CREATE) then return "Player Spawn" end end,
	["nz_spawn_zombie_normal"] = function() if nzRound:InState(ROUND_CREATE) then return "Zombie Spawn" end end,
	["nz_spawn_zombie_special"] = function() if nzRound:InState(ROUND_CREATE) then return "Zombie Special Spawn" end end,
	["pap_weapon_trigger"] = function(ent)
		local wepclass = ent:GetWepClass()
		local wep = weapons.Get(wepclass)
		local name = "UNKNOWN"
		
		if wep then name = nz.Display_PaPNames[wepclass] or nz.Display_PaPNames[wep.PrintName] or "Upgraded " .. wep.PrintName end
		
		return "Press " .. input.LookupBinding("+use") .. " to take " .. name .. " from the machine."
	end,
	["wunderfizz_machine"] = function(ent)
		local text = ""
		
		if not ent:IsOn() then text = "The Wunderfizz Orb is currently at another location."
		elseif ent:GetBeingUsed() then
			if ent:GetUser() == LocalPlayer() and ent:GetPerkID() ~= "" and not ent:GetIsTeddy() then text = "Press " .. input.LookupBinding("+use") .. " to take " .. nzPerks:Get(ent:GetPerkID()).name .. " from Der Wunderfizz."
			else text = "Currently in use." end
		else
			if #LocalPlayer():GetPerks() >= GetConVar("nz_difficulty_perks_max"):GetInt() then text = "You cannot have more perks."
			else text = "Press E to buy Der Wunderfizz for " .. ent:GetPrice() .. " points." end
		end
		
		return text
	end,
}

local door_trace_ents = {
	"func_brush" = true,
	"class C_BaseEntity" = true
}

local function GetTarget()
	local settings =  {
		start = EyePos(),
		endpos = EyePos() + LocalPlayer():GetAimVector() * 150,
		filter = LocalPlayer()}
	local trace = util.TraceLine(settings)
	
	if not trace.Hit then return end
	if not trace.HitNonWorld then return end
	
	return trace.Entity
end

local function GetDoorText(ent)
	local door_data = ent:GetDoorData()
	local text = ""
	
	if door_data and tonumber(door_data.price) == 0 and nzRound:InState(ROUND_CREATE) then
		if tobool(door_data.elec) then text = "This door will open when electricity is turned on."
		else text = "This door will open on game start." end
	elseif door_data and tonumber(door_data.buyable) == 1 then
		local price = tonumber(door_data.price)
		local req_elec = tobool(door_data.elec)
		local link = door_data.link
		
		if ent:IsLocked() then
			if req_elec and !IsElec() then text = "You must turn on the electricity first!"
			elseif door_data.text then text = door_data.text
			elseif price ~= 0 then text = "Press " .. input.LookupBinding("+use") .. " to open for " .. price .. " points." end
		end
	elseif door_data and tonumber(door_data.buyable) ~= 1 and nzRound:InState(ROUND_CREATE) then text = "This door is locked and cannot be bought in-game." end
	
	return text
end

local function GetText(ent)
	if not IsValid(ent) then return "" end
	if ent.GetNZTargetText then return ent:GetNZTargetText() end
	
	local class = ent:GetClass()
	local itemcategory = ent:GetNWString("NZItemCategory")
	local neededcategory, deftext, hastext = ent:GetNWString("NZRequiredItem"), ent:GetNWString("NZText"), ent:GetNWString("NZHasText")
	local text = ""
	
	if neededcategory ~= "" then
		local hasitem = LocalPlayer():HasCarryItem(neededcategory)
		
		text = hasitem and hastext ~= "" and hastext or deftext
	elseif deftext ~= "" then text = deftext
	elseif itemcategory ~= "" then
		local item = nzItemCarry.Items[itemcategory]
		local hasitem = LocalPlayer():HasCarryItem(itemcategory)
		
		if hasitem then text = item and item.hastext or "You already have this."
		else text = item and item.text or "Press " .. input.LookupBinding("+use") .. " to pick up." end
	elseif ent:IsPlayer() then
		if ent:GetNotDowned() then text = ent:Nick() .. " - " .. ent:Health() .. " HP"
		else text = "Hold " .. input.LookupBinding("+use") .. " to revive "..ent:Nick() end
	elseif ent:IsDoor() or ent:IsButton() or door_trace_ents[ent:GetClass()] or ent:IsBuyableProp() then text = GetDoorText(ent)
	else text = trace_ents[class] and trace_ents[class](ent) end
	
	return text
end

local function GetMapScriptEntityText()
	local text = ""

	for _, v in pairs(ents.FindByClass("nz_script_triggerzone")) do
		local dist = v:NearestPoint(EyePos()):Distance(EyePos())
		
		if dist <= 1 then
			text = GetDoorText(v)
			
			break
		end
	end

	return text
end

local function DrawTargetID(text)
	if not text then return end
	
	local font = "nz.display.hud.small"
	
	surface.SetFont(font)
	
	local w, h = surface.GetTextSize(text)
	local mouse_x, mouse_y = gui.MousePos()

	if mouse_x == 0 and mouse_y == 0 then
		mouse_x = ScrW() / 2
		mouse_y = ScrH() / 2
	end
	
	local x = mouse_x
	local y = mouse_y
	
	x = x - w / 2
	y = y + 30
	
	--the fonts internal drop shadow looks lousy with AA on
	draw.SimpleText(text, font, x + 1, y + 1, color_white)
end

function GM:HUDDrawTargetID()
	local ent = GetTarget()

	if ent then DrawTargetID(GetText(ent))
	else DrawTargetID(GetMapScriptEntityText()) end
end