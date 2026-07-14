--[[
  SergeiXuesos MENU
  Функции: Aimbot, Fly, Noclip
  Открытие: X, M, Insert
  Меню по центру экрана
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================
-- GUI (ПО ЦЕНТРУ)
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SergeiXuesosGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 440)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -220)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 100)
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 20, 50)
titleLabel.BackgroundTransparency = 0.5
titleLabel.Text = "✦ SERGEI XUESOS ✦"
titleLabel.TextColor3 = Color3.fromRGB(255, 100, 200)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.15, 0, 0, 30)
closeBtn.Position = UDim2.new(0.85, -5, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- ============================================
-- РАДУГА (НЕОН)
-- ============================================
RunService.Heartbeat:Connect(function()
    local hue = tick() % 2 / 2
    local color = Color3.fromHSV(hue, 1, 1)
    titleLabel.TextColor3 = color
    mainFrame.BorderColor3 = color
end)

-- ============================================
-- КНОПКИ МЕНЮ
-- ============================================
local toggles = {
    Aimbot = false,
    Fly = false,
    Noclip = false
}

local buttonRefs = {}

local function createButton(name, y)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Position = UDim2.new(0.1, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 30, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name .. " [OFF]"
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = mainFrame
    buttonRefs[name] = btn
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(60, 40, 70)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 30, 50)
    end)
    
    btn.MouseButton1Click:Connect(function()
        toggles[name] = not toggles[name]
        btn.Text = name .. (toggles[name] and " [ON]" or " [OFF]")
        btn.TextColor3 = toggles[name] and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 255, 255)
        
        if name == "Fly" then
            toggleFly()
        elseif name == "Noclip" then
            toggleNoclip()
        end
    end)
end

createButton("Aimbot", 65)
createButton("Fly", 115)
createButton("Noclip", 165)

-- ============================================
-- ОТКРЫТИЕ ПО X, M, Insert
-- ============================================
local function toggleMenu()
    mainFrame.Visible = not mainFrame.Visible
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then toggleMenu()
    elseif input.KeyCode == Enum.KeyCode.M then toggleMenu()
    elseif input.KeyCode == Enum.KeyCode.Insert then toggleMenu() end
end)

-- ============================================
-- AIMBOT
-- ============================================
local function getNearestPlayer()
    if not LocalPlayer or not LocalPlayer.Character then return nil end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local nearest = nil
    local minDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local dist = (root.Position - targetRoot.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = player
            end
        end
    end
    return nearest
end

RunService.RenderStepped:Connect(function()
    if toggles.Aimbot then
        local target = getNearestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local targetRoot = target.Character.HumanoidRootPart
                local direction = (targetRoot.Position - root.Position).Unit
                root.CFrame = CFrame.new(root.Position, root.Position + direction * 10)
            end
        end
    end
end)

-- ============================================
-- FLY (ИСПРАВЛЕННАЯ)
-- ============================================
local flyVelocity = nil
local flyGyro = nil
local flyConnection = nil
local flyKeys = {W=false, A=false, S=false, D=false, Space=false, Shift=false}

local function updateFly()
    if not toggles.Fly then return end
    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local camera = Camera
    if not camera then return end
    
    local forward = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local up = Vector3.new(0, 1, 0)
    
    local vel = Vector3.new(0, 0, 0)
    if flyKeys.W then vel = vel + forward end
    if flyKeys.S then vel = vel - forward end
    if flyKeys.A then vel = vel - right end
    if flyKeys.D then vel = vel + right end
    if flyKeys.Space then vel = vel + up end
    if flyKeys.Shift then vel = vel - up end
    
    if flyVelocity then
        flyVelocity.Velocity = vel.Magnitude > 0 and vel.Unit * 50 or Vector3.new(0, 0, 0)
    end
    
    if flyGyro then
        flyGyro.CFrame = CFrame.new(root.Position, root.Position + forward)
    end
end

local function toggleFly()
    local character = LocalPlayer.Character
    if not character then return end
    
    if toggles.Fly then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then humanoid.PlatformStand = true end
        
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
        flyVelocity.Parent = root
        
        flyGyro = Instance.new("BodyGyro")
        flyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)
        flyGyro.Parent = root
        
        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.Heartbeat:Connect(updateFly)
        
        for k in pairs(flyKeys) do flyKeys[k] = false end
    else
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
        if flyGyro then flyGyro:Destroy() flyGyro = nil end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not toggles.Fly then return end
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true end
    if input.KeyCode == Enum.KeyCode.A then flyKeys.A = true end
    if input.KeyCode == Enum.KeyCode.S then flyKeys.S = true end
    if input.KeyCode == Enum.KeyCode.D then flyKeys.D = true end
    if input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = true end
    if input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = true end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if not toggles.Fly then return end
    if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false end
    if input.KeyCode == Enum.KeyCode.A then flyKeys.A = false end
    if input.KeyCode == Enum.KeyCode.S then flyKeys.S = false end
    if input.KeyCode == Enum.KeyCode.D then flyKeys.D = false end
    if input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = false end
    if input.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = false end
end)

-- ============================================
-- NOCLIP (ИСПРАВЛЕННАЯ)
-- ============================================
local noclipConnection = nil

local function toggleNoclip()
    local character = LocalPlayer.Character
    if not character then return end
    
    if toggles.Noclip then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if not toggles.Noclip then return end
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ============================================
-- СБРОС ПРИ ПЕРЕРОЖДЕНИИ
-- ============================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if toggles.Fly then
        toggles.Fly = false
        if buttonRefs.Fly then
            buttonRefs.Fly.Text = "Fly [OFF]"
            buttonRefs.Fly.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        toggleFly()
    end
    if toggles.Noclip then
        toggles.Noclip = false
        if buttonRefs.Noclip then
            buttonRefs.Noclip.Text = "Noclip [OFF]"
            buttonRefs.Noclip.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        toggleNoclip()
    end
end)

print("═══════════════════════════════════════")
print("  ✦ SERGEI XUESOS MENU ✦")
print("  Открытие: X, M, Insert")
print("  Меню по центру экрана")
print("═══════════════════════════════════════")
