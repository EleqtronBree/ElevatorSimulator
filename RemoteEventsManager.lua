--[[
Author(s): Electra Bree & Aaron Spivey

Manages execution of a number of server-sided events that are called by clients
]]--

--// Variables
testers_module = require(game.ReplicatedStorage:WaitForChild("Testers"))
dev_module = require(game.ReplicatedStorage:WaitForChild("Devs"))
staff_module = require(game.ReplicatedStorage:WaitForChild("Staff"))

--// Creating remove events
random_gear = Instance.new("RemoteEvent", game.ReplicatedStorage)
random_gear.Name = 'RandomGearPaid'
gameboy_gear = Instance.new("RemoteEvent", game.ReplicatedStorage)
gameboy_gear.Name = 'GameboyGearPaid'
choose_gear = Instance.new("RemoteEvent", game.ReplicatedStorage)
choose_gear.Name = 'ChooseGearPaid'
buy_song = Instance.new("RemoteEvent", game.ReplicatedStorage)
buy_song.Name = 'BuyCustomSong'
song_paid = Instance.new("RemoteEvent", game.ReplicatedStorage)
song_paid.Name = 'CustomSongPaid'

--// Checks if a given player is a game developer of Elevator Simulator
function check_if_developers(player)
	for index, developer in ipairs(dev_module) do
		if developer == player then
			return true
		end
	end
	return false
end

--// Checks if a given player is a staff/admin of Elevator Simulator
function check_staff(player)
	for i, staff in pairs(staff_module) do
		if staff == player then
			return true
		end
	end
	return false
end

--// Checks if a given player is a quality assurance tester of Elevator Simulator
function check_tester(player)
	for i, tester in pairs(testers_module) do
		if tester == player then
			return true
		end
	end
	return false
end

--// Triggered when a player completes the gear transaction - gives the gear to the given player
choose_gear.OnServerEvent:connect(function(player, gear_name)
	if gear_name == "NeonBriefcase" and check_staff(player.Name) or check_tester(player.Name) or check_if_developers(player.Name) then
		local chosen_gear = game.ServerStorage.SpecialGear[gear_name]:Clone()
		chosen_gear.Parent = workspace
		player.PlayerGui.ShopUI.ChooseGear.Visible = false
		player.PlayerGui.ShopUI.Menu.Visible = true
	elseif gear_name ~= "NeonBriefcase" then
		local chosen_gear = game.ServerStorage.SpecialGear[gear_name]:Clone()
		chosen_gear.Parent = workspace
		player.PlayerGui.ShopUI.ChooseGear.Visible = false
		player.PlayerGui.ShopUI.Menu.Visible = true
	end
end)

-- Triggered when the client purchases a song - commences purchase
buy_song.OnServerEvent:connect(function(player)
	game:GetService("MarketplaceService"):PromptProductPurchase(player, 602241288)
end)

--// Triggered when the song transaction is completed - adds the song to the queue and notifies the player
song_paid.OnServerEvent:connect(function(player, song_id)
	_G.AddSong(song_id)
	player.PlayerGui.RequestGui.TextButton.Visible = true
	player.PlayerGui.RequestGui.Frame.Visible = false
end)



