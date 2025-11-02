local CollectionService = game:GetService("CollectionService")
local Remote = game:GetService("ReplicatedStorage").packages.Net["RE/SpearFishing/Minigame"]
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2585, 144, -1942)
while task.wait(0.1) do -- Reduced frequency to every 0.1 seconds instead of every frame
	local fishList = {}
	for i, v in next, CollectionService:GetTagged("SpearfishingZone") do
		local Zone = v.ZoneFish
		for _, Fish in next, Zone:GetChildren() do
			table.insert(fishList, Fish)
		end
	end
	for _, Fish in next, fishList do
		task.spawn(function()
			Remote:FireServer(Fish:GetAttribute("UID"))
			task.wait(0.05) -- Shorter wait between fires
			Remote:FireServer(Fish:GetAttribute("UID"), true)
		end)
	end
end
