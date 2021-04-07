--[[
Author(s): Electra Bree & Aaron Spivey

This script holds all the global functions in which other server scripts call
]]--

--// Configuration (can be edited)
previous_music = 0
open_height = 7.7
open_timer = 30
speed = 0.3
wall_speed = 0.3

--// Variables
datastore = game:GetService("DataStoreService"):GetDataStore("PurchaseHistory")
direction = "Up"
wall_stopped = false

--// Arrays
music = game.ServerStorage.ElevatorMusic:GetChildren()
new_maps = game.ServerStorage.NewMaps:GetChildren()
surfaces = workspace.Background:GetChildren()
added_songs = {}
elevator_players = {}
elevator_npcs = {}
maps = {}

require(3445337105)
wait()

--// Counts down intermission from given seconds and opens the door if given true, otherwise the door remains closed
_G["timer"] = function(seconds, bool)
	for timer = seconds, 0, -1 do wait(1)
		workspace.Elevator.Notifier.Timer.SurfaceGui.Time.Text = timer
	end
	if bool == true then
		_G.StopWall(true)
		_G.StopMusic()
	else
		_G.ChangeLightColor("Medium stone grey")
		_G.StartWall()
		_G.TeleportPlayers()
	end
end

--// Adds a given song to the song queue
_G["add_song"] = function(song_id)
	local song = "rbxassetid://"..song_id
	table.insert(added_songs, song)
end

--// Removes the song from the song queue
_G["remove_song"] = function()
	table.remove(added_songs,1)
end

--// Returns the song array
_G["return_songs"] = function()
	return added_songs
end

--// Toggles anti-gravity for a given player - bool is true to activate anti-gravity
_G["anti_gravity"] = function(player,bool)
	game.ReplicatedStorage.ToggleAnti:FireClient(player,bool)
end

--// Breaks the elevator
_G["malfunction"] = function(description) 
	for i = 1, #elevator_players do
		delay(0,function()
			local player = game.Players:FindFirstChild(elevator_players[i])
			if player then
				player.PlayerGui.GameUI.Malfunction.Description.Text = description
				player.PlayerGui.GameUI.Malfunction:TweenPosition(UDim2.new(0.77, 0,0.851, 0), 'Out', 'Quad', 0.3, true)
				wait(10)
				player.PlayerGui.GameUI.Malfunction:TweenPosition(UDim2.new(1, 0,0.851, 0), 'Out', 'Quad', 0.3, true)
				wait(0.4)
				player.PlayerGui.GameUI.Malfunction.Description.Text = ""
			end
		end)
	end
end

--// Disables door barrier, allowing players to exit the elevator
_G["disable_barrier"] = function()
	workspace.Elevator.Door.Barrier.Transparency = 1
	workspace.Elevator.Door.Barrier.CanCollide = false
end

--// Enables door barrier, trapping players inside the elevator
_G["enable_barrier"] = function()
	workspace.Elevator.Door.Barrier.Transparency = 1
	workspace.Elevator.Door.Barrier.CanCollide = true
end

--// Sets the state of the elevator walls to active/moving
_G["start_wall"] = function()
	game.ServerScriptService.ElevatorWallScript.Stopped.Value = false
end

--// Sets the state of the elevator walls to stopped
_G["stop_wall"] = function()
	game.ServerScriptService.ElevatorWallScript.Stopped.Value = true
end

--// opens the elevator door - this is controlled by G.timer() function, but can call this function to manually open the door
_G["open_door"] = function() 
	workspace.Elevator.Door.TopDoor.FX:Play()
	for time = 0, open_timer, 1 do wait()
		if (workspace.Elevator.Door.TopDoor.CFrame.p - workspace.Elevator.Door.TopDoor.CFrame.p+Vector3.new(5.5,open_height,5.5)).magnitude > .001 then
			workspace.Elevator.Door.TopDoor.CFrame = workspace.Elevator.Door.TopDoor.CFrame:Lerp(workspace.Elevator.Door.TopDoor.CFrame - Vector3.new(5.5,open_height,5.5) * workspace.Elevator.Door.BottomDoor.CFrame.upVector, speed)
			workspace.Elevator.Door.BottomDoor.CFrame = workspace.Elevator.Door.BottomDoor.CFrame:Lerp(workspace.Elevator.Door.BottomDoor.CFrame - Vector3.new(5.5,open_height,5.5) * workspace.Elevator.Door.TopDoor.CFrame.upVector, speed)
		end
	end
end

--// close the elevator door - this is controlled by G.timer() function, but can call this function to manually close the door
_G["close_door"] = function()
	workspace.Elevator.Door.TopDoor.FX:Play()
	for time = 0, open_timer, 1 do wait()
		if (workspace.Elevator.Door.TopDoor.CFrame.p - workspace.Elevator.Door.TopDoor.CFrame.p).magnitude > .001 then
			workspace.Elevator.Door.TopDoor.CFrame = workspace.Elevator.Door.TopDoor.CFrame:Lerp(workspace.Elevator.Door.TopDoor.CFrame, speed)
			workspace.Elevator.Door.BottomDoor.CFrame = workspace.Elevator.Door.BottomDoor.CFrame:Lerp(workspace.Elevator.Door.BottomDoor.CFrame, speed)
		end
	end
end

--// Toggles the elevator lights with a given boolean, bool - which is true when the lights are to be turned off
_G["toggle_lights"] = function(bool)
	if bool == true then
		workspace.Elevator.Lights.TopLight.Light.Enabled = false
		game.Lighting.Ambient = Color3.new(0, 0, 0)
		workspace.Elevator.Lights.LightPart.Material = "SmoothPlastic"
		workspace.Elevator.Lights.Logo.Material = "SmoothPlastic"
	elseif bool == false then
		workspace.Elevator.Lights.TopLight.Light.Enabled = true	
		game.Lighting.Ambient = Color3.new(111/255, 121/255, 122/255)
		workspace.Elevator.Lights.Logo.Material = "Neon"
		workspace.Elevator.Lights.LightPart.Material = "Neon"	
	end
end

--// Makes the elevator lights flicker
_G["flicker_lights"] = function(seconds) 
	for timer = 1, seconds do 
		wait(0.05)
		workspace.Elevator.Lights.TopLight.Light.Enabled = false
		workspace.Elevator.Lights.LightPart.Material = "SmoothPlastic"
		workspace.Elevator.Lights.Logo.Material = "SmoothPlastic"
		game.Lighting.Ambient = Color3.new(0, 0, 0)
		_G.EnableSkybox(false)
		wait(math.random(1, 5) / 10)
		_G.EnableSkybox(true)
		workspace.Elevator.Lights.TopLight.Light.Enabled = true	
		workspace.Elevator.Lights.LightPart.Material = "Neon"
		workspace.Elevator.Lights.Logo.Material = "Neon"
		game.Lighting.Ambient =  Color3.new(111/255, 121/255, 122/255)
	end
	workspace.Elevator.Lights.TopLight.Light.Enabled = true
end

--// Changes the color of the elevator lights with a given color
_G["change_light_color"] = function(brickcolor) -- _G.ChangeLightColor("Medium blue")
	workspace.Elevator.Lights.Logo.BrickColor = BrickColor.new(brickcolor)
	workspace.Elevator.Lights.LightPart.BrickColor = BrickColor.new(brickcolor)
	workspace.Elevator.Lights.TopLight.Light.Color = BrickColor.new(brickcolor).Color
end

--// Plays the game music
_G["play_music"] = function(MusicId, pitch) --_G.PlayerMusic(0) plays a song with the given id
	local speaker = workspace.Elevator:FindFirstChild("Speaker")
		speaker.Speaker.Music.SoundId = MusicId
		speaker.Speaker.Music.PlaybackSpeed = pitch
		speaker.Speaker.Music:Play()
	end

--// stops the game music
_G["stop_music"] = function() --_G.StopMusic() stops the music in the elevator
	local speaker = workspace.Elevator:FindFirstChild("Speaker")
		speaker.Speaker.Music:Stop()
	end

--// This allows the skybox to be set by other functions - with a given bool where true allows the skybox to be set
_G["enable_skybox"] = function(bool)
	for i = 1, #surfaces do
		surfaces[i].SurfaceGui.Frame.Visible = not bool
		surfaces[i].Transparency = 1
	end
end

--// Changes the background color of the sky with a given color value
_G["change_background_color"] = function(color)
	for i = 1, #surfaces do
		surfaces[i].SurfaceGui.Frame.BackgroundColor3 = color
	end
end

--// Changes the color of one surface/face of the skybox to a given color value, providing a face (string)
_G["change_background_surface"] = function(surface, color)
		surface.SurfaceGui.Frame.BackgroundColor3 = color	
	end

--// Changes the transparency of the skybox - where 0 is opaque and 1 is transparent
_G["change_background_transparency"] = function(transparency)
	for i = 1, #surfaces do
		surfaces[i].SurfaceGui.Frame.BackgroundTransparency = transparency
	end
end

--// Changes the map of the game
_G["change_map"] = function(map)
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if players[i].Backpack:FindFirstChild("RemoteEvents") then
			players[i].Backpack.RemoteEvents.Map.Value = map
		end
	end
end

--// Resets the elevator and lighting back to normal - removes any gears or UI given by each disaster
_G["restore_elevator"] =  function()
	for i = 1, #surfaces do
		surfaces[i].SurfaceGui.Frame.BackgroundColor3 = Color3.new(0, 0, 0)
		surfaces[i].SurfaceGui.Frame.Visible = true
		surfaces[i].Transparency = 0
	end
	workspace.Gravity = 196.2
	_G.ToggleLights(false)
	_G.Epilepsy(false)
	game.ReplicatedStorage.ToggleAnti:FireAllClients(false)
	workspace.Elevator.Speaker.MapSound:ClearAllChildren()			
	workspace.Elevator.Notifier.Timer.SurfaceGui.Enabled = true
	workspace.Elevator.Notifier.Timer.Color = Color3.fromRGB(99,116,154)
	workspace.Elevator.Lights.TopLight.Light.Enabled = true
	workspace.Elevator.Lights.TopLight.Light.Brightness = 2
	workspace.Elevator.Lights.TopLight.Light.Color = Color3.new(168 / 255, 246 / 255, 255 / 255)
	workspace.Elevator.Lights.TopLight.Light.Range = 20
	workspace.Elevator.Speaker.Speaker.Music.PlaybackSpeed = 1
	game.Lighting.TimeOfDay = "14:00:00"
	game.Lighting.Brightness = 2
	game.Lighting.Ambient = Color3.new(111/255, 121/255, 122/255)
	game.Lighting.Brightness = 2
	game.Lighting.FogColor = Color3.new(191 / 255, 191 / 255, 191 / 255)
	game.Lighting.FogEnd = 100000
	game.Lighting.FogStart = 0
	game.Lighting:ClearAllChildren()
	for index, player in ipairs(elevator_players) do
		if not game.Players:FindFirstChild(player) then
			print(player.Name .. " removed from list!")
			table.remove(elevator_players, index)
		else
			if (player.Backpack) then
				for index, tool in ipairs(player.Backpack:GetChildren()) do
					if (tool:IsA("Tool")) and (not game.ReplicatedStorage.Items:FindFirstChild(tool.Name)) then
						tool:Destroy()
					end
				end
			end
		end
	end
end

--// Returns a list of players currently in the elevator
_G["return_players"] = function()
	return elevator_players
end

--// Adds a player into the elevator player list, after joining the elevator
_G["add_player"] = function(player)
	if (#elevator_players > 0) then
		for i = 1, #elevator_players do
			if elevator_players[i] ~= player.Name then
				print(player.Name .. " added to list!")
				table.insert(elevator_players, i + 1, player.Name)
				break
			else
				print(player.Name .. " is already on the list!")
				break
			end
		end
	else
		print(player.Name .. " added to list!")
		table.insert(elevator_players, 1, player.Name)
	end
end

--// Removes the player from the elevator player list, given they have either left the game or respawned in the lobby
_G["remove_player"] = function(player)
	for i = 1, #elevator_players do
		if elevator_players[i] == player.Name then
			print(player.Name .. " removed from list!")
			table.remove(elevator_players, i)
		end
	end
end

--// Gets a random player from the elevator player list and returns it
_G["random_player"] = function() 
	local choices = {}
	for i = 1, #elevator_players do
		if (game.Players:FindFirstChild(elevator_players[i])) then
			local player = game.Players:FindFirstChild(elevator_players[i])
			if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(game.Players:FindFirstChild(elevator_players[i]).UserId, 5145473) or datastore:GetAsync("p_"..game.Players:FindFirstChild(elevator_players[i]).UserId.."_p_TC") then
				for k = 1, 3 do
					table.insert(choices, #choices + 1, elevator_players[i])
				end
			else
				table.insert(choices, #choices + 1, elevator_players[i])
			end 
		end
	end
	return choices[math.random(1, #choices)]
end

--// Adds an NPC to the elevator NPC list
_G["add_npc"] = function(NPC) 
	if (#elevator_npcs > 0) then
		for i = 1, #elevator_npcs do
			if elevator_npcs[i] ~= NPC.Name then
				print(NPC.Name .. " added to NPC list!")
				table.insert(elevator_npcs, #elevator_npcs + 1, NPC.Name)
				return
			else
				print(NPC.Name .. " is already on the NPC list!")
				return
			end
		end
	else
		print(NPC.Name .. " added to the NPC list!")
		table.insert(elevator_npcs, #elevator_npcs + 1, NPC.Name)
	end
end

--// Removes an NPC from the elevator NPC list
_G["remove_npc"] = function(NPC) 
	for i = 1, #elevator_npcs do
		if elevator_npcs[i] == NPC.Name then
			print(NPC.Name .. " removed from list!")
			table.remove(elevator_npcs, i)
			return
		end
	end
end

--// Returns an array of NPCs currently in the elevator
_G["get_current_npcs"] = function()
	return elevator_npcs
end

--// Teleports all elevator players into the elevator
_G["teleport_players"] = function()
	for i = 1, #elevator_players do
		local player = game.Players:FindFirstChild(elevator_players[i])
		if player then
			if player.Character.Humanoid.Sit == true then
				player.Character.Humanoid.Jump = true
				player.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.Elevator.ElevatorTeleport.Position)
				player.Character.HumanoidRootPart.Orientation = Vector3.new(0,-180,0)
				else
				player.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.Elevator.ElevatorTeleport.Position)
				player.Character.HumanoidRootPart.Orientation = Vector3.new(0,-180,0)
			end
		end
	end
end

--// Teleports all elevator players to a given position (Vector3 value)
_G["teleport_players_to_position"] = function(position)
	for i = 1, #elevator_players do
		local player = game.Players:FindFirstChild(elevator_players[i])
		if (player) then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
		end
	end
end

--// Teleports NPCs into the elevator 
_G["teleport_npcs"] = function()
	local positions = workspace.Elevator.NPCPositions:GetChildren()
	for index, object_value in ipairs(workspace.Elevator.NPCPositions:GetChildren()) do
		if object_value.Taken.Value == true then
			local NPC = object_value.Taken.Value	
			NPC.HumanoidRootPart.CFrame = CFrame.new(object_value.Position + Vector3.new(0,3,0))
		end
	end
end

--// Teleports a given NPC to a given position
_G["teleport_npcs_to_position"] = function(NPC, position)
	NPC.HumanoidRootPart.CFrame = CFrame.new(position)
end

script.LoadedGlobals.Value = true