--[[
  РАДУЖНОЕ МЕНЮ "НИКИТА ЛОХ"
  Функции: Aimbot, Fly, Noclip
  Нажмите [X] для открытия/закрытия меню
  На мобильных: нажмите на иконку "М" в левом верхнем углу
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- GUI
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NikitaLohGui"
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Мобильная кнопка
local mobileButton = Instance.new("TextButton")
mobileButton.Size = UDim2.new(0, 50, 0, 50)
mobileButton.Position = UDim2.new(0, 10, 0, 10)
mobileButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
mobileButton.Text = "М"
mobileButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mobileButton.TextScaled = true
mobileButton.Font = Enum.Font.Bold
mobileButton.Parent = screenGui

mobileButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
titleLabel.BackgroundTransparency = 0.5
titleLabel.Text = "НИКИТА ЛОХ"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.Bold
titleLabel.Parent = mainFrame

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.2, 0, 0, 30)
closeBtn.Position = UDim2.new(0.8, -10, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- ============================================
-- РАДУГА
-- ============================================
RunService.Heartbeat:Connect(function()
    local hue = tick() % 2 / 2
    local color = Color3.fromHSV(hue, 1, 1)
    titleLabel.TextColor3 = color
    mainFrame.BorderColor3 = color
    mobileButton.BackgroundColor3 = color
end)

-- ============================================
-- КНОПКИ МЕНЮ
-- ============================================
local toggles = {
    Aimbot = false,
    Fly = false,
    Noclip = false
}

local buttons = {
    {Name = "Aimbot", Y = 60},
    {Name = "Fly", Y = 110},
    {Name = "Noclip", Y = 160}
}

local buttonRefs = {}

for _, btn in ipairs(buttons) do
    local button = Instance.new("TextButton")
    button.Name = btn.Name
    button.Size = UDim2.new(0.8, 0, 0, 40)
    button.Position = UDim2.new(0.1, 0, 0, btn.Y)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = btn.Name .. " [OFF]"
    button.TextScaled = true
    button.Font = Enum.Font.SourceSansBold
    button.Parent = mainFrame
    buttonRefs[btn.Name] = button
    
    button.MouseEnter:Connect(function()
        local hue = tick() % 2 / 2
        button.BackgroundColor3 = Color3.fromHSV(hue, 0.8, 0.8)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)
    
    button.MouseButton1Click:Connect(function()
        toggles[btn.Name] = not toggles[btn.Name]
        button.Text = btn.Name .. (toggles[btn.Name] and " [ON]" or " [OFF]")
        button.TextColor3 = toggles[btn.Name] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
        
        if btn.Name == "Fly" then
            toggleFly()
        elseif btn.Name == "Noclip" then
            toggleNoclip()
        end
    end)
end

-- ============================================
-- ОТКРЫТИЕ ПО X
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        mainFrame.Visible = not mainFrame.Visible
    end
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
    
    local camera = workspace.CurrentCamera
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
        if vel.Magnitude > 0 then
            flyVelocity.Velocity = vel.Unit * 50
        else
            flyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
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
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyVelocity.Parent = root
        
        flyGyro = Instance.new("BodyGyro")
        flyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)
        flyGyro.Parent = root
        
        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.Heartbeat:Connect(updateFly)
        
        -- Сброс клавиш при переключении
        for k in pairs(flyKeys) do flyKeys[k] = false end
    else
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
        if flyGyro then flyGyro:Destroy() flyGyro = nil end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

-- Клавиши для Fly
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
print("  ✦ МЕНЮ НИКИТА ЛОХ ЗАГРУЖЕНО ✦")
print("  Нажми X для открытия меню (ПК)")
print("  Нажми кнопку 'М' (телефон)")
print("═══════════════════════════════════════")
