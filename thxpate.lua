-- Made and Open Source by zBeyond
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/UI-Interface/CustomFIeld/main/RayField.lua'))()

-- Custom loading screen
local function showCustomLoadingScreen()
    local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
    ScreenGui.Name = "CustomLoadingScreen"

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(0.8, 0, 0.2, 0)
    Title.Position = UDim2.new(0.1, 0, 0.3, 0)
    Title.Text = "[--Bey Hub--]"
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 60 -- Larger title
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.BackgroundTransparency = 1

    local Subtitle = Instance.new("TextLabel", Frame)
    Subtitle.Size = UDim2.new(0.8, 0, 0.1, 0)
    Subtitle.Position = UDim2.new(0.1, 0, 0.5, 0)
    Subtitle.Text = "⚔️ A New Experience in Pixel Slayer ⚔️"
    Subtitle.Font = Enum.Font.GothamBold
    Subtitle.TextSize = 40 -- Larger subtitle
    Subtitle.TextColor3 = Color3.new(1, 1, 1)
    Subtitle.BackgroundTransparency = 1

    wait(3) -- Wait for a few seconds before removing the loading screen
    ScreenGui:Destroy()
end

-- Show custom loading screen before proceeding
showCustomLoadingScreen()

-- General settings
local AutoFarmEnabled = false
local AutoStatsEnabled = false
local AutoRebirthEnabled = false
local KillAuraEnabled = false
local HEIGHT_OFFSET = 15
local SelectedStat = "Power"
local Hotkey = Enum.KeyCode.K -- Default "K" key
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotePath = ReplicatedStorage:WaitForChild("Universe"):WaitForChild("Network"):WaitForChild("Remotes")

local DAMAGE_AMOUNT = 50
local KILL_AURA_RANGE = 100 -- Kill Aura range
local AUTO_FARM_RANGE = 100 -- Auto Farm range
local MAX_MOBS_TO_DAMAGE = 13 -- Max mobs to attack simultaneously

-- Function to apply damage to all nearby mobs
local function multiDamageAllMobs()
    local mobsFolder = game.Workspace:WaitForChild("World"):WaitForChild("Mobs")
    local mobCount = 0

    for _, mob in pairs(mobsFolder:GetChildren()) do
        if mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            mobCount = mobCount + 1
            if mobCount > MAX_MOBS_TO_DAMAGE then break end

            local args = {
                [1] = mob,
                [2] = DAMAGE_AMOUNT
            }
            for i = 1, 3 do
                RemotePath.DamageFire:FireServer(unpack(args))
            end
        end
    end
end

-- Function to check if mob is alive
local function isMobAlive(mob)
    return mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0
end

-- Function to select stat
local function selectStat(stat)
    SelectedStat = stat
end

-- Function to enable AutoStats
local function runAutoStats()
    spawn(function()
        while AutoStatsEnabled do
            local args = {}

            if SelectedStat == "Power" then
                args = { [1] = 1, [2] = 0, [3] = 0 }
            elseif SelectedStat == "Health" then
                args = { [1] = 0, [2] = 1, [3] = 0 }
            elseif SelectedStat == "Critical" then
                args = { [1] = 0, [2] = 0, [3] = 1 }
            end

            local upgradeStat = RemotePath:FindFirstChild("UpgradeStat")
            if upgradeStat then
                upgradeStat:FireServer(unpack(args))
            end

            wait(0.1) -- Adjusted interval
        end
    end)
end

-- Function to enable AutoRebirth
local function runAutoRebirth()
    spawn(function()
        while AutoRebirthEnabled do
            local rebirthRemote = RemotePath:FindFirstChild("Rebirth")
            if rebirthRemote then
                rebirthRemote:FireServer()
            end
            wait(0.1)
        end
    end)
end

-- Function to enable AutoFarm
local function AutoFarm()
    spawn(function()
        while AutoFarmEnabled do
            local character = game.Players.LocalPlayer.Character
            if not character then continue end

            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then continue end

            local mobsFolder = game.Workspace:WaitForChild("World"):WaitForChild("Mobs")
            local mobFound = false

            for _, mob in pairs(mobsFolder:GetChildren()) do
                if mob and mob:FindFirstChild("HumanoidRootPart") and isMobAlive(mob) then
                    local distance = (mob.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude

                    if distance <= AUTO_FARM_RANGE then
                        mobFound = true

                        local targetCFrame = CFrame.new(
                            mob.HumanoidRootPart.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
                        )

                        local tween = TweenService:Create(
                            humanoidRootPart,
                            TweenInfo.new(0.1, Enum.EasingStyle.Linear),
                            {CFrame = targetCFrame}
                        )

                        tween:Play()
                        tween.Completed:Wait()

                        humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

                        multiDamageAllMobs()
                        break
                    end
                end
            end

            if not mobFound then
                wait(5) -- Adjusted interval
            else
                wait(0.1)
            end
        end
    end)
end

-- Function to enable Kill Aura
local function runKillAura()
    spawn(function()
        while KillAuraEnabled do
            local character = game.Players.LocalPlayer.Character
            if not character then continue end

            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then continue end

            local mobsFolder = game.Workspace:WaitForChild("World"):WaitForChild("Mobs")

            for _, mob in pairs(mobsFolder:GetChildren()) do
                if mob and mob:FindFirstChild("Humanoid") and isMobAlive(mob) then
                    local distance = (mob.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude

                    if distance <= KILL_AURA_RANGE then
                        local args = {
                            [1] = mob,
                            [2] = DAMAGE_AMOUNT
                        }

                        local damageRemote = RemotePath:FindFirstChild("DamageFire")
                        if damageRemote then
                            damageRemote:FireServer(unpack(args))
                        else
                            warn("Remote 'DamageFire' not found!")
                        end
                    end
                end
            end
            wait(0.1) -- Adjusted interval
        end
    end)
end

-- Rayfield Interface
local Window = Rayfield:CreateWindow({
    Name = "Bey Hub - Pixel Slayer ⚔️",
    LoadingTitle = "[--Bey Hub--]",
    LoadingSubtitle = "⚔️ A New Experience in Pixel Slayer ⚔️",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "FarmConfig",
        FileName = "Config"
    }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362459) -- New settings tab

-- Slider for height adjustment
MainTab:CreateSlider({
    Name = "Height Offset ",
    Range = {5, 30},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 15,
    Flag = "HeightOffset",
    Callback = function(Value)
        HEIGHT_OFFSET = Value
    end,
    ShowValue = false
})

-- AutoFarm Toggle with Emoji
MainTab:CreateToggle({
    Name = "Auto Farm ",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        AutoFarmEnabled = Value
        if Value then
            AutoFarm()
        end
    end
})

-- Kill Aura Toggle with Emoji
MainTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Flag = "KillAuraToggle",
    Callback = function(Value)
        KillAuraEnabled = Value
        if Value then
            runKillAura()
        end
    end
})

-- AutoStats Toggle with Emoji
MainTab:CreateToggle({
    Name = "Auto Stats (Only Power) ⚡",
    CurrentValue = false,
    Flag = "AutoStatsToggle",
    Callback = function(Value)
        AutoStatsEnabled = Value
        if Value then
            runAutoStats()
        end
    end
})

-- AutoRebirth Toggle with Emoji
MainTab:CreateToggle({
    Name = "Auto Rebirth ♻️",
    CurrentValue = false,
    Flag = "AutoRebirthToggle",
    Callback = function(Value)
        AutoRebirthEnabled = Value
        if Value then
            runAutoRebirth()
        end
    end
})

-- Hotkey selection in settings tab
SettingsTab:CreateDropdown({
    Name = "Select Hotkey for Menu 🧑‍💻",
    Options = {"K", "L", "M", "N", "O"},
    CurrentOption = "K", -- Default key
    Flag = "HotkeySelection",
    Callback = function(Option)
        Hotkey = Enum.KeyCode[Option]
    end
})

-- Show a notification for credits and thanks
Rayfield:Notify({
    Title = "Thank You for Playing!",
    Content = "This script was made by zBeyond. Enjoy the game and have fun!",
    Duration = 7
})
Rayfield:Notify({
    Title = "Special Thanks for Pateuing",
    Content = "Thx Pateuing and his Trashub",
    Duration = 7
})
