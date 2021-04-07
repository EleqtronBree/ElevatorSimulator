--[[
Author(s): Electra Bree

This script maanges virtual currency transactions made in-game
]]--

local DataStore = game:GetService("DataStoreService"):GetDataStore("PurchaseHistory")

game:GetService("MarketplaceService").ProcessReceipt = function(ReceiptInfo)
	for _,Player in ipairs(game.Players:GetChildren()) do
		if Player.UserId == ReceiptInfo.PlayerId then
				local player = game.Players:GetPlayerByUserId(ReceiptInfo.PlayerId)
			local PlayerProductKey = "p_" .. ReceiptInfo.PlayerId .. "_p_"
			if ReceiptInfo.ProductId == 602107958 then -- Fusion Coil
				local data = DataStore:SetAsync(PlayerProductKey.."FC",true) print(data)
				player.PlayerGui.ShopUI.Gamepasses['FusionCoil'].ImageTransparency = 0.5
				player.PlayerGui.ShopUI.Gamepasses['FusionCoil'].TextLabel.Text = 'OWNED'
				game.ServerStorage.SpecialGear.FusionCoil:Clone().Parent = player.Backpack
			elseif ReceiptInfo.ProductId == 602107261 then -- Segway
				DataStore:SetAsync(PlayerProductKey.."S", true)
				player.PlayerGui.ShopUI.Gamepasses['Segway'].ImageTransparency = 0.5
				player.PlayerGui.ShopUI.Gamepasses['Segway'].TextLabel.Text = 'OWNED'
				game.ServerStorage.SpecialGear.Segway:Clone().Parent = player.Backpack
			elseif ReceiptInfo.ProductId == 602108710 then -- Triple Chance
				DataStore:SetAsync(PlayerProductKey.."TC", true)
				player.PlayerGui.ShopUI.Gamepasses['TripleChance'].ImageTransparency = 0.5
				player.PlayerGui.ShopUI.Gamepasses['TripleChance'].TextLabel.Text = 'OWNED'
			elseif ReceiptInfo.ProductId == 602109879 then -- Triple Axelites
				DataStore:SetAsync(PlayerProductKey.."TA", true)
				player.PlayerGui.ShopUI.Gamepasses['TripleAxelites'].ImageTransparency = 0.5
				player.PlayerGui.ShopUI.Gamepasses['TripleAxelites'].TextLabel.Text = 'OWNED'
			elseif ReceiptInfo.ProductId == 602036979 then -- Choose Gear
				player.PlayerGui.ShopUI.Menu.Visible = false
				player.PlayerGui.ShopUI.ChooseGear.Visible = true
			elseif ReceiptInfo.ProductId == 602241288 then -- Song Request
				player.PlayerGui.RequestGui.TextButton.Visible = false
				player.PlayerGui.RequestGui.Frame.Visible = true
			elseif ReceiptInfo.ProductId ==  607458224 then -- Donation
				-- Award perks if not exist already
			elseif ReceiptInfo.ProductId == 606371649 then -- Candle Donation
				if player.StarterGear:FindFirstChild('Candle') == nil then
					game.ServerStorage['Gear'].Candle:Clone().Parent = player.Backpack
					game.ServerStorage['Gear'].Candle:Clone().Parent = player.StarterGear
				end
			end
		end
	end
return 
	Enum.ProductPurchaseDecision.PurchaseGranted		
end
