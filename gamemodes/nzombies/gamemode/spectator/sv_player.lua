local ply_meta = FindMetaTable("Player")

AccessorFunc(ply_meta, "iSpectatingID", "SpectatingID", FORCE_NUMBER)
AccessorFunc(ply_meta, "iSpectatingType", "SpectatingType", FORCE_NUMBER)

function ply_meta:SetSpectator()
	if self:Alive() then self:KillSilent() end
	
	self:SetTeam(TEAM_SPECTATOR)
	self:SetSpectatingType(OBS_MODE_CHASE)
	self:Spectate(self:GetSpectatingType())
	self:SetSpectatingID(1)
end
