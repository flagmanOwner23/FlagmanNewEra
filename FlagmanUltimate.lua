-- FlagmanUltimate_Fixed.lua
-- Версия 3.2 – исправлено затемнение меню
-- Автор: good

-- ====== СЕРВИСЫ ======
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
if not player then
    print("[Flagman] Ошибка: нет игрока")
    return
end

-- ====== ФУНКЦИИ ДЛЯ ПЕРСОНАЖА (с переподключением) ======
local function getChar()
    local char = player.Character
    if not char then
        char = player.CharacterAdded:Wait()
    end
    return char
end

local function getHumanoid()
    local char = getChar()
    return char:WaitForChild("Humanoid")
end

local function getRootPart()
    local char = getChar()
    return char:WaitForChild("HumanoidRootPart")
end

-- ====== ПЕРЕМЕННЫЕ ДЛЯ ЧИТОВ ======
local cheats = {
    fly = false,
    noclip = false,
    god = false,
    spider = false,
    scaffold = false,
    speedMult = 1,
    jumpMult = 1,
}
local bodyVelocity = nil
local noclipPart = nil
local spiderConn = nil
local scaffoldConn = nil
local heartbeatConn = nil

-- ====== СОЗДАНИЕ GUI (с запасным вариантом) ======
local screenGui
local success, err = pcall(function()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FlagmanUltimate"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
end)
if not success then
    local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FlagmanUltimate"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
end

if not screenGui then
    print("[Flagman] Не удалось создать GUI")
    return
end

-- ====== СНЕЖИНКИ ======
local SnowLayer = Instance.new("Frame")
SnowLayer.Size = UDim2.new(1, 0, 1, 0)
SnowLayer.BackgroundTransparency = 1
SnowLayer.ZIndex = 0
SnowLayer.Parent = screenGui

local snowflakes = {}
for i = 1, 30 do
    local sf = Instance.new("Frame")
    local size = 2 + math.random() * 4
    sf.Size = UDim2.new(0, size, 0, size)
    sf.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sf.BackgroundTransparency = 0.3 + math.random() * 0.5
    sf.BorderSizePixel = 0
    sf.Position = UDim2.new(math.random(), 0, math.random(), 0)
    sf.Parent = SnowLayer
    local data = {
        x = math.random() * 100,
        y = math.random() * 100,
        speed = 0.5 + math.random() * 1.5,
        drift = (math.random() - 0.5) * 0.3,
    }
    snowflakes[i] = { frame = sf, data = data }
end

RunService.Heartbeat:Connect(function(dt)
    for _, sf in ipairs(snowflakes) do
        local d = sf.data
        d.y = d.y + d.speed * dt * 60
        d.x = d.x + d.drift * dt * 60
        if d.y > 100 then
            d.y = -2
            d.x = math.random() * 100
        end
        if d.x > 100 then d.x = 0 end
        if d.x < 0 then d.x = 100 end
        sf.frame.Position = UDim2.new(d.x / 100, 0, d.y / 100, 0)
    end
end)

-- ====== ГЛАВНОЕ МЕНЮ (с полупрозрачным фоном) ======
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)  -- тёмно-синий
MainFrame.BackgroundTransparency = 0.2   -- полупрозрачный, чтобы видеть игру
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(180, 180, 255)
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.ZIndex = 2
MainFrame.Parent = screenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "❄ Flagman Ultimate ❄"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)  -- белый
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Вкладки
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 40)
TabContainer.Position = UDim2.new(0, 10, 0, 55)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local visualTabBtn = Instance.new("TextButton")
visualTabBtn.Size = UDim2.new(0.5, -5, 1, 0)
visualTabBtn.Position = UDim2.new(0, 0, 0, 0)
visualTabBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
visualTabBtn.Text = "Визуал"
visualTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
visualTabBtn.TextScaled = true
visualTabBtn.Font = Enum.Font.GothamMedium
visualTabBtn.BorderSizePixel = 1
visualTabBtn.BorderColor3 = Color3.fromRGB(200, 200, 255)
visualTabBtn.Parent = TabContainer

local cheatTabBtn = Instance.new("TextButton")
cheatTabBtn.Size = UDim2.new(0.5, -5, 1, 0)
cheatTabBtn.Position = UDim2.new(0.5, 5, 0, 0)
cheatTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
cheatTabBtn.Text = "Читы"
cheatTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cheatTabBtn.TextScaled = true
cheatTabBtn.Font = Enum.Font.GothamMedium
cheatTabBtn.BorderSizePixel = 1
cheatTabBtn.BorderColor3 = Color3.fromRGB(100, 100, 200)
cheatTabBtn.Parent = TabContainer

-- Контейнер для кнопок
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Size = UDim2.new(1, -20, 1, -110)
ContentContainer.Position = UDim2.new(0, 10, 0, 100)
ContentContainer.BackgroundTransparency = 1
ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentContainer.ScrollBarThickness = 6
ContentContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ContentContainer

-- ====== ВИЗУАЛЬНЫЕ ЭФФЕКТЫ (с защитой) ======
local function safeCreate(className, props)
    local success, obj = pcall(function()
        local existing = Lighting:FindFirstChildOfClass(className)
        if existing then existing:Destroy() end
        local newObj = Instance.new(className)
        for k, v in pairs(props) do newObj[k] = v end
        newObj.Parent = Lighting
        return newObj
    end)
    if not success then
        print("[Flagman] Ошибка создания " .. className)
        return nil
    end
    return obj
end

local atmosphere = safeCreate("Atmosphere", {
    Density = 0.35, Offset = 0.25, Color = Color3.fromRGB(190,210,235),
    Decay = Color3.fromRGB(100,110,140), Glaire = 0.4, Haze = 2, Enabled = true,
})
local sunRays = safeCreate("SunRaysEffect", { Intensity = 0.25, Spread = 1, Enabled = true })
local colorCorr = safeCreate("ColorCorrectionEffect", {
    Brightness = 0.05, Contrast = 0.2, Saturation = 0.25,
    TintColor = Color3.fromRGB(255,248,240), Enabled = true,
})
local bloom = safeCreate("BloomEffect", { Intensity = 0.4, Size = 24, Threshold = 0.8, Enabled = true })
local dof = safeCreate("DepthOfFieldEffect", { FarIntensity = 0.3, InNearBlur = 0, NearIntensity = 0, Enabled = true })

pcall(function()
    Lighting.Technology = Enum.Technology.Future
    Lighting.GlobalShadows = true
    Lighting.EnvironmentOutdoorScale = 1
    Lighting.EnvironmentSpecularScale = 1
    Lighting.ClockTime = 14
end)

local visualStates = {
    atmosphere = true, sunRays = true, colorCorr = true, bloom = true, dof = true,
}

local function setVisual(name, enabled)
    visualStates[name] = enabled
    if name == "atmosphere" and atmosphere then
        atmosphere.Enabled = enabled
        atmosphere.Density = enabled and 0.35 or 0
    elseif name == "sunRays" and sunRays then
        sunRays.Enabled = enabled
    elseif name == "colorCorr" and colorCorr then
        colorCorr.Enabled = enabled
    elseif name == "bloom" and bloom then
        bloom.Enabled = enabled
    elseif name == "dof" and dof then
        dof.Enabled = enabled
    end
end

-- ====== ФУНКЦИИ ЧИТОВ (с обновлением ссылок) ======
local function getRoot()
    local char = getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getChar()
    return char and char:FindFirstChild("Humanoid")
end

local function toggleFly()
    cheats.fly = not cheats.fly
    local root = getRoot()
    if cheats.fly and root then
        if bodyVelocity then bodyVelocity:Destroy() end
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1,1,1) * 100000
        bodyVelocity.Velocity = Vector3.new(0, 50, 0)
        bodyVelocity.Parent = root
        print("[Flagman] Fly ON")
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        print("[Flagman] Fly OFF")
    end
end

local function toggleNoclip()
    cheats.noclip = not cheats.noclip
    if cheats.noclip then
        if noclipPart then noclipPart:Destroy() end
        noclipPart = Instance.new("Part")
        noclipPart.CanCollide = false
        noclipPart.Transparency = 1
        noclipPart.Size = Vector3.new(5,5,5)
        noclipPart.Anchored = true
        noclipPart.Parent = workspace
        if heartbeatConn then heartbeatConn:Disconnect() end
        heartbeatConn = RunService.Heartbeat:Connect(function()
            if cheats.noclip then
                local root = getRoot()
                if root then noclipPart.Position = root.Position end
            end
        end)
        print("[Flagman] Noclip ON")
    else
        if noclipPart then noclipPart:Destroy() end
        if heartbeatConn then heartbeatConn:Disconnect() end
        print("[Flagman] Noclip OFF")
    end
end

local function toggleGod()
    cheats.god = not cheats.god
    local hum = getHumanoid()
    if cheats.god and hum then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        print("[Flagman] God ON")
    else
        if hum then
            hum.MaxHealth = 100
            hum.Health = 100
        end
        print("[Flagman] God OFF")
    end
end

local function toggleSpider()
    cheats.spider = not cheats.spider
    if cheats.spider then
        if spiderConn then spiderConn:Disconnect() end
        spiderConn = RunService.Heartbeat:Connect(function()
            if cheats.spider then
                local root = getRoot()
                local hum = getHumanoid()
                if root and hum then
                    local ray = Ray.new(root.Position, root.CFrame.LookVector * 3)
                    local hit = workspace:FindPartOnRay(ray)
                    if hit then
                        hum.WalkSpeed = 20
                        root.Velocity = root.Velocity + Vector3.new(0, -2, 0)
                        root.CFrame = root.CFrame + root.CFrame.LookVector * 1.5
                    end
                end
            end
        end)
        print("[Flagman] Spider ON")
    else
        if spiderConn then spiderConn:Disconnect() end
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = 16 end
        print("[Flagman] Spider OFF")
    end
end

local function toggleScaffold()
    cheats.scaffold = not cheats.scaffold
    if cheats.scaffold then
        if scaffoldConn then scaffoldConn:Disconnect() end
        scaffoldConn = RunService.Heartbeat:Connect(function()
            if cheats.scaffold then
                local root = getRoot()
                if root then
                    local pos = root.Position
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
            end
        end)
        print("[Flagman] Scaffold ON")
    else
        if scaffoldConn then scaffoldConn:Disconnect() end
        print("[Flagman] Scaffold OFF")
    end
end

local function setSpeed(value)
    cheats.speedMult = value
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = 16 * value end
    print("[Flagman] Speed: " .. (hum and hum.WalkSpeed or "N/A"))
end

local function setJump(value)
    cheats.jumpMult = value
    local hum = getHumanoid()
    if hum then hum.JumpPower = 50 * value end
    print("[Flagman] Jump: " .. (hum and hum.JumpPower or "N/A"))
end

local function teleportTo(targetName)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower():find(targetName:lower()) then
            local targetChar = plr.Character
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                local root = getRoot()
                if root then
                    root.CFrame = targetChar.HumanoidRootPart.CFrame
                    print("[Flagman] TP to " .. plr.Name)
                end
                return
            end
        end
    end
    print("[Flagman] Player not found")
end

local function clearParts()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part ~= getRoot() then
            part:Destroy()
        end
    end
    print("[Flagman] Cleared")
end

-- ====== СОЗДАНИЕ КНОПОК (яркие, контрастные) ======
local function createToggle(text, getState, setState)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)  -- ярче фон
    btn.Text = text .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)    -- белый текст
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(200, 200, 255)
    btn.Parent = ContentContainer

    local function update()
        local state = getState()
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = state and Color3.fromRGB(30, 120, 40) or Color3.fromRGB(50, 50, 80)
        btn.TextColor3 = state and Color3.fromRGB(255, 255, 200) or Color3.fromRGB(255, 255, 255)
    end
    update()

    btn.MouseButton1Click:Connect(function()
        setState(not getState())
        update()
    end)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = getState() and Color3.fromRGB(50, 180, 60) or Color3.fromRGB(70, 70, 110)
    end)
    btn.MouseLeave:Connect(function()
        update()
    end)
    return btn
end

local function createAction(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(200, 200, 255)
    btn.Parent = ContentContainer
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 110)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    end)
    return btn
end

-- ====== ЗАПОЛНЕНИЕ ВКЛАДОК ======
local function fillVisual()
    for _, child in ipairs(ContentContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    createToggle("🌫️ Туман", function() return visualStates.atmosphere end, function(v) setVisual("atmosphere", v) end)
    createToggle("☀️ Лучи", function() return visualStates.sunRays end, function(v) setVisual("sunRays", v) end)
    createToggle("🎨 Цветокоррекция", function() return visualStates.colorCorr end, function(v) setVisual("colorCorr", v) end)
    createToggle("💡 Свечение", function() return visualStates.bloom end, function(v) setVisual("bloom", v) end)
    createToggle("📷 Размытие", function() return visualStates.dof end, function(v) setVisual("dof", v) end)
    createAction("☀️ День", function() Lighting.ClockTime = 14 end)
    createAction("🌆 Вечер", function() Lighting.ClockTime = 18 end)
    createAction("🌙 Ночь", function() Lighting.ClockTime = 0 end)
end

local function fillCheats()
    for _, child in ipairs(ContentContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    createToggle("🪶 Fly (F)", function() return cheats.fly end, function(v) if v ~= cheats.fly then toggleFly() end end)
    createToggle("🚪 Noclip (N)", function() return cheats.noclip end, function(v) if v ~= cheats.noclip then toggleNoclip() end end)
    createToggle("🛡️ God (G)", function() return cheats.god end, function(v) if v ~= cheats.god then toggleGod() end end)
    createToggle("🕷️ Spider (S)", function() return cheats.spider end, function(v) if v ~= cheats.spider then toggleSpider() end end)
    createToggle("🧱 Scaffold (B)", function() return cheats.scaffold end, function(v) if v ~= cheats.scaffold then toggleScaffold() end end)
    createAction("⚡ Speed x2", function() setSpeed(2) end)
    createAction("⚡ Speed x3", function() setSpeed(3) end)
    createAction("🦘 Jump x2", function() setJump(2) end)
    createAction("🦘 Jump x3", function() setJump(3) end)
    createAction("🧹 Clear (C)", clearParts)
    createAction("📌 TP to bsjfcnjr", function() teleportTo("bsjfcnjr") end)
    createAction("🔄 Reset Speed/Jump", function() setSpeed(1); setJump(1) end)
end

-- Переключение вкладок
visualTabBtn.MouseButton1Click:Connect(function()
    visualTabBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
    cheatTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    fillVisual()
end)

cheatTabBtn.MouseButton1Click:Connect(function()
    cheatTabBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
    visualTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    fillCheats()
end)

-- По умолчанию визуал
fillVisual()
visualTabBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 120)

-- ====== ОТКРЫТИЕ/ЗАКРЫТИЕ БЕЗ АНИМАЦИИ (чтобы не было затемнения) ======
local menuOpen = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        menuOpen = not menuOpen
        MainFrame.Visible = menuOpen
        -- Если нужно плавное появление, можно использовать Tween, но оставим мгновенное
    end
end)

-- ====== ХОТКЕИ ======
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFly() end
    if input.KeyCode == Enum.KeyCode.N then toggleNoclip() end
    if input.KeyCode == Enum.KeyCode.G then toggleGod() end
    if input.KeyCode == Enum.KeyCode.S then toggleSpider() end
    if input.KeyCode == Enum.KeyCode.B then toggleScaffold() end
    if input.KeyCode == Enum.KeyCode.C then clearParts() end
end)

print("=== Flagman Ultimate исправлен (без затемнения) ===")
print("Нажми INSERT для открытия меню")
print("Хоткеи: F, N, G, S, B, C")
