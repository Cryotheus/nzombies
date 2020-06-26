local CATEGORY_NAME = "nZombies"
local current_points_mult = 1

--completes
local ulx_give_perk_completes = {}

--completes construction
local function construct_gm_dependent()
	for id in pairs(nzPerks.Data) do table.insert(ulx_give_perk_completes, id) end
	
end

if not nz then
	--if the gamemode has not yet loaded, create a hook to make the completes when the gamemode loads
	hook.Add("PostGamemodeLoaded", "nzULXComms", function()
		construct_gm_dependent()
		hook.Remove("PostGamemodeLoaded", "nzULXComms")
	end)
else construct_gm_dependent() end

--local functions
local function is_active_player(ply) return ply:Alive() and (ply:IsPlaying() or nzRound:InState(ROUND_CREATE)) end

--hooks
hook.Add("OnPlayerGetPoints", "nzULXComms", function(ply, amount) return math.Round(amount * current_points_mult) end)

--ulx functions
function ulx.argtypes(ply, targets, num, str, bool) print(ply, targets, num, str, bool) end

function ulx.nzgiveperk(ply, targets, perk)
	local perk_data = nzPerks:Get(perk)
	
	if perk_data then
		local receivers = {}
		
		for _, target in pairs(targets) do
			if is_active_player(target) then
				table.insert(receivers, target)
				
				target:GivePerk(perk)
			end
		end
		
		ulx.fancyLogAdmin(ply, true, "#A gave #T the " .. perk_data.name .. " perk.", receivers)
	end
end

function ulx.nzgivepoints(ply, targets, amount)
	local receivers = {}
	
	for _, target in pairs(targets) do
		if is_active_player(target) then
			table.insert(receivers, target)
			
			target:GivePoints(amount)
		end
	end
	
	ulx.fancyLogAdmin(ply, true, "#A gave #T " .. amount .. (amount == 1 and " point." or " points."), receivers)
end

function ulx.nzpointmultiplier(ply, multiplier)
	current_points_mult = multiplier
	
	ulx.fancyLogAdmin(ply, "#A set the point multiplier to " .. multiplier .. "x.")
end

--command definitions
local ulx_arg_types = ulx.command(CATEGORY_NAME, "ulx argtypes", ulx.argtypes)
ulx_arg_types:addParam{["type"] = ULib.cmds.PlayersArg}
ulx_arg_types:addParam{["type"] = ULib.cmds.NumArg, ["min"] = 0, ["hint"] = "points", ULib.cmds.round}
ulx_arg_types:addParam{["type"] = ULib.cmds.StringArg, ["hint"] = "skill", ["completes"] = {}}
ulx_arg_types:addParam{["type"] = ULib.cmds.BoolArg, ULib.cmds.optional, ["hint"] = "prestiege"}
ulx_arg_types:defaultAccess(ULib.ACCESS_SUPERADMIN)

local ulx_give_perk = ulx.command(CATEGORY_NAME, "ulx nzgiveperk", ulx.nzgiveperk)
ulx_give_perk:addParam{["type"] = ULib.cmds.PlayersArg}
ulx_give_perk:addParam{["type"] = ULib.cmds.StringArg, ["hint"] = "id", ["completes"] = ulx_give_perk_completes}
ulx_give_perk:defaultAccess(ULib.ACCESS_SUPERADMIN)

local ulx_give_points = ulx.command(CATEGORY_NAME, "ulx nzgivepoints", ulx.nzgivepoints)
ulx_give_points:addParam{["type"] = ULib.cmds.PlayersArg}
ulx_give_points:addParam{["type"] = ULib.cmds.NumArg, ["min"] = 1, ["hint"] = "points", ULib.cmds.round}
ulx_give_points:defaultAccess(ULib.ACCESS_SUPERADMIN)

local ulx_point_multiplier = ulx.command(CATEGORY_NAME, "ulx nzpointmultiplier", ulx.nzpointmultiplier)
ulx_point_multiplier:addParam{["type"] = ULib.cmds.NumArg, ["min"] = 0, ["hint"] = "multiplier"}
ulx_point_multiplier:defaultAccess(ULib.ACCESS_SUPERADMIN)