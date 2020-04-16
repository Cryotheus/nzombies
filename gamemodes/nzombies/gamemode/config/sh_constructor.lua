-- Main Tables
nzConfig = nzConfig or AddNZModule("Config")

nzConfig.ValidEnemies = {
	["nz_zombie_walker"] = {
		Valid = true,
		ScaleDMG = function(zombie, hitgroup, dmginfo) if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage(2) end end,
		OnHit = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			
			if attacker:IsPlayer() and attacker:GetNotDowned() then attacker:GivePoints(10) end
		end,
		OnKilled = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				if dmginfo:GetDamageType() == DMG_CLUB then attacker:GivePoints(130)
				elseif hitgroup == HITGROUP_HEAD then attacker:GivePoints(100)
				else attacker:GivePoints(50) end
			end
		end
	},
	["nz_zombie_special_burning"] = {
		Valid = true,
		ScaleDMG = function(zombie, hitgroup, dmginfo) if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage(2) end end,
		OnHit = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			
			if attacker:IsPlayer() and attacker:GetNotDowned() then attacker:GivePoints(10) end
		end,
		OnKilled = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				if dmginfo:GetDamageType() == DMG_CLUB then attacker:GivePoints(130)
				elseif hitgroup == HITGROUP_HEAD then attacker:GivePoints(100)
				else attacker:GivePoints(50) end
			end
		end
	},
	["nz_zombie_special_dog"] = {
		Valid = true,
		SpecialSpawn = true,
		ScaleDMG = function(zombie, hitgroup, dmginfo) if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage(2) end end,
		OnHit = function(zombie, dmginfo, hitgroup) local attacker = dmginfo:GetAttacker() if attacker:IsPlayer() and attacker:GetNotDowned() then attacker:GivePoints(10) end end,
		OnKilled = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				if dmginfo:GetDamageType() == DMG_CLUB then attacker:GivePoints(130)
				elseif hitgroup == HITGROUP_HEAD then attacker:GivePoints(100)
				else attacker:GivePoints(50) end
			end
		end
	}
}
nzConfig.WeaponBlackList = {}
nzConfig.WeaponWhiteList = {"fas2_", "m9k_", "cw_"}

function nzConfig.AddWeaponToBlacklist(class, remove) nzConfig.WeaponBlackList[class] = remove and nil or true end

if not ConVarExists("nz_randombox_whitelist") then CreateConVar("nz_randombox_whitelist", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}) end
if not ConVarExists("nz_downtime") then CreateConVar("nz_downtime", 45, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_nav_grouptargeting") then CreateConVar("nz_nav_grouptargeting", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_round_special_interval") then CreateConVar("nz_round_special_interval", 6, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_round_prep_time") then CreateConVar("nz_round_prep_time", 10, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_randombox_maplist") then CreateConVar("nz_randombox_maplist", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_round_dropins_allow") then CreateConVar("nz_round_dropins_allow", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_zombie_amount_base") then CreateConVar("nz_difficulty_zombie_amount_base", 6, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_zombie_amount_scale") then CreateConVar("nz_difficulty_zombie_amount_scale", 0.35, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_zombie_health_base") then CreateConVar("nz_difficulty_zombie_health_base", 75, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_zombie_health_scale") then CreateConVar("nz_difficulty_zombie_health_scale", 1.1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_max_zombies_alive") then CreateConVar("nz_difficulty_max_zombies_alive", 35, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_barricade_planks_max") then CreateConVar("nz_difficulty_barricade_planks_max", 6, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_powerup_chance") then CreateConVar("nz_difficulty_powerup_chance", 2, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_difficulty_perks_max") then CreateConVar("nz_difficulty_perks_max", 4, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_point_notification_clientside") then CreateConVar("nz_point_notification_clientside", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}) end
if not ConVarExists("nz_zombie_lagcompensated") then CreateConVar("nz_zombie_lagcompensated", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}) end
if not ConVarExists("nz_spawnpoint_update_rate") then CreateConVar("nz_spawnpoint_update_rate", 4, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}) end
if not ConVarExists("nz_rtv_time") then CreateConVar("nz_rtv_time", 45, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}) end
if not ConVarExists("nz_rtv_enabled") then CreateConVar("nz_rtv_enabled", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}) end

nzConfig.AddWeaponToBlacklist("cw_base")
nzConfig.AddWeaponToBlacklist("fas2_ammobox")
nzConfig.AddWeaponToBlacklist("fas2_base")
nzConfig.AddWeaponToBlacklist("fas2_ifak")
nzConfig.AddWeaponToBlacklist("nz_grenade")
nzConfig.AddWeaponToBlacklist("nz_multi_tool")
nzConfig.AddWeaponToBlacklist("nz_one_inch_punch") -- Nope! You gotta give this with special map scripts
nzConfig.AddWeaponToBlacklist("nz_perk_bottle")
nzConfig.AddWeaponToBlacklist("nz_quickknife_crowbar")
nzConfig.AddWeaponToBlacklist("nz_tool_base")
nzConfig.AddWeaponToBlacklist("weapon_base")
nzConfig.AddWeaponToBlacklist("weapon_dod_sim_base")
nzConfig.AddWeaponToBlacklist("weapon_dod_sim_base_shot")
nzConfig.AddWeaponToBlacklist("weapon_dod_sim_base_snip")
nzConfig.AddWeaponToBlacklist("weapon_fists")
nzConfig.AddWeaponToBlacklist("weapon_flechettegun")
nzConfig.AddWeaponToBlacklist("weapon_medkit")
nzConfig.AddWeaponToBlacklist("weapon_sim_admin")
nzConfig.AddWeaponToBlacklist("weapon_sim_spade")

if SERVER then
	nzConfig.RoundData = {}

	--[[Available fields:
	normalCount		[optional][number]		:	how many of the normalTypes zombies will spawn. overrides the default curves
	normalCountMod	[optional][function]	:	if you'd like to, you can use a function instead of a number to determine the amount of normalTypes zombies that will spawn. overrides the default curves and normalCount
	normalDelay		[optional][number]		:	delay between spawns of the normalTypes zombies
	normalTypes		[required][table]		:	table with keys determining the class and the value is a table with a chance key set to the chance, use this to choose what zombies spawn
	special			[optional][bool]		:	if this is set, flags the round as special. fog will appear, the "FETCH ME THEIR SOOOUUULS" sound will play, etc.
	specialCount	[optional][number]		:	how many of the specialTypes zombies will spawn. if this is not set the zombie amount will be doubled
	specialTypes	[optional][table]		:	table with keys determining the class and the value is a table with a chance key set to the chance, use this to choose what zombies spawn]]
	
	nzConfig.RoundData[1] = {normalTypes = {["nz_zombie_walker"] = {chance = 100}}}
	nzConfig.RoundData[2] = {normalTypes = {["nz_zombie_walker"] = {chance = 100}}}
	nzConfig.RoundData[13] = {normalTypes = {["nz_zombie_walker"] = {chance = 75}, ["nz_zombie_special_burning"] = {chance = 25}}}
	nzConfig.RoundData[14] = {normalTypes = {["nz_zombie_walker"] = {chance = 100}}}
	nzConfig.RoundData[23] = {normalTypes = {["nz_zombie_walker"] = {chance = 90}, ["nz_zombie_special_burning"] = {chance = 10}}}
	
	--fas2_p226, fas2_ots33, fas2_glock20, weapon_pistol
	nzConfig.BaseStartingWeapons = {"fas2_glock20"} 
end