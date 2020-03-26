function GM:ContextMenuOpen() return nzRound:InState(ROUND_CREATE) and LocalPlayer():IsAdmin() end

function GM:PopulateMenuBar(panel)
	panel:Remove()
	
	return false
end

function GM:OnUndo(name, custom_text)
	if not custom_text then notification.AddLegacy("Undone " .. name, NOTIFY_UNDO, 2)
	else notification.AddLegacy(custom_text, NOTIFY_UNDO, 2) end
	
	surface.PlaySound("buttons/button15.wav")
end
