repeat task.wait() until game:IsLoaded()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Load Wind UI
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not success then
    warn("Failed to load WindUI: " .. tostring(WindUI))
    return
end

-- Variables
local autoCast = false
local autoCatch = false
local autoTarget = false
local autoSell = false
local autoZone = false
local castMode = "bypass"
local sellAmount = 50
local freezeChar = false
local selectedZone = CFrame.new(942.536377, 127.545708, 254.444763)

-- Auto loops
task.spawn(function()
    while true do
        if autoCast and Lives() and not LocalPlayer.fishing.general.activeFishing.Value then
            EquipRod()
            local oldValue = LocalPlayer.gui.autofishing.Value
            LocalPlayer.gui.autofishing.Value = true
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
            repeat task.wait() until LocalPlayer.fishing.general.activeFishing.Value
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
            LocalPlayer.gui.autofishing.Value = oldValue
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if autoCatch and LocalPlayer.fishing.general.activeFighting.Value then
            ReplicatedStorage.events.fishing.fightClick:FireServer()
        end
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if autoTarget then
            local targetFrame = LocalPlayer.PlayerGui.fishing.targetFrame
            for _, target in ipairs(targetFrame:GetChildren()) do
                if target:IsA("GuiObject") and target.Name == 'target' and target:FindFirstChild('ImageButton') then
                    game:GetService('GuiService').SelectedObject = target.ImageButton
                    task.wait()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    task.wait()
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                end
                task.wait(0.08)
            end
        end
        task.wait()
    end
end)

-- Functions
local function Lives()
    return LocalPlayer.Character and 
           LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
           LocalPlayer.Character:FindFirstChild("Humanoid") and 
           LocalPlayer.Character.Humanoid.Health >= 1
end

local function EquipRod()
    if Lives() then
        local rodName = LocalPlayer.inventory.rodsEquippedName.Value
        if not LocalPlayer.Character:FindFirstChild(rodName) then
            if LocalPlayer.Backpack:FindFirstChild(rodName) then
                LocalPlayer.Backpack:FindFirstChild(rodName).Parent = LocalPlayer.Character
            end
        end
    end
end

local function SafeZone(pos)
    if workspace:FindFirstChild('aetherhub-safezone') then
        workspace:FindFirstChild('aetherhub-safezone').CFrame = pos
    else
        local part = Instance.new('Part', workspace)
        part.Name = 'aetherhub-safezone'
        part.CFrame = pos
        part.Size = Vector3.new(10, 2, 10)
        part.Transparency = 0.8
        part.Anchored = true
    end
end

local isSelling = false
local function SellAll()
    if not isSelling and Lives() then
        local fishCount = 0
        for _, fish in pairs(LocalPlayer.inventory.fishes:GetChildren()) do
            fishCount = fishCount + 1
        end
        
        if fishCount >= sellAmount then
            isSelling = true
            local originalPos = LocalPlayer.Character.HumanoidRootPart.CFrame
            
            -- Teleport to shop
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(815.194214, 125.560997, -250.464111)
            task.wait(2)
            
            -- Sell all fish
            for _, fish in pairs(LocalPlayer.inventory.fishes:GetChildren()) do
                local args = {[1] = fish.Name, [2] = fish:GetAttribute('itemId')}
                ReplicatedStorage.events.fishing.itemSell:InvokeServer(unpack(args))
            end
            
            task.wait(2)
            LocalPlayer.Character.HumanoidRootPart.CFrame = originalPos
            isSelling = false
        end
    end
end

local TweenService = game:GetService("TweenService")

local function FlyTo(targetCFrame)
    if not Lives() then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local currentPos = hrp.Position
    local targetPos = targetCFrame.Position

    -- Check if already at the target position (within 5 units)
    if (currentPos - targetPos).Magnitude < 5 then
        return -- Already at position, stop flying
    end

    hrp.Anchored = false

    -- Phase 1: Go up vertically 50 units to avoid obstacles
    local upPos = Vector3.new(currentPos.X, currentPos.Y + 50, currentPos.Z)
    local tweenInfo1 = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
    local tween1 = TweenService:Create(hrp, tweenInfo1, {CFrame = CFrame.new(upPos)})
    tween1:Play()
    tween1.Completed:Wait()

    -- Phase 2: Move horizontally to target X,Z at moderate speed
    local horizontalPos = Vector3.new(targetPos.X, upPos.Y, targetPos.Z)
    local distance2 = (horizontalPos - upPos).Magnitude
    local speed2 = 200
    local time2 = distance2 / speed2
    local tweenInfo2 = TweenInfo.new(time2, Enum.EasingStyle.Linear)
    local tween2 = TweenService:Create(hrp, tweenInfo2, {CFrame = CFrame.new(horizontalPos)})
    tween2:Play()
    tween2.Completed:Wait()

    -- Phase 3: Descend vertically to target Y
    local finalPos = Vector3.new(targetPos.X, targetPos.Y, targetPos.Z)
    local tweenInfo3 = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
    local tween3 = TweenService:Create(hrp, tweenInfo3, {CFrame = CFrame.new(finalPos)})
    tween3:Play()
    tween3.Completed:Wait()

    -- Set final CFrame with rotation
    hrp.CFrame = targetCFrame
end

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "Aether Hub | Go Fishing 🎃",
    Icon = "rocket",
    Author = "Made By ge8266",
    Folder = "AetherHub/GoFish",
    Size = UDim2.fromOffset(480, 360),
    Transparent = false,
    Theme = "Dark",
    SideBarWidth = 170,
    OpenButton = {
        Title = "Open Aether Hub UI",
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Color = ColorSequence.new(
            Color3.fromHex("fdd700"),
            Color3.fromHex("e7ff2f")
        )
    }
})

do
    Window:Tag({
        Title = "RANK: PELER",
        Icon = "crown",
        Color = Color3.fromHex("#f7b605")
    })
end

-- Tabs
local Farm = Window:Tab({ Title = "Auto Farm", Icon = "fish" })
local other = Window:Tab({ Title = "Ga Tau", Icon = "captions" })
local Misc = Window:Tab({ Title = "Misc", Icon = "settings" })

-- Farm Tab
Farm:Section({ Title = "Auto Fishing" })

Farm:Toggle({
    Title = "Auto Cast",
    Default = false,
    Callback = function(v)
        autoCast = v
        task.spawn(function()
            while autoCast and task.wait(1) do
                if Lives() and not LocalPlayer.fishing.general.activeFishing.Value then
                    EquipRod()
                    local oldValue = LocalPlayer.gui.autofishing.Value
                    LocalPlayer.gui.autofishing.Value = true
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
                    repeat task.wait() until LocalPlayer.fishing.general.activeFishing.Value
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
                    LocalPlayer.gui.autofishing.Value = oldValue
                end
            end
        end)
        WindUI:Notify(v and "Auto Cast Enabled!" or "Auto Cast Disabled!", 3)
    end
})

Farm:Toggle({
    Title = "Auto Catch",
    Default = false,
    Callback = function(v)
        autoCatch = v
        task.spawn(function()
            while autoCatch and task.wait() do
                if LocalPlayer.fishing.general.activeFighting.Value then
                    ReplicatedStorage.events.fishing.fightClick:FireServer()
                end
            end
        end)
        WindUI:Notify(v and "Auto Catch Enabled!" or "Auto Catch Disabled!", 3)
    end
})

Farm:Toggle({
    Title = "Auto Target",
    Default = false,
    Callback = function(v)
        autoTarget = v
        task.spawn(function()
            while autoTarget and task.wait() do
                local targetFrame = LocalPlayer.PlayerGui.fishing.targetFrame
                for _, target in ipairs(targetFrame:GetChildren()) do
                    if target:IsA("GuiObject") and target.Name == 'target' and target:FindFirstChild('ImageButton') then
                        game:GetService('GuiService').SelectedObject = target.ImageButton
                        task.wait()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        task.wait()
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    end
                    task.wait(0.08)
                end
            end
        end)
        WindUI:Notify(v and "Auto Target Enabled!" or "Auto Target Disabled!", 3)
    end
})

Farm:Section({ Title = "Paket Halloween" })

Farm:Toggle({
    Title = "Paket Halloween (Halloween Only)",
    Desc = "Pake pake aja lah kontol.",
    Default = false,
    Callback = function(v)
        if v and Lives() then
            -- Fly to specified position
            FlyTo(CFrame.new(Vector3.new(1114, 126, 748)) * CFrame.Angles(0, math.rad(180), 0))
            -- Enable auto features
            autoCast = true
            autoCatch = true
            autoTarget = true
            -- Start auto cast loop
            task.spawn(function()
                while autoCast and task.wait(1) do
                    if Lives() and not LocalPlayer.fishing.general.activeFishing.Value then
                        EquipRod()
                        local oldValue = LocalPlayer.gui.autofishing.Value
                        LocalPlayer.gui.autofishing.Value = true
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
                        repeat task.wait() until LocalPlayer.fishing.general.activeFishing.Value
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
                        LocalPlayer.gui.autofishing.Value = oldValue
                    end
                end
            end)
            -- Start auto catch loop
            task.spawn(function()
                while autoCatch and task.wait() do
                    if LocalPlayer.fishing.general.activeFighting.Value then
                        ReplicatedStorage.events.fishing.fightClick:FireServer()
                    end
                end
            end)
            -- Start auto target loop
            task.spawn(function()
                while autoTarget and task.wait() do
                    local targetFrame = LocalPlayer.PlayerGui.fishing.targetFrame
                    for _, target in ipairs(targetFrame:GetChildren()) do
                        if target:IsA("GuiObject") and target.Name == 'target' and target:FindFirstChild('ImageButton') then
                            game:GetService('GuiService').SelectedObject = target.ImageButton
                            task.wait()
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            task.wait()
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        end
                        task.wait(0.08)
                    end
                end
            end)
            -- Freeze character
            freezeChar = true
            LocalPlayer.Character.HumanoidRootPart.Anchored = true
            WindUI:Notify("Paket Halloween Activated! Teleported, autos enabled, and frozen.", 3)
        else
            -- Disable when toggled off
            autoCast = false
            autoCatch = false
            autoTarget = false
            freezeChar = false
            if Lives() then
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
            end
            WindUI:Notify("Paket Halloween Deactivated!", 3)
        end
    end
})

Farm:Button({
    Title = "Infinite Money",
    Locked = true,
    Callback = function()
        if LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Money") then
            LocalPlayer.leaderstats.Money.Value = 999999999
            WindUI:Notify("Infinite Money Set!", 3)
        else
            WindUI:Notify("Money stat not found!", 3)
        end
    end
})

-- Ga Tau

other:Button({
    Title = "Redeem All Codes",
    Callback = function()
        local codes = 0
        for _, code in pairs(LocalPlayer.rewards.codes:GetChildren()) do
            if not code.Value then
                ReplicatedStorage.events.gui.canRedeemCode:InvokeServer(code.Name)
                codes = codes + 1
            end
        end
        WindUI:Notify("Redeemed " .. codes .. " codes!", 3)
    end
})

-- Misc Tab
Misc:Section({ Title = "Information" })

Misc:Button({
    Title = "Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/D679qytx")
        WindUI:Notify("Discord link copied!", 3)
    end
})

Misc:Paragraph({
    Title = "Aether Hub | Go Fish 🐟",
    Content = "Version: 1.0.0\n\nFeatures:\n• Auto Cast & Catch\n• Auto Target\n• Auto Sell\n• Zone Teleporter\n• Auto Buy Items\n• Code Redeemer\n\nDiscord: discord.gg/G4AuBncANE"
})

-- Initial Notification
task.wait(1)
WindUI:Notify("Aether Hub | Go Fish loaded! 🐟", 5)
print("✅ Aeter Hub | Go Fish loaded successfully!")
