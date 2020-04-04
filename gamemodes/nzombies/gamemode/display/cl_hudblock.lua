local hud_functions = {
	["CHudAmmo"] = function() return false end,
	["CHudBattery"] = function() if LocalPlayer() then return LocalPlayer():Health() > 0 end return false end,
	["CHudWeaponSelection"] = function() return not nzRound:InProgress() and not nzRound:InState(ROUND_GO) end,
	["CHudHealth"] = function() return GetConVar("nz_bloodoverlay"):GetBool() end,
	["CHudSecondaryAmmo"] = function() return false end
}

hook.Add("HUDShouldDraw", "HideHUD", function(name) if hud_functions[name] then return hud_functions[name]() end end)