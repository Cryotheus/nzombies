if SERVER then
	nzCurves = nzCurves or AddNZModule("Curves")
	
	function nzCurves.GenerateHealthCurve(round)
		local base = GetConVar("nz_difficulty_zombie_health_base"):GetFloat()
		local scale = GetConVar("nz_difficulty_zombie_health_scale"):GetFloat()
		
		return math.Round(base * math.pow(scale, round - 1))
	end
	
	function nzCurves.GenerateMaxZombies(round)
		local base = GetConVar("nz_difficulty_zombie_amount_base"):GetInt()
		local scale = GetConVar("nz_difficulty_zombie_amount_scale"):GetFloat()
		
		return math.Round((base + (scale * (#player.GetAllPlaying() - 1))) * round)
	end
	
	function nzCurves.GenerateSpeedTable(round)
		if not round then return {[50] = 100} end --Default speed for any invalid round (Say, creative mode test zombies)
		
		local max = 300 --Maximum speed
		local maxround = 27 --The round at which the 300 speed has its tip
		local min = 30 --Minimum speed (Round 1)
		local range = 3 --The range on either side of the tip (current round) of speeds in steps of "steps"
		local steps = (max - min) / maxround --The different speed steps speed can exist in
		local tbl = {}
		
		for i = -range, range do
			local speed = min - steps + steps * round + steps * i
			
			if speed >= min and speed <= max then tbl[speed] = 100 - 10 * math.abs(i) ^ 2 --chance
			elseif speed >= max then tbl[max] = 100 end
		end
		
		return tbl
	end
end