-- FlagmanUltimateV2.lua
-- Улучшенная версия: WASD-полёт + регулировка скорости + вкладки + снежинки
-- Версия 4.0
-- Автор: good

-- ====== СЕРВИСЫ ======
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
if not player then return end

-- ====== ПЕРСОНАЖ (с обновлением) ======
local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHumanoid() return getChar():WaitForChild("Humanoid") end
local function getRoot() return getChar():FindFirstChild("HumanoidRootPart") end

-- ====== СОСТОЯНИЯ ======
local state = {
    fly = false,
    noclip = false,
    god = false,
    spider = false,
    scaffold = false,
    flySpeed = 50,          -- скорость полёта
    speedMult = 1,
    jumpMult = 1,
}
local flyBodyVel = nil
local noclipPart = nil
local spiderConn = nil
local scaffoldConn = nil

-- ====== УПРАВЛЕНИЕ ПОЛЁТОМ (WASD + ПРОБЕЛ + SHIFT) ======
local keys = { w = false, a = false, s = false, d = false, space = false, shift = false }

local function updateFly()
    if not state.fly then return end
    local root = getRoot()
    if not root then return end
    if not flyBodyVel then
        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        flyBodyVel.Parent = root
    end
    local speed = state.flySpeed
    local dir = Vector3.new()
    if keys.w then dir = dir + root.CFrame.LookVector end
    if keys.s then dir = dir - root.CFrame.LookVector end
    if keys.a then dir = dir - root.CFrame.RightVector end
    if keys.d then dir = dir + root.CFrame.RightVector end
    if keys.space then dir = dir + Vector3.new(0, 1, 0) end
    if keys.shift then dir = dir - Vector3.new(0, 1, 0) end
    if dir.Magnitude > 0 then
        dir = dir.Unit * speed
    end
    flyBodyVel.Velocity = dir
end

-- Отслеживание нажатий
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then keys.w = true; updateFly() end
    if key == Enum.KeyCode.A then keys.a = true; updateFly() end
    if key == Enum.KeyCode.S then keys.s = true; updateFly() end
    if key == Enum.KeyCode.D then keys.d = true; updateFly() end
    if key == Enum.KeyCode.Space then keys.space = true; updateFly() end
    if key == Enum.KeyCode.LeftShift then keys.shift = true; updateFly() end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then keys.w = false; updateFly() end
    if key == Enum.KeyCode.A then keys.a = false; updateFly() end
    if key == Enum.KeyCode.S then keys.s = false; updateFly() end
    if key == Enum.KeyCode.D then keys.d = false; updateFly() end
    if key == Enum.KeyCode.Space then keys.space = false; updateFly() end
    if key == Enum.KeyCode.LeftShift then keys.shift = false; updateFly() end
end)

-- ====== ФУНКЦИИ ЧИТОВ ======
local function toggleFly()
    state.fly = not state.fly
    if not state.fly then
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
        local root = getRoot()
        if root then root.Velocity = Vector3.new() end
    else
        updateFly()
    end
    print("[Flagman] Fly " .. (state.fly and "ON" or "OFF"))
end

local function toggleNoclip()
    state.noclip = not state.noclip
    if state.noclip then
        noclipPart = Instance.new("Part")
        noclipPart.CanCollide = false
        noclipPart.Transparency = 1
        noclipPart.Size = Vector3.new(5,5,5)
        noclipPart.Anchored = true
        noclipPart.Parent = workspace
        RunService.Heartbeat:Connect(function()
            if state.noclip and getRoot() then
                noclipPart.Position = getRoot().Position
            end
        end)
    else
        if noclipPart then noclipPart:Destroy(); noclipPart = nil end
    end
    print("[Flagman] Noclip " .. (state.noclip and "ON" or "OFF"))
end

local function toggleGod()
    state.god = not state.god
    local hum = getHumanoid()
    if hum then
        if state.god then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        else
            hum.MaxHealth = 100
            hum.Health = 100
        end
    end
    print("[Flagman] God " .. (state.god and "ON" or "OFF"))
end

local function toggleSpider()
    state.spider = not state.spider
    if state.spider then
        if spiderConn then spiderConn:Disconnect() end
        spiderConn = RunService.Heartbeat:Connect(function()
            if state.spider then
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
    else
        if spiderConn then spiderConn:Disconnect(); spiderConn = nil end
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = 16 end
    end
    print("[Flagman] Spider " .. (state.spider and "ON" or "OFF"))
end

local function toggleScaffold()
    state.scaffold = not state.scaffold
    if state.scaffold then
        if scaffoldConn then scaffoldConn:Disconnect() end
        scaffoldConn = RunService.Heartbeat:Connect(function()
            if state.scaffold then
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
    else
        if scaffoldConn then scaffoldConn:Disconnect(); scaffoldConn = nil end
    end
    print("[Flagman] Scaffold " .. (state.scaffold and "ON" or "OFF"))
end

-- Регулировка скорости полёта (кнопки в меню)
local function changeFlySpeed(delta)
    state.flySpeed = math.max(10, state.flySpeed + delta)
    if state.fly then updateFly() end
    print("[Flagman] Fly Speed: " .. state.flySpeed)
end

local function setSpeed(mult)
    state.speedMult = mult
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = 16 * mult end
end

local function setJump(mult)
    state.jumpMult = mult
    local hum = getHumanoid()
    if hum then hum.JumpPower = 50 * mult end
end

local function clearParts()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part ~= getRoot() then
            part:Destroy()
        end
    end
    print("[Flagman] Cleared")
end

local function teleportTo(target)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower():find(target:lower()) then
            local root = getRoot()
            if root and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                root.CFrame = plr.Character.HumanoidRootPart.CFrame
                print("[Flagman] TP to " .. plr.Name)
                return
            end
        end
    end
    print("[Flagman] Player not found")
end

-- ====== ВИЗУАЛЬНЫЕ ЭФФЕКТЫ ======
local function createEffect(className, props)
    local existing = Lighting:FindFirstChildOfClass(className)
    if existing then existing:Destroy() end
    local obj = Instance.new(className)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = Lighting
    return obj
end

local atmos = createEffect("Atmosphere", { Density = 0.35, Offset = 0.25, Color = Color3.fromRGB(190,210,235), Decay = Color3.fromRGB(100,110,140), Glaire = 0.4, Haze = 2, Enabled = true })
local sunRays = createEffect("SunRaysEffect", { Intensity = 0.25, Spread = 1, Enabled = true })
local colorCorr = createEffect("ColorCorrectionEffect", { Brightness = 0.05, Contrast = 0.2, Saturation = 0.25, TintColor = Color3.fromRGB(255,248,240), Enabled = true })
local bloom = createEffect("BloomEffect", { Intensity = 0.4, Size = 24, Threshold = 0.8, Enabled = true })
local dof = createEffect("DepthOfFieldEffect", { FarIntensity = 0.3, InNearBlur = 0, NearIntensity = 0, Enabled = true })

Lighting.Technology = Enum.Technology.Future
Lighting.GlobalShadows = true
Lighting.EnvironmentOutdoorScale = 1
Lighting.EnvironmentSpecularScale = 1

local visualOn = { atmos = true, sun = true, color = true, bloom = true, dof = true }

local function toggleVisual(name)
    visualOn[name] = not visualOn[name]
    if name == "atmos" then atmos.Enabled = visualOn.atmos; atmos.Density = visualOn.atmos and 0.35 or 0
    elseif name == "sun" then sunRays.Enabled = visualOn.sun
    elseif name == "color" then colorCorr.Enabled = visualOn.color
    elseif name == "bloom" then bloom.Enabled = visualOn.bloom
    elseif name == "dof" then dof.Enabled = visualOn.dof
    end
end

-- ====== GUI (с снежинками) ======
local gui = Instance.new("ScreenGui")
gui.Name = "FlagmanUltimateV2"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Слой снежинок
local snowLayer = Instance.new("Frame")
snowLayer.Size = UDim2.new(1, 0, 1, 0)
snowLayer.BackgroundTransparency = 1
snowLayer.ZIndex = 0
snowLayer.Parent = gui

local snowflakes = {}
for i = 1, 30 do
    local sf = Instance.new("Frame")
    local size = 2 + math.random() * 4
    sf.Size = UDim2.new(0, size, 0, size)
    sf.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sf.BackgroundTransparency = 0.3 + math.random() * 0.5
    sf.BorderSizePixel = 0
    sf.Position = UDim2.new(math.random(), 0, math.random(), 0)
    sf.Parent = snowLayer
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
        if d.y > 100 then d.y = -2; d.x = math.random() * 100 end
        if d.x > 100 then d.x = 0 end
        if d.x < 0 then d.x = 100 end
        sf.frame.Position = UDim2.new(d.x / 100, 0, d.y / 100, 0)
    end
end)

-- Основное меню (тёмное, но без затемнения)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 450)
frame.Position = UDim2.new(0.5, -175, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(200, 200, 255)
frame.ClipsDescendants = true
frame.Visible = false
frame.ZIndex = 2
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "❄ Flagman Ultimate V2 ❄"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Вкладки
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 35)
tabContainer.Position = UDim2.new(0, 10, 0, 50)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = frame

local visTab = Instance.new("TextButton")
visTab.Size = UDim2.new(0.5, -5, 1, 0)
visTab.Position = UDim2.new(0, 0, 0, 0)
visTab.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
visTab.Text = "Визуал"
visTab.TextColor3 = Color3.fromRGB(255,255,255)
visTab.TextScaled = true
visTab.Font = Enum.Font.GothamMedium
visTab.BorderSizePixel = 1
visTab.BorderColor3 = Color3.fromRGB(200,200,255)
visTab.Parent = tabContainer

local cheatTab = Instance.new("TextButton")
cheatTab.Size = UDim2.new(0.5, -5, 1, 0)
cheatTab.Position = UDim2.new(0.5, 5, 0, 0)
cheatTab.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
cheatTab.Text = "Читы"
cheatTab.TextColor3 = Color3.fromRGB(255,255,255)
cheatTab.TextScaled = true
cheatTab.Font = Enum.Font.GothamMedium
cheatTab.BorderSizePixel = 1
cheatTab.BorderColor3 = Color3.fromRGB(200,200,255)
cheatTab.Parent = tabContainer

-- Контейнер кнопок
local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -20, 1, -100)
container.Position = UDim2.new(0, 10, 0, 90)
container.BackgroundTransparency = 1
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.ScrollBarThickness = 6
container.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = container

-- Функция создания кнопки (переключатель)
local function createToggle(text, getState, setState)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    btn.Text = text .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(150,150,200)
    btn.Parent = container

    local function update()
        local s = getState()
        btn.Text = text .. (s and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = s and Color3.fromRGB(30, 90, 40) or Color3.fromRGB(45, 45, 70)
    end
    update()

    btn.MouseButton1Click:Connect(function()
        setState(not getState())
        update()
    end)
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = getState() and Color3.fromRGB(50, 130, 60) or Color3.fromRGB(65, 65, 100)
    end)
    btn.MouseLeave:Connect(function() update() end)
    return btn
end

-- Функция создания кнопки-действия
local function createAction(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(150,150,200)
    btn.Parent = container
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(65, 65, 100) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(45, 45, 70) end)
    return btn
end

-- ====== ЗАПОЛНЕНИЕ ВКЛАДОК ======
local function fillVisual()
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    createToggle("🌫️ Туман", function() return visualOn.atmos end, function(v) toggleVisual("atmos") end)
    createToggle("☀️ Лучи", function() return visualOn.sun end, function(v) toggleVisual("sun") end)
    createToggle("🎨 Цветокоррекция", function() return visualOn.color end, function(v) toggleVisual("color") end)
    createToggle("💡 Свечение", function() return visualOn.bloom end, function(v) toggleVisual("bloom") end)
    createToggle("📷 Размытие", function() return visualOn.dof end, function(v) toggleVisual("dof") end)
    createAction("☀️ День", function() Lighting.ClockTime = 14 end)
    createAction("🌆 Вечер", function() Lighting.ClockTime = 18 end)
    createAction("🌙 Ночь", function() Lighting.ClockTime = 0 end)
end

local function fillCheats()
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    createToggle("🪶 Fly (WASD)", function() return state.fly end, function(v) toggleFly() end)
    createToggle("🚪 Noclip", function() return state.noclip end, function(v) toggleNoclip() end)
    createToggle("🛡️ God", function() return state.god end, function(v) toggleGod() end)
    createToggle("🕷️ Spider", function() return state.spider end, function(v) toggleSpider() end)
    createToggle("🧱 Scaffold", function() return state.scaffold end, function(v) toggleScaffold() end)
    
    -- Регулировка скорости полёта
    createAction("⬆️ Fly Speed +10", function() changeFlySpeed(10) end)
    createAction("⬇️ Fly Speed -10", function() changeFlySpeed(-10) end)
    createAction("⚡ Speed x2", function() setSpeed(2) end)
    createAction("⚡ Speed x3", function() setSpeed(3) end)
    createAction("🦘 Jump x2", function() setJump(2) end)
    createAction("🦘 Jump x3", function() setJump(3) end)
    createAction("🧹 Clear Parts", clearParts)
    createAction("📌 TP to bsjfcnjr", function() teleportTo("bsjfcnjr") end)
    createAction("🔄 Reset Speed/Jump", function() setSpeed(1); setJump(1) end)
end

-- Переключение вкладок
visTab.MouseButton1Click:Connect(function()
    visTab.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    cheatTab.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    fillVisual()
end)
cheatTab.MouseButton1Click:Connect(function()
    cheatTab.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    visTab.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    fillCheats()
end)

-- По умолчанию открываем Читы (чтобы сразу видеть управление полётом)
fillCheats()
cheatTab.BackgroundColor3 = Color3.fromRGB(60, 60, 100)

-- ====== ОТКРЫТИЕ МЕНЮ ПО INSERT ======
local open = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        open = not open
        frame.Visible = open
    end
end)

-- ====== ХОТКЕИ ======
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFly() end
    if input.KeyCode == Enum.KeyCode.N then toggleNoclip() end
    if input.KeyCode == Enum.KeyCode.G then toggleGod() end
    if input.KeyCode == Enum.KeyCode.S then toggleSpider() end
    if input.KeyCode == Enum.KeyCode.B then toggleScaffold() end
    if input.KeyCode == Enum.KeyCode.C then clearParts() end
end)

print("=== Flagman Ultimate V2 загружен ===")
print("Insert — меню, WASD — полёт, F/N/G/S/B/C — хоткеи")
print("Скорость полёта регулируется кнопками в меню (Читы)")
