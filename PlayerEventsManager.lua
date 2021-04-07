--[[
Author(s): Electra Bree & Aaron Spivey

This script manages player events (joining the game, leaving the game, respawning) and refreshes data accordingly
]]--

--// Removes the player's character from the characters folder
function RemoveCharacter(player)
	for index, character in ipairs(workspace.Characters:GetChildren()) do 
		if character.Name == player.Name and character ~= player.Character then 
			character:Destroy()
		end
	end
end

--// Triggered when the player joins the game
game.Players.PlayerAdded:connect(function(player)
	--// Triggered when the player joins or respawns
	player.CharacterAdded:connect(function(char)
		workspace:WaitForChild(player.Name)
		char.Parent = workspace:WaitForChild("Characters")
		local humanoid = char:WaitForChild("Humanoid")
			humanoid.Died:connect(function()
			_G.RemovePlayer(player)
			RemoveCharacter(player)
			player:LoadCharacter(true)
			if (player:FindFirstChild("Stats")) then
				player.Stats.Deaths.Value = player.Stats.Deaths.Value + 1
			end
		end)
	end)
end)

--// Triggered when the player leaves the game
game.Players.PlayerRemoving:connect(function(player)
	_G.RemovePlayer(player)
	RemoveCharacter(player)
end)