-- Rufu MM2｜繁體中文介面
-- 懸浮按鈕會在外部 UI 函式庫載入前建立，避免載入失敗時按鈕一起消失。
local __Players = game:GetService("Players")
local __Input = game:GetService("UserInputService")
local __LocalPlayer = __Players.LocalPlayer
local __PlayerGui = __LocalPlayer:WaitForChild("PlayerGui")
local __OldFloat = __PlayerGui:FindFirstChild("RufuMM2FloatToggle")
if __OldFloat then __OldFloat:Destroy() end
local __FloatGui = Instance.new("ScreenGui")
__FloatGui.Name = "RufuMM2FloatToggle"
__FloatGui.ResetOnSpawn = false
__FloatGui.DisplayOrder = 2147483647
__FloatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
__FloatGui.Parent = __PlayerGui
local __FloatButton = Instance.new("ImageButton")
__FloatButton.Name = "中文懸浮開關"
__FloatButton.Size = UDim2.fromOffset(64, 64)
__FloatButton.Position = UDim2.new(0, 24, 0.5, -32)
__FloatButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
__FloatButton.BackgroundTransparency = 0.1
__FloatButton.Image = "rbxassetid://78147648126454"
__FloatButton.ScaleType = Enum.ScaleType.Crop
__FloatButton.AutoButtonColor = false
__FloatButton.Active = true
__FloatButton.Parent = __FloatGui
local __FloatCorner = Instance.new("UICorner")
__FloatCorner.CornerRadius = UDim.new(1, 0)
__FloatCorner.Parent = __FloatButton
local __FloatStroke = Instance.new("UIStroke")
__FloatStroke.Thickness = 2
__FloatStroke.Color = Color3.fromRGB(180, 80, 255)
__FloatStroke.Parent = __FloatButton
local __Dragging, __DragStart, __StartPosition = false, nil, nil
__FloatButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        __Dragging, __DragStart, __StartPosition = true, input.Position, __FloatButton.Position
    end
end)
__FloatButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then __Dragging = false end
end)
__Input.InputChanged:Connect(function(input)
    if not __Dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - __DragStart
    __FloatButton.Position = UDim2.new(__StartPosition.X.Scale, __StartPosition.X.Offset + delta.X, __StartPosition.Y.Scale, __StartPosition.Y.Offset + delta.Y)
end)

local Venyx = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Venyx-UI-Library/main/source2.lua"))()
local UI = Venyx.new({
    title = "Rufu MM2｜中文介面",
    theme = {
        Background = Color3.fromRGB(24, 24, 24),
        Glow = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(10, 10, 10),
        LightContrast = Color3.fromRGB(20, 20, 20),
        DarkContrast = Color3.fromRGB(14, 14, 14),
        TextColor = Color3.fromRGB(255, 255, 255)
    }
})

local __FloatToggleReady = false
__FloatButton.Activated:Connect(function()
    if not __FloatToggleReady then return end
    pcall(function() UI:toggle() end)
end)
__FloatToggleReady = true
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local PlayerPage = UI:addPage({ title = "玩家", icon = 7992557358 })
local MovementSection = PlayerPage:addSection({ title = "移動" })

local GravityValue = 196.2
local SpeedValue = 16
local JumpValue = 50

local function applyMovementSettings()
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = SpeedValue
            humanoid.JumpPower = JumpValue
        end
    end
    workspace.Gravity = GravityValue
end

MovementSection:addSlider({
    title = "重力",
    default = 196.2,
    min = 0,
    max = 500,
    callback = function(value)
        GravityValue = value
        workspace.Gravity = GravityValue
    end
})

MovementSection:addSlider({
    title = "行走速度",
    default = 16,
    min = 0,
    max = 100,
    callback = function(value)
        SpeedValue = value
        applyMovementSettings()
    end
})

MovementSection:addSlider({
    title = "跳躍力度",
    default = 50,
    min = 0,
    max = 200,
    callback = function(value)
        JumpValue = value
        applyMovementSettings()
    end
})

player.CharacterAdded:Connect(function()
    wait(0.5)
    applyMovementSettings()
end)
applyMovementSettings()

local BoostSection = PlayerPage:addSection({ title = "跳躍加速" })

local boostEnabled = false
local boostSpeed = 75
local boostListener = nil
local originalSpeed = 16
local isBoosting = false
local boostHeartbeat = nil

local function setupBoostListener()
    if boostListener then 
        boostListener:Disconnect() 
        boostListener = nil 
    end
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    boostListener = humanoid.Jumping:Connect(function()
        if not boostEnabled then return end
        if isBoosting then return end
        
        isBoosting = true
        originalSpeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = boostSpeed
    end)
end

local function startBoostHeartbeat()
    if boostHeartbeat then return end
    boostHeartbeat = runService.Heartbeat:Connect(function()
        if not boostEnabled then return end
        if not isBoosting then return end
        
        local char = player.Character
        if not char then return end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not rootPart then return end
        
        local velocity = rootPart.AssemblyLinearVelocity
        if humanoid.FloorMaterial ~= Enum.Material.Air and math.abs(velocity.Y) < 0.5 then
            humanoid.WalkSpeed = originalSpeed
            isBoosting = false
        end
    end)
end

local function stopBoostHeartbeat()
    if boostHeartbeat then
        boostHeartbeat:Disconnect()
        boostHeartbeat = nil
    end
end

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    isBoosting = false
    originalSpeed = 16
    if boostEnabled then
        setupBoostListener()
        startBoostHeartbeat()
    end
end)

BoostSection:addToggle({
    title = "跳躍時加速（75 速度）",
    callback = function(value)
        boostEnabled = value
        if value then
            setupBoostListener()
            startBoostHeartbeat()
        else
            if boostListener then 
                boostListener:Disconnect() 
                boostListener = nil 
            end
            stopBoostHeartbeat()
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and isBoosting then
                    hum.WalkSpeed = originalSpeed
                    isBoosting = false
                end
            end
        end
    end
})

task.wait(1)
if boostEnabled then
    setupBoostListener()
    startBoostHeartbeat()
end

local CombatPage = UI:addPage({ title = "戰鬥", icon = 6187718252 })
local ESPSection = CombatPage:addSection({ title = "透視設定" })

local ESPEnabled = true
local showGun = true
local showKnife = true
local showNone = true
local GunColor = Color3.fromRGB(0, 100, 255)
local KnifeColor = Color3.fromRGB(255, 0, 0)
local NoneColor = Color3.fromRGB(0, 255, 0)
local FillTransparency = 0.5
local OutlineTransparency = 0.2

ESPSection:addToggle({
    title = "啟用透視",
    default = true,
    callback = function(value)
        ESPEnabled = value
        if not ESPEnabled then clearAllESP() else updateESP() end
    end
})

ESPSection:addToggle({
    title = "顯示槍枝玩家",
    default = true,
    callback = function(value)
        showGun = value
        updateESP()
    end
})

ESPSection:addToggle({
    title = "顯示小刀玩家",
    default = true,
    callback = function(value)
        showKnife = value
        updateESP()
    end
})

ESPSection:addToggle({
    title = "顯示無武器玩家",
    default = true,
    callback = function(value)
        showNone = value
        updateESP()
    end
})

ESPSection:addColorPicker({
    title = "槍枝顏色",
    default = GunColor,
    callback = function(color)
        GunColor = color
        updateESP()
    end
})

ESPSection:addColorPicker({
    title = "小刀顏色",
    default = KnifeColor,
    callback = function(color)
        KnifeColor = color
        updateESP()
    end
})

ESPSection:addColorPicker({
    title = "無武器顏色",
    default = NoneColor,
    callback = function(color)
        NoneColor = color
        updateESP()
    end
})

ESPSection:addSlider({
    title = "填充透明度（％）",
    default = 50,
    min = 0,
    max = 100,
    callback = function(value)
        FillTransparency = value / 100
        updateESP()
    end
})

ESPSection:addSlider({
    title = "外框透明度（％）",
    default = 20,
    min = 0,
    max = 100,
    callback = function(value)
        OutlineTransparency = value / 100
        updateESP()
    end
})

local weaponCache = {}
local espObjects = {}
local espScreenGui = Instance.new("ScreenGui")
espScreenGui.Name = "ESPScreenGui"
espScreenGui.Parent = player.PlayerGui

local function updateWeaponCacheForPlayer(plr)
    if plr == player then weaponCache[plr] = nil return end
    local found = nil
    local backpack = plr:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local name = string.lower(item.Name)
                if string.find(name, "gun") then found = "Gun" break
                elseif string.find(name, "knife") then found = "Knife" break end
            end
        end
    end
    if not found and plr.Character then
        for _, item in ipairs(plr.Character:GetChildren()) do
            if item:IsA("Tool") then
                local name = string.lower(item.Name)
                if string.find(name, "gun") then found = "Gun" break
                elseif string.find(name, "knife") then found = "Knife" break end
            end
        end
    end
    weaponCache[plr] = found
end

local function refreshAllCache()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        updateWeaponCacheForPlayer(plr)
    end
end

local function getPlayerInfo(plr)
    local itemType = weaponCache[plr]
    if itemType == "Gun" then
        return GunColor, plr.Name .. " [槍枝]", "Gun"
    elseif itemType == "Knife" then
        return KnifeColor, plr.Name .. " [小刀]", "Knife"
    else
        return NoneColor, plr.Name .. " [無武器]", "None"
    end
end

local function createESPForPlayer(plr)
    if espObjects[plr] then
        if espObjects[plr].Highlight then espObjects[plr].Highlight:Destroy() end
        if espObjects[plr].Frame then espObjects[plr].Frame:Destroy() end
        espObjects[plr] = nil
    end
    if not plr.Character then return end

    local color, displayText, itemType = getPlayerInfo(plr)
    if (itemType == "Gun" and not showGun) or
       (itemType == "Knife" and not showKnife) or
       (itemType == "None" and not showNone) then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Parent = plr.Character
    highlight.FillColor = color
    highlight.FillTransparency = FillTransparency
    highlight.OutlineColor = color
    highlight.OutlineTransparency = OutlineTransparency
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = espScreenGui

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = displayText
    text.TextColor3 = color
    text.TextSize = 16
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0.3
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.Parent = frame

    espObjects[plr] = { Highlight = highlight, Frame = frame }
end

local function removeESPForPlayer(plr)
    if espObjects[plr] then
        if espObjects[plr].Highlight then espObjects[plr].Highlight:Destroy() end
        if espObjects[plr].Frame then espObjects[plr].Frame:Destroy() end
        espObjects[plr] = nil
    end
end

local function clearAllESP()
    for plr, data in pairs(espObjects) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Frame then data.Frame:Destroy() end
    end
    espObjects = {}
    weaponCache = {}
end

function updateESP()
    if not ESPEnabled then clearAllESP() return end
    refreshAllCache()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            if not plr.Character then
                if espObjects[plr] then removeESPForPlayer(plr) end
            else
                local _, _, itemType = getPlayerInfo(plr)
                local shouldShow = true
                if (itemType == "Gun" and not showGun) or
                   (itemType == "Knife" and not showKnife) or
                   (itemType == "None" and not showNone) then
                    shouldShow = false
                end
                if shouldShow then
                    if not espObjects[plr] then
                        createESPForPlayer(plr)
                    else
                        local oldColor = espObjects[plr].Highlight.FillColor
                        local newColor, _ = getPlayerInfo(plr)
                        if oldColor ~= newColor then
                            createESPForPlayer(plr)
                        end
                        if espObjects[plr] then
                            espObjects[plr].Highlight.FillTransparency = FillTransparency
                            espObjects[plr].Highlight.OutlineTransparency = OutlineTransparency
                        end
                    end
                else
                    if espObjects[plr] then
                        removeESPForPlayer(plr)
                    end
                end
            end
        end
    end
    for plr, _ in pairs(espObjects) do
        if not game.Players:FindFirstChild(plr.Name) then removeESPForPlayer(plr) end
    end
end

runService.RenderStepped:Connect(function()
    if not ESPEnabled then return end
    for plr, data in pairs(espObjects) do
        local frame = data.Frame
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local headPos = root.Position + Vector3.new(0, 3.5, 0)
            local screenPos, onScreen = camera:WorldToScreenPoint(headPos)
            if onScreen then
                frame.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - 15)
                frame.Visible = true
            else
                frame.Visible = false
            end
        else
            frame.Visible = false
        end
    end
end)

local function espMainLoop()
    while true do wait(0.5) updateESP() end
end
coroutine.wrap(espMainLoop)()

game.Players.PlayerAdded:Connect(function(newPlayer)
    wait(0.2)
    updateESP()
    newPlayer.CharacterAdded:Connect(function()
        wait(0.3)
        if espObjects[newPlayer] then
            createESPForPlayer(newPlayer)
        else
            updateESP()
        end
    end)
end)

game.Players.PlayerRemoving:Connect(function(removedPlayer)
    removeESPForPlayer(removedPlayer)
    weaponCache[removedPlayer] = nil
end)

player.CharacterAdded:Connect(function()
    wait(0.3)
    updateESP()
end)

for _, plr in ipairs(game.Players:GetPlayers()) do
    if plr ~= player then
        plr.CharacterAdded:Connect(function()
            wait(0.3)
            if espObjects[plr] then
                createESPForPlayer(plr)
            else
                updateESP()
            end
        end)
    end
end

local GunDropSection = CombatPage:addSection({ title = "槍枝掉落透視" })

local gunDropEnabled = false
local gunDropColor = Color3.fromRGB(0, 200, 255)
local gunDropObjects = {}
local gunDropListener = nil
local gunDropScreenGui = nil

local function isGunDrop(instance)
    if not instance then return false end
    local name = string.lower(instance.Name)
    return string.find(name, "gundrop") or string.find(name, "drop")
end

local function getGunDropPosition(instance)
    local primary = instance:FindFirstChild("PrimaryPart")
    if primary then return primary.Position end
    local part = instance:FindFirstChildOfClass("BasePart")
    if part then return part.Position end
    if instance:IsA("BasePart") then return instance.Position end
    for _, child in ipairs(instance:GetChildren()) do
        if child:IsA("BasePart") then
            return child.Position
        end
    end
    return nil
end

local function createGunDropESP(instance)
    if gunDropObjects[instance] then return end
    if not instance or not instance.Parent then return end

    local pos = getGunDropPosition(instance)
    if not pos then return end

    if not gunDropScreenGui then
        gunDropScreenGui = Instance.new("ScreenGui")
        gunDropScreenGui.Name = "GunDropESP_Overlay"
        gunDropScreenGui.Parent = player.PlayerGui
        gunDropScreenGui.ResetOnSpawn = false
    end

    local highlight = Instance.new("Highlight")
    highlight.Parent = instance
    highlight.FillColor = gunDropColor
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = gunDropColor
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 150, 0, 25)
    frame.BackgroundTransparency = 1
    frame.Parent = gunDropScreenGui

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "槍枝掉落"
    text.TextColor3 = gunDropColor
    text.TextSize = 14
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0.3
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.Parent = frame

    gunDropObjects[instance] = { Highlight = highlight, Frame = frame }

    instance.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            if gunDropObjects[instance] then
                local data = gunDropObjects[instance]
                if data.Highlight then data.Highlight:Destroy() end
                if data.Frame then data.Frame:Destroy() end
                gunDropObjects[instance] = nil
            end
        end
    end)
end

local function scanGunDrops()
    if not gunDropEnabled then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isGunDrop(obj) then
            createGunDropESP(obj)
        end
    end
end

local function startGunDropListener()
    if gunDropListener then return end
    gunDropListener = workspace.DescendantAdded:Connect(function(obj)
        if gunDropEnabled and isGunDrop(obj) then
            createGunDropESP(obj)
        end
    end)
end

local function stopGunDropListener()
    if gunDropListener then
        gunDropListener:Disconnect()
        gunDropListener = nil
    end
end

local function clearGunDropESP()
    for obj, data in pairs(gunDropObjects) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Frame then data.Frame:Destroy() end
    end
    gunDropObjects = {}
    if gunDropScreenGui then
        gunDropScreenGui:Destroy()
        gunDropScreenGui = nil
    end
end

GunDropSection:addToggle({
    title = "啟用槍枝掉落透視",
    callback = function(value)
        gunDropEnabled = value
        if value then
            scanGunDrops()
            startGunDropListener()
        else
            clearGunDropESP()
            stopGunDropListener()
        end
    end
})

GunDropSection:addColorPicker({
    title = "槍枝掉落顏色",
    default = gunDropColor,
    callback = function(color)
        gunDropColor = color
        for obj, data in pairs(gunDropObjects) do
            if data.Highlight then
                data.Highlight.FillColor = gunDropColor
                data.Highlight.OutlineColor = gunDropColor
            end
            if data.Frame and data.Frame:FindFirstChildOfClass("TextLabel") then
                data.Frame:FindFirstChildOfClass("TextLabel").TextColor3 = gunDropColor
            end
        end
    end
})

local function teleportToGunDropAndBack()
    local foundObjects = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isGunDrop(obj) then
            table.insert(foundObjects, obj)
        end
    end
    if #foundObjects == 0 then
        UI:Notify({ title = "槍枝掉落", text = "找不到槍枝掉落！", duration = 2 })
        return
    end
    local targetObj = foundObjects[1]
    local targetPos = getGunDropPosition(targetObj)
    if not targetPos then
        UI:Notify({ title = "槍枝掉落", text = "槍枝掉落沒有有效部件！", duration = 2 })
        return
    end
    local char = player.Character
    if not char then
        UI:Notify({ title = "槍枝掉落", text = "你的角色尚未準備完成！", duration = 2 })
        return
    end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        UI:Notify({ title = "槍枝掉落", text = "找不到角色核心部件！", duration = 2 })
        return
    end
    local originalCF = rootPart.CFrame
    rootPart.CFrame = CFrame.new(targetPos)
    task.wait(0.05)
    rootPart.CFrame = originalCF
    UI:Notify({ title = "槍枝掉落", text = "快速傳送完成！", duration = 1 })
end

GunDropSection:addButton({
    title = "快速傳送到槍枝掉落並返回",
    callback = teleportToGunDropAndBack
})

local function updateGunDropPositions()
    if not gunDropEnabled then return end
    for obj, data in pairs(gunDropObjects) do
        local frame = data.Frame
        if not frame then continue end
        if not obj or not obj.Parent then
            frame.Visible = false
            continue
        end
        local pos = getGunDropPosition(obj)
        if not pos then
            frame.Visible = false
            continue
        end
        local screenPos, onScreen = camera:WorldToScreenPoint(pos)
        if onScreen then
            frame.Position = UDim2.new(0, screenPos.X - 75, 0, screenPos.Y - 15)
            frame.Visible = true
        else
            frame.Visible = false
        end
    end
end

runService.RenderStepped:Connect(updateGunDropPositions)

local AimbotSection = CombatPage:addSection({ title = "瞄準輔助設定" })

local aimbotEnabled = false
local aimSmoothness = 0.3
local aimbotConnection = nil

local function hasKnife(plr)
    if plr == player then return false end
    local char = plr.Character
    if not char then return false end
    
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and string.find(string.lower(item.Name), "knife") then
            return true
        end
    end
    
    local backpack = plr:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and string.find(string.lower(item.Name), "knife") then
                return true
            end
        end
    end
    return false
end

local function getClosestKnifePlayer()
    local closest = nil
    local closestDist = math.huge
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and hasKnife(plr) then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local pos = hrp.Position
                    local screenPos, onScreen = camera:WorldToScreenPoint(pos)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = pos
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function aimbotLoop()
    if not aimbotEnabled then return end
    local target = getClosestKnifePlayer()
    if target then
        local currentCF = camera.CFrame
        local targetCF = CFrame.lookAt(currentCF.Position, target)
        camera.CFrame = currentCF:Lerp(targetCF, aimSmoothness)
    end
end

local function startAimbot()
    if aimbotConnection then 
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    aimbotConnection = runService.Heartbeat:Connect(aimbotLoop)
end

local function stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        startAimbot()
    else
        stopAimbot()
    end
end

AimbotSection:addToggle({
    title = "啟用瞄準輔助（按 E）",
    callback = function(value)
        aimbotEnabled = value
        if value then
            startAimbot()
        else
            stopAimbot()
        end
    end
})

AimbotSection:addSlider({
    title = "平滑度",
    default = 0.3,
    min = 0.05,
    max = 1,
    callback = function(value)
        aimSmoothness = value
    end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        toggleAimbot()
    end
end)

local VisualsPage = UI:addPage({ title = "視覺", icon = 15330618083 })
local CursorSection = VisualsPage:addSection({ title = "游標" })

local cursorEnabled = false
local defaultIcon = player:GetMouse().Icon

CursorSection:addToggle({
    title = "自訂游標",
    callback = function(value)
        cursorEnabled = value
        player:GetMouse().Icon = value and "rbxassetid://11232270732" or defaultIcon
    end
})

local EffectsSection = VisualsPage:addSection({ title = "移除特效" })

local effectsEnabled = false
local effectsConnection = nil

local function removeAllEffects()
    local lighting = game:GetService("Lighting")
    for _, child in ipairs(lighting:GetChildren()) do
        if child:IsA("Atmosphere") or child:IsA("BloomEffect") or child:IsA("ColorCorrectionEffect") or
           child:IsA("SunRaysEffect") or child:IsA("DepthOfFieldEffect") or child:IsA("BlurEffect") then
            pcall(function() child:Destroy() end)
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or
           obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Attachment") then
            pcall(function() obj:Destroy() end)
        end
    end
end

local function startCleanup()
    if effectsConnection then return end
    removeAllEffects()
    effectsConnection = workspace.DescendantAdded:Connect(function(obj)
        if effectsEnabled then
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or
               obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Attachment") then
                pcall(function() obj:Destroy() end)
            end
        end
    end)
end

local function stopCleanup()
    if effectsConnection then
        effectsConnection:Disconnect()
        effectsConnection = nil
    end
end

EffectsSection:addToggle({
    title = "移除所有特效",
    callback = function(value)
        effectsEnabled = value
        if value then startCleanup() else stopCleanup() end
    end
})

local FogSection = VisualsPage:addSection({ title = "霧效" })

local fogEnabled = false
local fogEnd = 500
local fogColor = Color3.fromRGB(140, 60, 200)
local fogHeartbeat = nil

local function applyFog()
    local lighting = game:GetService("Lighting")
    if fogEnabled then
        lighting.FogEnd = fogEnd
        lighting.FogStart = 0
        lighting.Brightness = 0.8
        lighting.FogColor = fogColor
    else
        lighting.FogEnd = 1000
        lighting.FogStart = 0
        lighting.Brightness = 1
        lighting.FogColor = Color3.fromRGB(255, 255, 255)
    end
end

local function startFogLoop()
    if fogHeartbeat then return end
    fogHeartbeat = runService.Heartbeat:Connect(function()
        if fogEnabled then
            local lighting = game:GetService("Lighting")
            lighting.FogColor = fogColor
            lighting.FogEnd = fogEnd
        end
    end)
end

local function stopFogLoop()
    if fogHeartbeat then
        fogHeartbeat:Disconnect()
        fogHeartbeat = nil
    end
end

FogSection:addToggle({
    title = "啟用霧效",
    callback = function(value)
        fogEnabled = value
        if value then
            applyFog()
            startFogLoop()
        else
            stopFogLoop()
            applyFog()
        end
    end
})

FogSection:addSlider({
    title = "霧效距離",
    default = 500,
    min = 100,
    max = 2000,
    callback = function(value)
        fogEnd = value
        if fogEnabled then game:GetService("Lighting").FogEnd = fogEnd end
    end
})

FogSection:addColorPicker({
    title = "霧效顏色",
    default = fogColor,
    callback = function(color)
        fogColor = color
        if fogEnabled then game:GetService("Lighting").FogColor = fogColor end
    end
})

local TransSection = VisualsPage:addSection({ title = "透明度" })

local transEnabled = false
local selfTrans = 0.5
local otherTrans = 0.8
local transConnections = {}

local function applyTransToChar(char, trans)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = trans
        end
    end
    local conn = char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = trans
        end
    end)
    return conn
end

local function applyAllTrans()
    if not transEnabled then
        for _, plr in ipairs(game.Players:GetPlayers()) do
            local c = plr.Character
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                        p.Transparency = 0
                    end
                end
            end
        end
        return
    end
    for _, plr in ipairs(game.Players:GetPlayers()) do
        local c = plr.Character
        if c then
            local t = (plr == player) and selfTrans or otherTrans
            applyTransToChar(c, t)
        end
    end
end

local function setupTransListeners()
    for _, conn in ipairs(transConnections) do conn:Disconnect() end
    transConnections = {}
    local function onPlayerAdded(plr)
        local function onCharAdded(char)
            if transEnabled then
                local t = (plr == player) and selfTrans or otherTrans
                local conn = applyTransToChar(char, t)
                table.insert(transConnections, conn)
            end
        end
        if plr.Character then onCharAdded(plr.Character) end
        local conn = plr.CharacterAdded:Connect(onCharAdded)
        table.insert(transConnections, conn)
    end
    for _, plr in ipairs(game.Players:GetPlayers()) do onPlayerAdded(plr) end
    local conn = game.Players.PlayerAdded:Connect(onPlayerAdded)
    table.insert(transConnections, conn)
end

TransSection:addToggle({
    title = "啟用透明度",
    callback = function(value)
        transEnabled = value
        if value then
            setupTransListeners()
            applyAllTrans()
        else
            for _, conn in ipairs(transConnections) do conn:Disconnect() end
            transConnections = {}
            applyAllTrans()
        end
    end
})

TransSection:addSlider({
    title = "自身透明度（％）",
    default = 50,
    min = 0,
    max = 100,
    callback = function(value)
        selfTrans = value / 100
        if transEnabled then applyAllTrans() end
    end
})

TransSection:addSlider({
    title = "其他玩家透明度（％）",
    default = 80,
    min = 0,
    max = 100,
    callback = function(value)
        otherTrans = value / 100
        if transEnabled then applyAllTrans() end
    end
})

local CameraSection = VisualsPage:addSection({ title = "相機" })

CameraSection:addSlider({
    title = "視野角度（FOV）",
    default = 70,
    min = 1,
    max = 120,
    callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end
})

local MonoSection = VisualsPage:addSection({ title = "單色模式" })

local monochromeEnabled = false
local monochromeData = {}
local monochromeListener = nil

local function isPartPartOfPlayer(part)
    local model = part:FindFirstAncestorOfClass("Model")
    if model and game.Players:GetPlayerFromCharacter(model) then
        return true
    end
    return false
end

local function rgbToDarkGray(color)
    local gray = (color.R + color.G + color.B) / 3
    local dark = gray * 0.25
    return Color3.new(dark, dark, dark)
end

local function applyMonochromeToPart(part)
    if not part:IsA("BasePart") then return end
    if isPartPartOfPlayer(part) then return end
    if not monochromeData[part] then
        monochromeData[part] = {
            Color = part.Color,
            Material = part.Material
        }
    end
    local darkColor = rgbToDarkGray(part.Color)
    part.Color = darkColor
    part.Material = Enum.Material.Plastic
end

local function restorePart(part)
    if monochromeData[part] then
        part.Color = monochromeData[part].Color
        part.Material = monochromeData[part].Material
        monochromeData[part] = nil
    end
end

local function applyMonochromeToAll()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            applyMonochromeToPart(obj)
        end
    end
end

local function restoreAll()
    for part, data in pairs(monochromeData) do
        if part and part.Parent then
            part.Color = data.Color
            part.Material = data.Material
        end
    end
    monochromeData = {}
end

local function toggleMonochrome(value)
    monochromeEnabled = value
    if value then
        applyMonochromeToAll()
        if monochromeListener then monochromeListener:Disconnect() end
        monochromeListener = workspace.DescendantAdded:Connect(function(obj)
            if monochromeEnabled and obj:IsA("BasePart") and not isPartPartOfPlayer(obj) then
                applyMonochromeToPart(obj)
            end
        end)
    else
        if monochromeListener then
            monochromeListener:Disconnect()
            monochromeListener = nil
        end
        restoreAll()
    end
end

MonoSection:addToggle({
    title = "啟用單色模式（深灰／黑色）",
    callback = function(value)
        toggleMonochrome(value)
    end
})

task.wait(0.2)

updateESP()
applyMovementSettings()

if transEnabled then applyAllTrans() end
if monochromeEnabled then toggleMonochrome(true) end
if fogEnabled then applyFog(); startFogLoop() end
if effectsEnabled then startCleanup() end
if cursorEnabled then player:GetMouse().Icon = "rbxassetid://11232270732" end
if aimbotEnabled then startAimbot() end
if gunDropEnabled then
    scanGunDrops()
    startGunDropListener()
end
