--[[
Author(s): Electra Bree & Aaron Spivey

This script runs the elevator minigame
]]--

repeat 
	wait() 
until 
	game.ServerScriptService.GlobalFunctionsBrain ~= nil and game.ServerScriptService.GlobalFunctionsBrain.LoadedGlobals.Value == true

--// Variables
datastore = game:GetService("DataStoreService"):GetDataStore("PurchaseHistory")
previous_song_index = 0

--// Arrays
maps = {}
songs = game.ServerStorage.ElevatorMusic:GetChildren()
new_maps = game.ServerStorage.NewMaps:GetChildren()

--// Randomizes the maps array
function random_table()
    for index = 1, #maps do
        local random_index = math.random(index, #maps)
        maps[index], maps[random_index] = maps[random_index], maps[index]
    end
end

--// Refreshes the maps array and randomizes the order of contents
function random_maps()
	maps = {}
	for index, disaster in pairs(game.ServerStorage.Maps:GetChildren()) do
		table.insert(maps, index, disaster)
	end
	for index = 1, #maps do
        local random_index = math.random(index, #maps)
        maps[index], maps[random_index] = maps[random_index], maps[index]
    end
end

--// Chooses the next song to be played and returns the song object
function get_next_song()
	local requests = _G.return_songs()
	if #requests > 0 then
		workspace.Elevator.Speaker.Speaker.Music.SoundId = requests[1]
		workspace.Elevator.Speaker.Speaker.Music:Play()
		_G.RemoveSong()	
	elseif #requests < 1 then
		if previous_song_index ~= 0 then					--if the server didn't just start then
			local current_song_index = previous_song_index + 1			--the current music that will be playing is next after the previous music
			if songs[current_song_index] == nil then				--if there is no music on the list then
				current_song_index = 1
				previous_song_index = current_song_index
				return songs[current_song_index]					--restart the list
			else											--else if there is music still on the list then
				previous_song_index = current_song_index					--the previous music is now the current music (for next time)
				return songs[current_song_index]						--return the current music
			end				
		else											--else if the server just started then
			local current_song_index = math.random(1, #songs)	--the current music is a random song										
			previous_song_index = current_song_index		--initialize previous_music as currentMusic
			return songs[current_song_index]					--return the current music
		end	
	end
end

--// Chooses maps
random_maps()

--// Infinite loop that runs the minigame
while wait() do
	for index = 1, #maps do
		local song = get_next_song()
		wait()
		_G.play_music(song.SoundId, song.PlaybackSpeed)
		_G.timer(math.random(20,30), true)
		local map = maps[index]:Clone()
		map.Parent = workspace
		map.Main.Disabled = false
		wait()
		if map:FindFirstChild("KeepBarrier") then
			_G.enable_barrier()
		elseif not map:FindFirstChild("KeepBarrier") then
			_G.disable_barrier()
		end
		if not(map:FindFirstChild("KeepDoorClosed")) then
			_G.open_door()
		end
		_G.timer(map.FloorTime.Value, false)
		wait()
		_G.close_door()
		map:Destroy()
		_G.restore_elevator()
		for index, player in pairs(_G.return_players()) do
			if game.Players:FindFirstChild(player) then
				if player:FindFirstChild("Music") then
					player.Music.Volume = 0
					player.Music:Destroy()
				end
				if player:FindFirstChild("Stats") then
					player.Stats.Floors.Value = player.Stats.Floors.Value + 1
				end
				if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(player.userId, 6739507) or datastore:GetAsync("p_"..player.UserId.."_p_TA") == true then
					player.Stats.Axelites.Value = player.Stats.Axelites.Value + 3
				else
					player.Stats.Axelites.Value = player.Stats.Axelites.Value + 1	
				end
				if player.Character and player.Character:FindFirstChild("Humanoid") then
					player.Character.Humanoid.WalkSpeed = 16
				end
			end
		end
	end
end