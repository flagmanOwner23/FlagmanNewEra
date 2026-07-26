-- FlagmanUltimate.lua
-- Мега-меню с визуалом и читами, снежинки, чёрный стиль
-- Версия 3.0
-- Автор: good

-- ====== СЕРВИСЫ ======
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ====== СОСТОЯНИЯ ДЛЯ ЧИТОВ ======
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

-- ====== СОСТОЯНИЯ ДЛЯ ВИЗУАЛА ======
local visualStates = {
    atmosphere = true,
    sunRays = true,
    colorCorr = true,
    bloom = true,
    dof = true,
    rain = false,
    snow = false,
    timeOfDay = "день", -- день, вечер, ночь
}

-- ====== СОЗДАНИЕ ВИЗУАЛЬНЫХ ЭФФЕКТОВ ======
local function safeCreate(className, props)
    local existing = Lighting:FindFirstChildOfClass(className)
    if existing then existing:Destroy() end
    local obj = Instance.new(className)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = Lighting
    return obj
end

local atmosphere = safeCreate("Atmosphere", {
    Density = 0.35,
    Offset = 0.25,
    Color = Color3.fromRGB(190, 210, 235),
    Decay = Color3.fromRGB(100, 110, 140),
    Glaire = 0.4,
    Haze = 2,
    Enabled = true,
})
local sunRays = safeCreate("SunRaysEffect", { Intensity = 0.25, Spread = 1, Enabled = true })
local colorCorr = safeCreate("ColorCorrectionEffect", {
    Brightness = 0.05, Contrast = 0.2, Saturation = 0.25,
    TintColor = Color3.fromRGB(255, 248, 240), Enabled = true,
})
local bloom = safeCreate("BloomEffect", { Intensity = 0.4, Size = 24, Threshold = 0.8, Enabled = true })
local dof = safeCreate("DepthOfFieldEffect", { FarIntensity = 0.3, InNearBlur = 0, NearIntensity = 0, Enabled = true })

-- Включаем лучшее освещение
Lighting.Technology = Enum.Technology.Future
Lighting.GlobalShadows = true
Lighting.EnvironmentOutdoorScale = 1
Lighting.EnvironmentSpecularScale = 1
Lighting.ClockTime = 14 -- день

-- Функции для управления визуалом
local function setVisual(name, enabled)
    visualStates[name] = enabled
    if name == "atmosphere" then
        atmosphere.Enabled = enabled
        atmosphere.Density = enabled and 0.35 or 0
    elseif name == "sunRays" then sunRays.Enabled = enabled
    elseif name == "colorCorr" then colorCorr.Enabled = enabled
    elseif name == "bloom" then bloom.Enabled = enabled
    elseif name == "dof" then dof.Enabled = enabled
    elseif name == "rain" then
        Lighting.Rain = enabled and 0.5 or 0
    elseif name == "snow" then
        Lighting.Snow = enabled and 0.5 or 0
    elseif name == "timeOfDay" then
        if enabled == "день" then Lighting.ClockTime = 14
        elseif enabled == "вечер" then Lighting.ClockTime = 18
        elseif enabled == "ночь" then Lighting.ClockTime = 0
        end
    end
end

-- ====== ФУНКЦИИ ЧИТОВ ======
local function toggleFly()
    cheats.fly = not cheats.fly
    if cheats.fly then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1,1,1) * 100000
        bodyVelocity.Velocity = Vector3.new(0, 50, 0)
        bodyVelocity.Parent = rootPart
        print("[Flagman] Fly ON")
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        print("[Flagman] Fly OFF")
    end
end

local function toggleNoclip()
    cheats.noclip = not cheats.noclip
    if cheats.noclip then
        noclipPart = Instance.new("Part")
        noclipPart.CanCollide = false
        noclipPart.Transparency = 1
        noclipPart.Size = Vector3.new(5,5,5)
        noclipPart.Anchored = true
        noclipPart.Parent = workspace
        RunService.Heartbeat:Connect(function()
            if cheats.noclip and rootPart then
                noclipPart.Position = rootPart.Position
            end
        end)
        print("[Flagman] Noclip ON")
    else
        if noclipPart then noclipPart:Destroy() end
        print("[Flagman] Noclip OFF")
    end
end

local function toggleGod()
    cheats.god = not cheats.god
    if cheats.god then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        print("[Flagman] God ON")
    else
        humanoid.MaxHealth = 100
        humanoid.Health = 100
        print("[Flagman] God OFF")
    end
end

local function toggleSpider()
    cheats.spider = not cheats.spider
    if cheats.spider then
        if spiderConn then spiderConn:Disconnect() end
        spiderConn = RunService.Heartbeat:Connect(function()
            if cheats.spider and rootPart and humanoid then
                local ray = Ray.new(rootPart.Position, rootPart.CFrame.LookVector * 3)
                local hit = workspace:FindPartOnRay(ray)
                if hit then
                    humanoid.WalkSpeed = 20
                    rootPart.Velocity = rootPart.Velocity + Vector3.new(0, -2, 0)
                    rootPart.CFrame = rootPart.CFrame + rootPart.CFrame.LookVector * 1.5
                end
            end
        end)
        print("[Flagman] Spider ON")
    else
        if spiderConn then spiderConn:Disconnect() end
        humanoid.WalkSpeed = 16
        print("[Flagman] Spider OFF")
    end
end

local function toggleScaffold()
    cheats.scaffold = not cheats.scaffold
    if cheats.scaffold then
        if scaffoldConn then scaffoldConn:Disconnect() end
        scaffoldConn = RunService.Heartbeat:Connect(function()
            if cheats.scaffold and rootPart then
                local pos = rootPart.Position
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
        if scaffoldConn then scaffoldConn:Disconnect() end
        print("[Flagman] Scaffold OFF")
    end
end

local function setSpeed(value)
    cheats.speedMult = value
    humanoid.WalkSpeed = 16 * value
    print("[Flagman] Speed: " .. humanoid.WalkSpeed)
end

local function setJump(value)
    cheats.jumpMult = value
    humanoid.JumpPower = 50 * value
    print("[Flagman] Jump: " .. humanoid.JumpPower)
end

local function teleportTo(targetName)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower():find(targetName:lower()) then
            local targetChar = plr.Character
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                rootPart.CFrame = targetChar.HumanoidRootPart.CFrame
                print("[Flagman] TP to " .. plr.Name)
                return
            end
        end
    end
    print("[Flagman] Player not found")
end

local function clearParts()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part ~= rootPart then
            part:Destroy()
        end
    end
    print("[Flagman] Cleared")
end

-- ====== СОЗДАНИЕ ГЛАВНОГО GUI ======
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlagmanUltimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Слой для снежинок (поверх всего, но под меню)
local SnowLayer = Instance.new("Frame")
SnowLayer.Size = UDim2.new(1, 0, 1, 0)
SnowLayer.BackgroundTransparency = 1
SnowLayer.ZIndex = 0
SnowLayer.Parent = ScreenGui

-- Создаём 50 снежинок (белые точки)
local snowflakes = {}
for i = 1, 50 do
    local sf = Instance.new("Frame")
    sf.Size = UDim2.new(0, 3, 0, 3)
    sf.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sf.BackgroundTransparency = 0.3
    sf.BorderSizePixel = 0
    sf.Position = UDim2.new(math.random(), 0, math.random(), 0)
    sf.Parent = SnowLayer
    local data = {
        x = math.random() * 100, -- процент от ширины экрана
        y = math.random() * 100,
        speed = 0.5 + math.random() * 1.5,
        drift = (math.random() - 0.5) * 0.3,
        size = 2 + math.random() * 4,
        alpha = 0.3 + math.random() * 0.5,
    }
    sf.Size = UDim2.new(0, data.size, 0, data.size)
    sf.BackgroundTransparency = 1 - data.alpha
    snowflakes[i] = { frame = sf, data = data }
end

-- Анимация снежинок
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

-- Главная панель меню (чёрная, с закруглениями)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(180, 180, 255)
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "❄ Flagman Ultimate ❄"
Title.TextColor3 = Color3.fromRGB(200, 220, 255)
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
visualTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
visualTabBtn.Text = "Визуал"
visualTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
visualTabBtn.TextScaled = true
visualTabBtn.Font = Enum.Font.GothamMedium
visualTabBtn.BorderSizePixel = 1
visualTabBtn.BorderColor3 = Color3.fromRGB(100, 100, 200)
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

-- Контейнер для содержимого вкладок
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

-- Функция для создания кнопок (переключатели)
local function createToggle(text, callback, getState)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    btn.Text = text .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(80, 80, 120)
    btn.Parent = ContentContainer

    local function update()
        local state = getState()
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = state and Color3.fromRGB(20, 70, 40) or Color3.fromRGB(30, 30, 50)
    end
    update()

    btn.MouseButton1Click:Connect(function()
        callback(not getState())
        update()
    end)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = getState() and Color3.fromRGB(40, 100, 60) or Color3.fromRGB(50, 50, 80)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = getState() and Color3.fromRGB(20, 70, 40) or Color3.fromRGB(30, 30, 50)
    end)
    return btn
end

-- Функция для кнопок-действий (без состояния)
local function createAction(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(80, 80, 120)
    btn.Parent = ContentContainer
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    end)
    return btn
end

-- ====== ЗАПОЛНЕНИЕ ВКЛАДКИ "ВИЗУАЛ" ======
local function fillVisual()
    -- Очищаем контейнер
    for _, child in ipairs(ContentContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    createToggle("🌫️ Туман (Atmosphere)", function(v) setVisual("atmosphere", v) end, function() return visualStates.atmosphere end)
    createToggle("☀️ Солнечные лучи", function(v) setVisual("sunRays", v) end, function() return visualStates.sunRays end)
    createToggle("🎨 Цветокоррекция", function(v) setVisual("colorCorr", v) end, function() return visualStates.colorCorr end)
    createToggle("💡 Свечение (Bloom)", function(v) setVisual("bloom", v) end, function() return visualStates.bloom end)
    createToggle("📷 Размытие фона", function(v) setVisual("dof", v) end, function() return visualStates.dof end)
    createToggle("🌧️ Дождь", function(v) setVisual("rain", v) end, function() return visualStates.rain end)
    createToggle("❄️ Снег", function(v) setVisual("snow", v) end, function() return visualStates.snow end)

    -- Выбор времени суток (действия)
    createAction("☀️ День", function() setVisual("timeOfDay", "день") end)
    createAction("🌆 Вечер", function() setVisual("timeOfDay", "вечер") end)
    createAction("🌙 Ночь", function() setVisual("timeOfDay", "ночь") end)
end

-- ====== ЗАПОЛНЕНИЕ ВКЛАДКИ "ЧИТЫ" ======
local function fillCheats()
    for _, child in ipairs(ContentContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    createToggle("🪶 Fly (F)", function(v) if v then toggleFly() else toggleFly() end end, function() return cheats.fly end)
    createToggle("🚪 Noclip (N)", function(v) if v then toggleNoclip() else toggleNoclip() end end, function() return cheats.noclip end)
    createToggle("🛡️ Godmode (G)", function(v) if v then toggleGod() else toggleGod() end end, function() return cheats.god end)
    createToggle("🕷️ Spider (S)", function(v) if v then toggleSpider() else toggleSpider() end end, function() return cheats.spider end)
    createToggle("🧱 Scaffold (B)", function(v) if v then toggleScaffold() else toggleScaffold() end end, function() return cheats.scaffold end)
    createAction("⚡ Speed x2", function() setSpeed(2) end)
    createAction("⚡ Speed x3", function() setSpeed(3) end)
    createAction("🦘 Jump x2", function() setJump(2) end)
    createAction("🦘 Jump x3", function() setJump(3) end)
    createAction("🧹 Clear Parts (C)", clearParts)
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

-- По умолчанию открываем вкладку "Визуал"
fillVisual()
visualTabBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 120)

-- ====== ОТКРЫТИЕ/ЗАКРЫТИЕ МЕНЮ ПО INSERT ======
local menuOpen = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        menuOpen = not menuOpen
        MainFrame.Visible = true
        local goal = menuOpen and 0 or 1
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundTransparency = goal
        })
        tween:Play()
        if not menuOpen then
            wait(0.3)
            MainFrame.Visible = false
        end
    end
end)

-- ====== ХОТКЕИ ДЛЯ ЧИТОВ ======
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFly() end
    if input.KeyCode == Enum.KeyCode.N then toggleNoclip() end
    if input.KeyCode == Enum.KeyCode.G then toggleGod() end
    if input.KeyCode == Enum.KeyCode.S then toggleSpider() end
    if input.KeyCode == Enum.KeyCode.B then toggleScaffold() end
    if input.KeyCode == Enum.KeyCode.C then clearParts() end
end)

print("=== Flagman Ultimate загружен ===")
print("Нажмите INSERT для открытия меню")
print("Хоткеи: F - Fly, N - Noclip, G - God, S - Spider, B - Scaffold, C - Clear")
