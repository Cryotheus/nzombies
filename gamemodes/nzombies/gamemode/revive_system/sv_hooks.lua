local defaultdata = {
	DownTime = true,
	ReviveTime = true,
	RevivePlayer = true
}

function nzRevive:PlayerDowned(ply)
	local attdata = {}
	-- Attach whatever other data was attached to the table, other than the default ones
	for k, v in pairs(nzRevive.Players[ply:EntIndex()]) do if not defaultdata[k] then attdata[k] = v end end
	
	self:SendPlayerDowned(ply, nil, attdata)
end

function nzRevive:PlayerRevived(ply) self:SendPlayerRevived(ply) end
function nzRevive:PlayerBeingRevived(ply, revivor) self:SendPlayerBeingRevived(ply, revivor) end
function nzRevive:PlayerNoLongerBeingRevived(ply) self:SendPlayerBeingRevived(ply) end -- No second argument means no revivor
function nzRevive:PlayerKilled(ply) self:SendPlayerKilled(ply) end