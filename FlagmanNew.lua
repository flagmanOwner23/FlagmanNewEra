-- Flagman New.lua
-- Открытие по Insert
-- Версия 1.1
-- Автор: good

local Flagman = {
    Name = "Flagman New",
    Version = "1.1",
    Author = "good"
}

-- Сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Состояния
local flyEnabled = false
local noclipEnabled = false
local godEnabled = false
local spiderEnabled = false
local scaffoldEnabled = false
local speedMultiplier = 1
local jumpMultiplier = 1
local bodyVelocity = nil
local noclipPart = nil
local spiderConnection = nil
local scaffoldConnection = nil
local menuOpen = false

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlagmanMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(100, 100, 150)
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
Title.BackgroundTransparency = 1
Title.Text = "Flagman New"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local ButtonContainer = Instance.new("ScrollingFrame")
ButtonContainer.Size = UDim2.new(1, -20, 1, -60)
ButtonContainer.Position = UDim2.new(0, 10, 0, 50)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ButtonContainer.ScrollBarThickness = 6
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ButtonContainer

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(80, 80, 120)
    btn.Parent = ButtonContainer
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    end)
end

-- Функции
local function toggleFly()
    flyEnabled = not flyEnabled
    if flyEnabled then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1,1,1) * 100000
        bodyVelocity.Velocity = Vector3.new(0, 50, 0)
        bodyVelocity.Parent = RootPart
        print("[Flagman] Fly ON")
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        print("[Flagman] Fly OFF")
    end
end

local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        noclipPart = Instance.new("Part")
        noclipPart.CanCollide = false
        noclipPart.Transparency = 1
        noclipPart.Size = Vector3.new(5,5,5)
        noclipPart.Anchored = true
        noclipPart.Parent = workspace
        RunService.Heartbeat:Connect(function()
            if noclipEnabled and RootPart then
                noclipPart.Position = RootPart.Position
            endend)
        print("[Flagman] Noclip ON")
    else
        if noclipPart then noclipPart:Destroy() end
        print("[Flagman] Noclip OFF")
    end
end

local function toggleGod()
    godEnabled = not godEnabled
    if godEnabled then
        Humanoid.MaxHealth = math.huge
        Humanoid.Health = math.huge
        print("[Flagman] God ON")
    else
        Humanoid.MaxHealth = 100
        Humanoid.Health = 100
        print("[Flagman] God OFF")
    end
end

local function toggleSpider()
    spiderEnabled = not spiderEnabled
    if spiderEnabled then
        if spiderConnection then spiderConnection:Disconnect() end
        spiderConnection = RunService.Heartbeat:Connect(function()
            if spiderEnabled and RootPart and Humanoid then
                local ray = Ray.new(RootPart.Position, RootPart.CFrame.LookVector * 3)
                local hit = workspace:FindPartOnRay(ray)
                if hit then
                    Humanoid.WalkSpeed = 20
                    RootPart.Velocity = RootPart.Velocity + Vector3.new(0, -2, 0)
                    RootPart.CFrame = RootPart.CFrame + RootPart.CFrame.LookVector * 1.5
                end
            end
        end)
        print("[Flagman] Spider ON")
    else
        if spiderConnection then spiderConnection:Disconnect() end
        Humanoid.WalkSpeed = 16
        print("[Flagman] Spider OFF")
    end
end

local function toggleScaffold()
    scaffoldEnabled = not scaffoldEnabled
    if scaffoldEnabled then
        if scaffoldConnection then scaffoldConnection:Disconnect() end
        scaffoldConnection = RunService.Heartbeat:Connect(function()
            if scaffoldEnabled and RootPart then
                local pos = RootPart.Position
                local below = pos - Vector3.new(0, 2.5, 0)
                local ray = Ray.new(below, Vector3.new(0, -0.5, 0))
                local hit = workspace:FindPartOnRay(ray)
                if not hit then
                    local block = Instance.new("Part")
                    block.Size = Vector3.new(2, 0.5, 2)
                    block.Position = below + Vector3.new(0, -0.25, 0)
                    block.Anchored = true
                    block.BrickColor = BrickColor.new("Bright red")
                    block.Material = Enum.Material.SmoothPlastic
                    block.Parent = workspace
                    game:GetService("Debris"):AddItem(block, 5)
                end
            end
        end)
        print("[Flagman] Scaffold ON")
    else
        if scaffoldConnection then scaffoldConnection:Disconnect() end
        print("[Flagman] Scaffold OFF")
    end
end

local function setSpeed(value)
    speedMultiplier = value or 1
    Humanoid.WalkSpeed = 16 * speedMultiplier
    print("[Flagman] Speed: " .. Humanoid.WalkSpeed)
end

local function setJump(value)
    jumpMultiplier = value or 1
    Humanoid.JumpPower = 50 * jumpMultiplier
    print("[Flagman] Jump: " .. Humanoid.JumpPower)
end

local function clearAll()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part ~= RootPart then
            part:Destroy()
        end
    end
    print("[Flagman] Cleared")
end

local function teleportToPlayer(targetName)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower():find(targetName:lower()) then
            local targetChar = plr.Character
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                RootPart.CFrame = targetChar.HumanoidRootPart.CFrame
                print("[Flagman] TP to " .. plr.Name)
                return
            end
        end
    end
    print("[Flagman] Player not found")
end

-- Кнопки меню
createButton("Fly (F)", toggleFly)
createButton("Noclip (N)", toggleNoclip)
createButton("Godmode (G)", toggleGod)
createButton("Spider (S)", toggleSpider)
createButton("Scaffold (B)", toggleScaffold)
createButton("Speed x2", function() setSpeed(2) end)
createButton("Speed x3", function() setSpeed(3) end)
createButton("Jump x2", function() setJump(2) end)
createButton("Jump x3", function() setJump(3) end)
createButton("Clear Parts (C)", clearAll)
createButton("TP to bsjfcnjr", function() teleportToPlayer("bsjfcnjr") end)
createButton("Reset Speed", function() setSpeed(1) end)
createButton("Reset Jump", function() setJump(1) end)

-- Открытие меню по INSERT
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        menuOpen = not menuOpen
        local goal = menuOpen and 0 or 1
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundTransparency = goal
        })
        tween:Play()
        MainFrame.Visible = true
        if not menuOpen then
            wait(0.3)
            MainFrame.Visible = false
        end
    end
end)

-- Хоткеи
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFly() end
    if input.KeyCode == Enum.KeyCode.N then toggleNoclip() end
    if input.KeyCode == Enum.KeyCode.G then toggleGod() end
    if input.KeyCode == Enum.KeyCode.S then toggleSpider() end
    if input.KeyCode == Enum.KeyCode.B then toggleScaffold() end
    if input.KeyCode == Enum.KeyCode.C then clearAll() end
end)

print("=== Flagman New загружен ===")
print("Нажмите INSERT для открытия меню")
print("Хоткеи: F - Fly, N - Noclip, G - God, S - Spider, B - Scaffold, C - Clear")
