-- SergeiXuesos v2.0
-- Fly, Noclip, Spider, ESP, Binds, Поиск, Размытие
-- Автор: SergeiXuesos

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ============================================
-- СОСТОЯНИЯ
-- ============================================
local toggles = {
    Fly = false,
    Noclip = false,
    Spider = false,
    ESP = false
}

local flySpeed = 50
local flyConnection = nil
local bodyVelocity = nil
local bodyGyro = nil
local flyKeys = {W=false, A=false, S=false, D=false, Space=false, Shift=false}

local noclipConnection = nil
local noclipPart = nil

local spiderConnection = nil
local spiderActive = false

local espObjects = {}
local espConnections = {}

local binds = {}
local bindWaiting = nil

-- ============================================
-- GUI (С РАЗМЫТИЕМ)
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SergeiXuesosGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Размытие
local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting

local function applyBlur(enabled)
    TweenService:Create(Blur, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
        Size = enabled and 12 or 0
    }):Play()
end

-- Основное меню (центр)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 10, 35)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(180, 100, 255)
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Плавное открытие
local function toggleMenu()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        applyBlur(true)
        MainFrame.BackgroundTransparency = 0.15
    else
        applyBlur(false)
        MainFrame.BackgroundTransparency = 1
    end
end

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
Title.BackgroundTransparency = 0.5
Title.Text = "✦ SERGEI XUESOS ✦"
Title.TextColor3 = Color3.fromRGB(200, 150, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.15, 0, 0, 30)
CloseBtn.Position = UDim2.new(0.85, -5, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(toggleMenu)

-- Поиск
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0.9, 0, 0, 35)
SearchBox.Position = UDim2.new(0.05, 0, 0, 55)
SearchBox.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.PlaceholderText = "🔍 Поиск функции..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(180, 150, 200)
SearchBox.Text = ""
SearchBox.ClearTextOnFocus = false
SearchBox.Font = Enum.Font.GothamMedium
SearchBox.TextScaled = true
SearchBox.BorderSizePixel = 1
SearchBox.BorderColor3 = Color3.fromRGB(180, 100, 255)
SearchBox.Parent = MainFrame

-- Контейнер кнопок
local ButtonContainer = Instance.new("ScrollingFrame")
ButtonContainer.Size = UDim2.new(0.9, 0, 1, -110)
ButtonContainer.Position = UDim2.new(0.05, 0, 0, 95)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ButtonContainer.ScrollBarThickness = 6
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ButtonContainer

local allButtons = {}
local buttonRefs = {}

-- ============================================
-- КНОПКИ
-- ============================================
local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 200, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(180, 100, 255)
    btn.Parent = ButtonContainer
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
    end)
    
    btn.MouseButton1Click:Connect(function()
        callback()
        btn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        task.wait(0.1)
        btn.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
    end)
    
    -- БИНД: ПКМ → сразу нажать клавишу (без диалога)
    btn.MouseButton2Click:Connect(function()
        bindWaiting = callback
        print("[SergeiXuesos] ⏳ Нажмите клавишу для бинда...")
    end)
    
    table.insert(allButtons, {button = btn, text = text:lower()})
    buttonRefs[text] = btn
    return btn
end

-- Поиск
local function updateSearch(query)
    query = query:lower()
    local count = 0
    for _, data in ipairs(allButtons) do
        if query == "" or string.find(data.text, query, 1, true) then
            data.button.Visible = true
            count = count + 1
        else
            data.button.Visible = false
        end
    end
    ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, count * 39 + 20)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    updateSearch(SearchBox.Text)
end)

-- ============================================
-- FLY (WASD + Space/Shift)
-- ============================================
local function updateFly()
    if not toggles.Fly or not RootPart then return end
    local dir = Vector3.new(0, 0, 0)
    local cf = Camera.CFrame
    local forward = cf.LookVector
    local right = cf.RightVector
    local up = Vector3.new(0, 1, 0)
    
    if flyKeys.W then dir = dir + forward end
    if flyKeys.S then dir = dir - forward end
    if flyKeys.A then dir = dir - right end
    if flyKeys.D then dir = dir + right end
    if flyKeys.Space then dir = dir + up end
    if flyKeys.Shift then dir = dir - up end
    
    if dir.Magnitude > 0 then
        dir = dir.Unit * flySpeed
    end
    if bodyVelocity then
        bodyVelocity.Velocity = dir
    end
end

local function toggleFly()
    toggles.Fly = not toggles.Fly
    if toggles.Fly then
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
        
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
        bodyVelocity.Parent = RootPart
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 100000
        bodyGyro.CFrame = RootPart.CFrame
        bodyGyro.Parent = RootPart
        
        flyConnection = RunService.Heartbeat:Connect(updateFly)
        Humanoid.PlatformStand = true
        print("[SergeiXuesos] Fly ON")
    else
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        Humanoid.PlatformStand = false
        print("[SergeiXuesos] Fly OFF")
    end
end

local function setFlySpeed(val)
    flySpeed = val
    print("[SergeiXuesos] Fly Speed: " .. flySpeed)
end

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if toggles.Fly then
        if inp.KeyCode == Enum.KeyCode.W then flyKeys.W = true end
        if inp.KeyCode == Enum.KeyCode.A then flyKeys.A = true end
        if inp.KeyCode == Enum.KeyCode.S then flyKeys.S = true end
        if inp.KeyCode == Enum.KeyCode.D then flyKeys.D = true end
        if inp.KeyCode == Enum.KeyCode.Space then flyKeys.Space = true end
        if inp.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = true end
    end
end)

UserInputService.InputEnded:Connect(function(inp, gp)
    if gp then return end
    if toggles.Fly then
        if inp.KeyCode == Enum.KeyCode.W then flyKeys.W = false end
        if inp.KeyCode == Enum.KeyCode.A then flyKeys.A = false end
        if inp.KeyCode == Enum.KeyCode.S then flyKeys.S = false end
        if inp.KeyCode == Enum.KeyCode.D then flyKeys.D = false end
        if inp.KeyCode == Enum.KeyCode.Space then flyKeys.Space = false end
        if inp.KeyCode == Enum.KeyCode.LeftShift then flyKeys.Shift = false end
    end
end)

-- ============================================
-- NOCLIP
-- ============================================
local function toggleNoclip()
    toggles.Noclip = not toggles.Noclip
    if toggles.Noclip then
        if not noclipPart then
            noclipPart = Instance.new("Part")
            noclipPart.CanCollide = false
            noclipPart.Transparency = 1
            noclipPart.Size = Vector3.new(5, 5, 5)
            noclipPart.Anchored = true
            noclipPart.Parent = Workspace
        end
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Heartbeat:Connect(function()
            if toggles.Noclip and RootPart then
                noclipPart.Position = RootPart.Position
                for _, p in ipairs(Character:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end
        end)
        print("[SergeiXuesos] Noclip ON")
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        if noclipPart then noclipPart:Destroy() noclipPart = nil end
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = true
            end
        end
        print("[SergeiXuesos] Noclip OFF")
    end
end

-- ============================================
-- SPIDER (РЫВОК ПО ТЕКСТУРЕ)
-- ============================================
local function toggleSpider()
    toggles.Spider = not toggles.Spider
    if toggles.Spider then
        if spiderConnection then spiderConnection:Disconnect() end
        spiderConnection = RunService.Heartbeat:Connect(function()
            if toggles.Spider and RootPart and RootPart.Parent and Humanoid then
                local ray = Ray.new(RootPart.Position, RootPart.CFrame.LookVector * 3)
                local hit = Workspace:FindPartOnRay(ray, Character)
                if hit then
                    Humanoid.WalkSpeed = 20
                    RootPart.Velocity = RootPart.Velocity + Vector3.new(0, -2, 0)
                    RootPart.CFrame = RootPart.CFrame + RootPart.CFrame.LookVector * 1.5
                end
            end
        end)
        print("[SergeiXuesos] Spider ON")
    else
        if spiderConnection then spiderConnection:Disconnect() spiderConnection = nil end
        Humanoid.WalkSpeed = 16
        print("[SergeiXuesos] Spider OFF")
    end
end

-- ============================================
-- ESP (ФИОЛЕТОВЫЙ)
-- ============================================
local function createESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(3, 5, 1.5)
    box.Adornee = hrp
    box.Color3 = Color3.fromRGB(180, 100, 255)
    box.Transparency = 0.4
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Parent = hrp
    
    local bill = Instance.new("BillboardGui")
    bill.Adornee = hrp
    bill.Size = UDim2.new(0, 200, 0, 50)
    bill.StudsOffset = Vector3.new(0, 4, 0)
    bill.AlwaysOnTop = true
    bill.Parent = hrp
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name
    label.TextColor3 = Color3.fromRGB(200, 150, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = bill
    
    table.insert(espObjects, box)
    table.insert(espObjects, bill)
end

local function toggleESP()
    toggles.ESP = not toggles.ESP
    if toggles.ESP then
        for _, obj in ipairs(espObjects) do obj:Destroy() end
        espObjects = {}
        for _, conn in ipairs(espConnections) do conn:Disconnect() end
        espConnections = {}
        
        for _, plr in ipairs(Players:GetPlayers()) do
            createESP(plr)
        end
        print("[SergeiXuesos] ESP ON")
    else
        for _, obj in ipairs(espObjects) do obj:Destroy() end
        espObjects = {}
        print("[SergeiXuesos] ESP OFF")
    end
end

-- ============================================
-- БИНДЫ (ПКМ → клавиша, без диалога)
-- ============================================
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    
    if binds[inp.KeyCode] then
        binds[inp.KeyCode]()
    end
    
    if bindWaiting then
        if inp.KeyCode == Enum.KeyCode.Delete then
            for k, f in pairs(binds) do
                if f == bindWaiting then
                    binds[k] = nil
                    print("[SergeiXuesos] ❌ Бинд снят: " .. tostring(k.Name))
                    break
                end
            end
            bindWaiting = nil
        elseif inp.KeyCode ~= Enum.KeyCode.Unknown then
            binds[inp.KeyCode] = bindWaiting
            print("[SergeiXuesos] ✅ Бинд: " .. tostring(inp.KeyCode.Name))
            bindWaiting = nil
        end
    end
end)

-- ============================================
-- КНОПКИ МЕНЮ
-- ============================================
createButton("Fly (WASD + Space/Shift)", toggleFly)
createButton("Fly Speed 25", function() setFlySpeed(25) end)
createButton("Fly Speed 50", function() setFlySpeed(50) end)
createButton("Fly Speed 75", function() setFlySpeed(75) end)
createButton("Fly Speed 100", function() setFlySpeed(100) end)
createButton("Fly Speed 150", function() setFlySpeed(150) end)
createButton("Fly Speed 200", function() setFlySpeed(200) end)

createButton("Noclip", toggleNoclip)
createButton("Spider (рынок по текстуре)", toggleSpider)
createButton("ESP (фиолетовый)", toggleESP)

createButton("Kill All", function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.Health = 0
            end
        end
    end
    print("[SergeiXuesos] All players killed")
end)

createButton("Teleport", function()
    local d = Instance.new("TextBox")
    d.Size = UDim2.new(0, 200, 0, 30)
    d.Position = UDim2.new(0.5, -100, 0.5, -15)
    d.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
    d.TextColor3 = Color3.fromRGB(255, 255, 255)
    d.PlaceholderText = "Имя игрока"
    d.ClearTextOnFocus = false
    d.Font = Enum.Font.GothamMedium
    d.TextScaled = true
    d.Parent = MainFrame
    d:CaptureFocus()
    d.FocusLost:Connect(function(entered)
        if entered and d.Text ~= "" then
            for _, plr in ipairs(Players:GetPlayers()) do
                if string.find(plr.Name:lower(), d.Text:lower(), 1, true) then
                    local char = plr.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        RootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                        print("[SergeiXuesos] TP to " .. plr.Name)
                        break
                    end
                end
            end
        end
        d:Destroy()
    end)
end)

createButton("Clear Parts", function()
    local count = 0
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part ~= RootPart and part.Parent ~= Character then
            if not part:IsA("Terrain") then
                part:Destroy()
                count = count + 1
            end
        end
    end
    print("[SergeiXuesos] Cleared " .. count .. " parts")
end)

task.wait(0.1)
ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, #allButtons * 39 + 20)

-- ============================================
-- ОТКРЫТИЕ МЕНЮ
-- ============================================
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.X then toggleMenu()
    elseif inp.KeyCode == Enum.KeyCode.M then toggleMenu()
    elseif inp.KeyCode == Enum.KeyCode.Insert then toggleMenu() end
end)

-- ============================================
-- СБРОС ПРИ ПЕРЕРОЖДЕНИИ
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    
    toggles.Fly = false
    toggles.Noclip = false
    toggles.Spider = false
    toggles.ESP = false
    
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    if noclipPart then noclipPart:Destroy() noclipPart = nil end
    if spiderConnection then spiderConnection:Disconnect() spiderConnection = nil end
    
    for _, obj in ipairs(espObjects) do obj:Destroy() end
    espObjects = {}
    
    Humanoid.PlatformStand = false
    print("[SergeiXuesos] Character reset")
end)

print("═══════════════════════════════════════")
print("  ✦ SERGEI XUESOS v2.0 ✦")
print("  Открытие: X, M, Insert")
print("  БИНДЫ: ПКМ на кнопке → нажать клавишу")
print("  DELETE - снять бинд")
print("═══════════════════════════════════════")
