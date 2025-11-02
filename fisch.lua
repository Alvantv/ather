local CollectionService = game:GetService("CollectionService")
local Remote = game:GetService("ReplicatedStorage").packages.Net["RE/SpearFishing/Minigame"]
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2585, 144, -1942)
while task.wait() do
	local fishList = {}
	for i, v in next, CollectionService:GetTagged("SpearfishingZone") do
		local Zone = v.ZoneFish
		for _, Fish in next, Zone:GetChildren() do
			table.insert(fishList, Fish)
		end
	end
	for _, Fish in next, fishList do
		task.spawn(function()
			for i = 1, 10 do
				Remote:FireServer(Fish:GetAttribute("UID"))
				Remote:FireServer(Fish:GetAttribute("UID"), true)
			end
		end)
	end
end
