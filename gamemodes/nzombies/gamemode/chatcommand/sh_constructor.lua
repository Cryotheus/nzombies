-- Chat Commands module
nzChatCommand = nzChatCommand or AddNZModule("chatcommand")
nzChatCommand.commands = nzChatCommand.commands or {}

if CLIENT then nzChatCommand.servercommands = nzChatCommand.servercommands or {} end -- For autocomplete

--[[nzChatCommand.Add
	text		[string]	: The text you put in chat to trigger this command. example: /ready
	realm		[realm]		: The realm this command will work in (SERVER/CLIENT)
	func		[function]	: The function to run when the command is issued. It runs the function with the player as the first argument, then all arguments in the chat seperated by space
	allowAll	[boolean]	: If set to true, will allow even non-admins to run this command ]]

function nzChatCommand.Add(text, realm, func, allowAll, usageHelp)
	if realm or SERVER then -- Always server
		if usageHelp then table.insert(nzChatCommand.commands, {text, func, allowAll and true or false, usageHelp})
		else table.insert(nzChatCommand.commands, {text, func, allowAll and true or false}) end
	elseif CLIENT then table.insert(nzChatCommand.servercommands, {text, allowAll and true or false, usageHelp}) end
end

function nzChatCommand.splitCommand(command)
	--I don't like the [=[ ]=] quotes but it makes sense to use them here
	--I put the contents above so it's easier to read
	--                                 ^(['"])        (['"])$
	local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
	local result = {}
	
	for str in string.gmatch(command, "%S+") do
		local squoted = str:match(spat)
		local equoted = str:match(epat)
		local escaped = str:match([=[(\*)['"]$]=]) --(\*)['"]$
		
		if squoted and not quoted and not equoted then buf, quoted = str, squoted
		elseif buf and equoted == quoted and #escaped % 2 == 0 then str, buf, quoted = buf .. ' ' .. str, nil, nil
		elseif buf then buf = buf .. ' ' .. str end
		
		if not buf then table.insert(result, (str:gsub(spat, ""):gsub(epat, ""))) end
	end
	
	--returning nil just makes it so we still have a value in the arguments table but functions similar to a blank return
	if buf then return nil end
	
	return result
end

if SERVER then
	util.AddNetworkString("nzChatCommand")
	
	local function commandListenerSV(ply, text, public)
		if text[1] == "/" then
			text = string.lower(text)
			
			for _, command in pairs(nzChatCommand.commands) do
				if string.sub(text, 1, string.len(command[1])) == command[1] then
					if not command[3] and not ply:IsSuperAdmin() then
						ply:ChatPrint("[nZ] This command can only be used by administrators.")
						
						return false
					end
					
					local args = nzChatCommand.splitCommand(text)
					
					if args then
						table.remove(args, 1)
						
						print("\"" .. ply:Nick() .. "\" ran nzombies command \"" .. text .. "\"")
						
						return command[2](ply, args) or false
					else
						ply:ChatPrint("[nZ]] Invalid command usage (check for missing quotes).")
						
						return false
					end
				end
			end
			
			ply:ChatPrint("[nZ] No valid command exists with this name, try '/help' for a list of commands.")
		end
	end
	
	--we use a chat hook and net.Recieve as we want player to be able to use chat and console
	hook.Add("PlayerSay", "nzChatCommand", commandListenerSV)
	
	net.Receive("nzChatCommand", function(len, ply)
		if not IsValid(ply) then return end
		
		commandListenerSV(ply, net.ReadString() or "")
	end)
end

if CLIENT then
	local function commandListenerCL( ply, text, public, dead )
		if text[1] == "/" then
			text = string.lower(text)
			
			for _, command in pairs(nzChatCommand.commands) do
				if string.sub(text, 1, string.len(command[1])) == command[1] then
					if command[3] and not ply:IsSuperAdmin() then return true end
					
					if ply == LocalPlayer() then
						local args = nzChatCommand.splitCommand(text)
						
						if args then
							table.remove(args, 1)
							
							return command[2](ply, args) or false
						else
							ply:ChatPrint("[nZ] Invalid command usage (check for missing quotes).")
							
							return false
						end
					end
					
					return true
				end
			end
		end
	end
	
	hook.Add("OnPlayerChat", "nzChatCommandClient", commandListenerCL)
	
	
	local function nz_chatcommand(ply, cmd, args, arg_string)
		--console command nz_chatcommand in case another addon blocks the hooks (works just like chat, "nz_chatcommand [chat commands]")
		if not arg_string then return end
		
		arg_string = string.Trim(arg_string, " ")
		
		if string.sub(arg_string, 1, 1) == "\"" and string.sub(arg_string, #arg_string, #arg_string) == "\"" then arg_string = string.sub(arg_string, 2, #arg_string-1) end -- Trim quotation marks but only if they are around the WHOLE string
		
		net.Start("nzChatCommand")
		net.WriteString(arg_string)
		net.SendToServer()
		
		commandListenerCL(LocalPlayer(), arg_string)
	end
	
	local function nz_chatcommand_autocomplete(cmd, arg_string)
		arg_string = string.lower(string.Trim(arg_string))
		
		local tbl = {}
		
		for _, cmd in pairs(nzChatCommand.servercommands) do
			local cmd_text = cmd[1]
			
			if string.find(cmd_text, arg_string) then
				if cmd[2] or (not cmd[2] and LocalPlayer():IsSuperAdmin()) then
					local text = "nz_chatcommand ".. cmd_text
					
					if not table.HasValue(tbl, text) then table.insert(tbl, text) end
				end
			end
		end
		
		for _, cmd in pairs(nzChatCommand.commands) do
			local cmd_text = cmd[1]
			
			if string.find(cmd_text, arg_string) then
				if cmd[3] or (not cmd[3] and LocalPlayer():IsSuperAdmin()) then
					local text = "nz_chatcommand ".. cmd_text
					
					if not table.HasValue(tbl, text) then table.insert(tbl, text) end
				end
			end
		end

		return tbl
	end
	
	concommand.Add("nz_chatcommand", nz_chatcommand, nz_chatcommand_autocomplete, "Executes a chatcommand without the use of chat, in case chatcommands don't work.")	
end