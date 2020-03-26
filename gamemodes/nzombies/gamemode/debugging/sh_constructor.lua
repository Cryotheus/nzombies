NZ_DEBUG_LOGLEVEL_MAX = 3
NZ_DEBUG_LOGLEVEL_INFO = 2
NZ_DEBUG_LOGLEVEL_ERROR = 1

CreateConVar("nz_log_level", "0", FCVAR_ARCHIVE, "The nz log level.")

function DebugPrint(logLevel, ...)
	local required_lvl = GetConVar("nz_log_level"):GetInt() or 0
	
	if  required_lvl >= logLevel then
		local arg = {...}
		local result = ""
		
		for i = 1, #arg do
			if istable(arg[i]) then PrintTable(arg[i])
			else result = result .. tostring(arg[i]) .. "\t" end
		end
		
		print(result)
	end
end