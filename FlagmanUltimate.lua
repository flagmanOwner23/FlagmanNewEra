-- FlagmanSimple.lua
-- Простая, но мощная менюха для Xeno
-- Всё работает плавно, без багов

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
if not player then return end

-- ====== ФУНКЦИИ ДЛЯ ПЕРСОНАЖА ======
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
    flySpeed = 50,
    speedMult = 1,
    jumpMult = 1,
}
local flyVel = nil
local noclipPart = nil
local spiderConn = nil
local scaffoldConn = nil

-- ====== УПРАВЛЕНИЕ ПОЛЁТОМ (WASD) ======
local keys = { w = false, a = false, s = false, d = false, space = false, shift = false }
local flyBodyVel = nil

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

-- ====== МЕНЮ (МИНИМАЛИСТИЧНОЕ) ======
local gui = Instance.new("ScreenGui")
gui.Name = "FlagmanGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(200, 200, 255)
frame.Visible = false
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "❄ Flagman ❄"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -20, 1, -60)
container.Position = UDim2.new(0, 10, 0, 50)
container.BackgroundTransparency = 1
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.ScrollBarThickness = 6
container.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = container

local function btn(text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextScaled = true
    b.Font = Enum.Font.GothamMedium
    b.BorderSizePixel = 1
    b.BorderColor3 = Color3.fromRGB(150, 150, 200)
    b.Parent = container
    b.MouseButton1Click:Connect(callback)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(65, 65, 100) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(45, 45, 70) end)
    return b
end

-- Кнопки
btn("🪶 Fly (WASD)", toggleFly)
btn("🚪 Noclip", toggleNoclip)
btn("🛡️ God", toggleGod)
btn("🕷️ Spider", toggleSpider)
btn("🧱 Scaffold", toggleScaffold)
btn("⚡ Speed x2", function() setSpeed(2) end)
btn("⚡ Speed x3", function() setSpeed(3) end)
btn("🦘 Jump x2", function() setJump(2) end)
btn("🦘 Jump x3", function() setJump(3) end)
btn("🌫️ Туман", function() toggleVisual("atmos") end)
btn("☀️ Лучи", function() toggleVisual("sun") end)
btn("🎨 Цвет", function() toggleVisual("color") end)
btn("💡 Свечение", function() toggleVisual("bloom") end)
btn("📷 Размытие", function() toggleVisual("dof") end)
btn("☀️ День", function() Lighting.ClockTime = 14 end)
btn("🌆 Вечер", function() Lighting.ClockTime = 18 end)
btn("🌙 Ночь", function() Lighting.ClockTime = 0 end)
btn("🧹 Clear Parts", clearParts)
btn("📌 TP to bsjfcnjr", function() teleportTo("bsjfcnjr") end)
btn("🔄 Reset Speed/Jump", function() setSpeed(1); setJump(1) end)

-- Открытие по Insert
local open = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        open = not open
        frame.Visible = open
    end
end)

-- Хоткеи
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFly() end
    if input.KeyCode == Enum.KeyCode.N then toggleNoclip() end
    if input.KeyCode == Enum.KeyCode.G then toggleGod() end
    if input.KeyCode == Enum.KeyCode.S then toggleSpider() end
    if input.KeyCode == Enum.KeyCode.B then toggleScaffold() end
    if input.KeyCode == Enum.KeyCode.C then clearParts() end
end)

print("=== Flagman Simple загружен ===")
print("Insert — меню, WASD — полёт, F/N/G/S/B/C — хоткеи")
