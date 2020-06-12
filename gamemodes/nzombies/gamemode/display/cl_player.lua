local function shuffle(source)
	local source_copy = table.Copy(source)
	local shuffled = {}
	local source_copy_count = table.Count(source_copy)
	
	while source_copy_count > 0 do
		local index = math.random(source_copy_count)
		
		table.insert(shuffled, source_copy[index])
		table.remove(source_copy, index)
		
		source_copy_count = table.Count(source_copy)
	end
	
	return shuffled
end

local blood_decals = shuffle{
	Material("bloodline_score1.png", "unlitgeneric smooth"),
	Material("bloodline_score2.png", "unlitgeneric smooth"),
	Material("bloodline_score3.png", "unlitgeneric smooth"),
	Material("bloodline_score4.png", "unlitgeneric smooth"),
	nil --we HAVE to have nil here because Material has two return values and that second value gets placed in the next slot of the table
}

local player_colors = shuffle{
	Color(239, 154, 154),
	Color(244, 143, 177),
	Color(159, 168, 218),
	Color(129, 212, 250),
	Color(128, 203, 196),
	Color(165, 214, 167),
	Color(230, 238, 156),
	Color(255, 241, 118),
	Color(255, 224, 130),
	Color(255, 171, 145),
	Color(161, 136, 127),
	Color(224, 224, 224),
	Color(144, 164, 174)
}

function player.GetBloodByIndex(index) return blood_decals[(index - 1) % #blood_decals + 1] end
function player.GetColorByIndex(index) return player_colors[(index - 1) % #player_colors + 1] end