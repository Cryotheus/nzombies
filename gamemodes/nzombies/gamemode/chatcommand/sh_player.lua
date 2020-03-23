function player.GetByName(name)
	for _, ply in ipairs(player.GetHumans()) do if string.find(string.lower(ply:Nick()), string.lower(name), 1, true) then return ply end end
	
	return nil
end