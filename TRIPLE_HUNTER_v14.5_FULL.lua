print("🌶️🥤🤠☕️✨📝😂☢️⛏️🌟🐱 TRIPLE+ HUNTER v14.6 - MINI UI + 11 TARGETS + RADIOACTIVE!")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = workspace
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local head = character:WaitForChild("Head")

-- PATHS
local spawnRemote = ReplicatedStorage["shared/network@GlobalFunctions"].SpawnEggs
local collectPenRemote = ReplicatedStorage["shared/network@GlobalFunctions"].CollectPenEarnings
local conveyor = Workspace.Farms.Mhazrll.Components.Conveyor
local pensFolder = Workspace.Farms.Mhazrll.Components.Pens

-- TARGET MODELS - 11 TARGETS
local targets = {
    {model = ReplicatedStorage.Assets.Models.Eggs:WaitForChild("05Secret").chili, name="chili", emoji="🌶️", color=Color3.new(1,0.3,0)},
    {model = ReplicatedStorage.Assets.Models.Eggs:WaitForChild("05Secret").soda, name="soda", emoji="🥤", color=Color3.new(0,0.8,1)},
    {model = ReplicatedStorage.Assets.Models.Eggs:WaitForChild("05Secret").bandito, name="bandito", emoji="🤠", color=Color3.new(1,0.8,0)},
    {model = ReplicatedStorage.Assets.Models.Eggs:WaitForChild("06Divine").espresso, name="espresso", emoji="☕️", color=Color3.new(0.6,0.4,0.2)},
    {model = ReplicatedStorage.Assets.Models.Eggs:WaitForChild("06Divine").tung, name="tung", emoji="✨", color=Color3.new(0.8,0.2,1)},
    {model = ReplicatedStorage.Assets.Models.Eggs:WaitForChild("05Secret").pencil, name="pencil", emoji="📝", color=Color3.new(0.2,0.6,0.8)},
    {model = ReplicatedStorage.Assets.Models.Eggs:WaitForChild("05Secret").lololo, name="lololo", emoji="😂", color=Color3.new(1,0.5,0.8)},
    {model = ReplicatedStorage.Assets.Models.Eggs:WaitForChild("05Secret").nuclear, name="nuclear", emoji="☢️", color=Color3.new(0.8,0.2,0.2)},
    {model = ReplicatedStorage.Assets.Models.Eggs:WaitForChild("05Secret").shovel, name="shovel", emoji="⛏️", color=Color3.new(0.6,0.5,0.3)},
    {model = ReplicatedStorage.Assets.Models.Eggs:WaitForChild("06Divine").wl, name="wl", emoji="🌟", color=Color3.new(0.3,0.8,1)},
    {model = ReplicatedStorage.Assets.Models.Eggs:WaitForChild("06Divine").meowl, name="meowl", emoji="🐱", color=Color3.new(0.9,0.7,0.8)}
}

print("✅ " .. #targets .. " Targets + AUTO PENS + RADIOACTIVE - MINI UI MODE!")

-- STATE
local hunting = false
local autoPens = false
local eggsSpawned = 0
local pensCollected = 0
local isMinimized = false
local screenGui, mainFrame, miniFrame, bubbleGui = nil, nil, nil, nil
local spawnThread, monitorConnection, penThread = nil, nil, nil
local lastCheck = 0
local CHECK_INTERVAL = 0.1
local PEN_COLLECT_INTERVAL = 5

-- VFX CHECK - UPDATED WITH RADIOACTIVE, NO GOLD
local function checkVFXFast(targetName)
    for i = 1, 10 do
        local slot = conveyor.Objects:FindFirstChild(tostring(i))
        if slot and slot:FindFirstChild(targetName) then
            local egg = slot[targetName]
            if egg:FindFirstChild("tier-vfx-Radioactive") then return "RADIOACTIVE"  -- NEW!
            elseif egg:FindFirstChild("tier-vfx-Diamond") then return "DIAMOND"
            elseif egg:FindFirstChild("tier-vfx-Rainbow") then return "RAINBOW"
            -- GOLD REMOVED AS REQUESTED
            end
        end
    end
    return nil
end

-- AUTO PENS
local function collectPens()
    pcall(function()
        for i = 1, 82 do
            local penSlot = pensFolder:FindFirstChild(tostring(i))
            if penSlot and penSlot:FindFirstChild("PenComponent") then
                collectPenRemote:FireServer(82, penSlot.PenComponent)
            end
        end
        pensCollected = pensCollected + 82
    end)
end

-- BUBBLE
local function showBubble(text, duration, color)
    if bubbleGui then bubbleGui:Destroy() end
    bubbleGui = Instance.new("BillboardGui")
    bubbleGui.Name = "HunterBubble"
    bubbleGui.Size = UDim2.new(5, 0, 1.5, 0)
    bubbleGui.StudsOffset = Vector3.new(0, 3, 0)
    bubbleGui.Parent = head
    
    local bubbleFrame = Instance.new("Frame")
    bubbleFrame.Size = UDim2.new(1, 0, 0.6, 0)
    bubbleFrame.BackgroundColor3 = color or Color3.new(0.1, 0.1, 0.15)
    bubbleFrame.BorderSizePixel = 0
    bubbleFrame.Parent = bubbleGui
    
    Instance.new("UICorner", bubbleFrame).CornerRadius = UDim.new(0, 10)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -8, 1, -8)
    textLabel.Position = UDim2.new(0, 4, 0, 4)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = bubbleFrame
    
    task.delay(duration or 2.5, function()
        if bubbleGui then
            TweenService:Create(bubbleFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(textLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            task.wait(0.3)
            bubbleGui:Destroy()
            bubbleGui = nil
        end
    end)
end

-- TOGGLE MINI
local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(1, -80, 1, -80)
        }):Play()
        task.wait(0.3)
        mainFrame.Visible = false
        miniFrame.Visible = true
        TweenService:Create(miniFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 100, 0, 100)}):Play()
    else
        TweenService:Create(miniFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.2)
        miniFrame.Visible = false
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 320, 0, 380), Position = UDim2.new(0.5, -160, 0.5, -190)
        }):Play()
    end
end

-- CREATE MINI UI
local function createUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TripleHunterV146Mini"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- MAIN FRAME - MINI SIZE 320x380
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
    mainFrame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.12)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    -- TOP BUTTONS
    local minimizeBtn = Instance.new("TextButton", mainFrame)
    minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    minimizeBtn.Position = UDim2.new(1, -55, 0, 3)
    minimizeBtn.BackgroundColor3 = Color3.new(0.3, 0.5, 0.9)
    minimizeBtn.Text = "➖"
    minimizeBtn.TextColor3 = Color3.new(1,1,1)
    minimizeBtn.TextScaled = true
    minimizeBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)
    minimizeBtn.MouseButton1Click:Connect(toggleMinimize)

    local closeBtn = Instance.new("TextButton", mainFrame)
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -27, 0, 3)
    closeBtn.BackgroundColor3 = Color3.new(0.9, 0.2, 0.1)
    closeBtn.Text = "❌"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

    -- TITLE - UPDATED VERSION
    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1, -60, 0, 30)
    title.Position = UDim2.new(0, 8, 0, 2)
    title.BackgroundTransparency = 1
    title.Text = "🌶️🥤🤠☕️✨📝😂☢️☢️ v14.6 RADIOACTIVE"
    title.TextColor3 = Color3.new(1, 0.3, 0)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- STATUS
    local status = Instance.new("TextLabel", mainFrame)
    status.Size = UDim2.new(1, -16, 0, 22)
    status.Position = UDim2.new(0, 8, 0, 35)
    status.BackgroundTransparency = 1
    status.Text = "READY | Eggs: 0 | Pens: 0"
    status.TextColor3 = Color3.new(0, 1, 0)
    status.TextScaled = true
    status.Font = Enum.Font.Gotham

    -- MINI SCROLL TARGETS
    local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
    scrollFrame.Size = UDim2.new(1, -16, 0, 140)
    scrollFrame.Position = UDim2.new(0, 8, 0, 60)
    scrollFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.08)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 8)
    
    for i, target in ipairs(targets) do
        local yPos = (i-1) * 18
        local targetLabel = Instance.new("TextLabel", scrollFrame)
        targetLabel.Size = UDim2.new(1, -8, 0, 16)
        targetLabel.Position = UDim2.new(0, 4, 0, yPos)
        targetLabel.BackgroundColor3 = target.color
        targetLabel.Text = target.emoji .. " " .. target.name:sub(1,4):upper()
        targetLabel.TextScaled = true
        targetLabel.Font = Enum.Font.Code
        targetLabel.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", targetLabel).CornerRadius = UDim.new(0, 4)
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #targets * 18)

    -- LIVE SCAN
    local liveScan = Instance.new("TextLabel", mainFrame)
    liveScan.Size = UDim2.new(1, -16, 0, 18)
    liveScan.Position = UDim2.new(0, 8, 0, 205)
    liveScan.BackgroundTransparency = 1
    liveScan.Text = "Radioactive Scan Ready..."
    liveScan.TextColor3 = Color3.new(1, 1, 0)
    liveScan.TextScaled = true
    liveScan.Font = Enum.Font.Gotham

    -- PENS STATUS
    local pensLabel = Instance.new("TextLabel", mainFrame)
    pensLabel.Size = UDim2.new(1, -16, 0, 20)
    pensLabel.Position = UDim2.new(0, 8, 0, 228)
    pensLabel.BackgroundColor3 = Color3.new(0.2, 0.8, 0.4)
    pensLabel.Text = "🖊️ PENS: OFF | 0"
    pensLabel.TextColor3 = Color3.new(1,1,1)
    pensLabel.TextScaled = true
    pensLabel.Font = Enum.Font.GothamBold
    Instance.new("UICorner", pensLabel).CornerRadius = UDim.new(0, 6)

    -- HUNT BUTTON
    local huntBtn = Instance.new("TextButton", mainFrame)
    huntBtn.Size = UDim2.new(1, -16, 0, 38)
    huntBtn.Position = UDim2.new(0, 8, 0, 252)
    huntBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
    huntBtn.Text = "🔥 START " .. #targets .. " HUNT"
    huntBtn.TextColor3 = Color3.new(1,1,1)
    huntBtn.TextScaled = true
    huntBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", huntBtn).CornerRadius = UDim.new(0, 8)

    -- PENS BUTTON
    local pensBtn = Instance.new("TextButton", mainFrame)
    pensBtn.Size = UDim2.new(1, -16, 0, 38)
    pensBtn.Position = UDim2.new(0, 8, 0, 295)
    pensBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
    pensBtn.Text = "🖊️ AUTO PENS (82)"
    pensBtn.TextColor3 = Color3.new(1,1,1)
    pensBtn.TextScaled = true
    pensBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", pensBtn).CornerRadius = UDim.new(0, 8)

    -- MINI FRAME
    miniFrame = Instance.new("Frame", screenGui)
    miniFrame.Size = UDim2.new(0, 0, 0, 0)
    miniFrame.Position = UDim2.new(1, -110, 1, -110)
    miniFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    miniFrame.Visible = false
    Instance.new("UICorner", miniFrame).CornerRadius = UDim.new(0, 16)

    local miniIcon = Instance.new("TextLabel", miniFrame)
    miniIcon.Size = UDim2.new(1, 0, 0.6, 0)
    miniIcon.BackgroundTransparency = 1
    miniIcon.Text = "🌶️🤠☢️🐱"
    miniIcon.TextColor3 = Color3.new(1,1,1)
    miniIcon.TextScaled = true
    miniIcon.Font = Enum.Font.GothamBold

    local miniBtn = Instance.new("TextButton", miniFrame)
    miniBtn.Size = UDim2.new(1, 0, 0.4, 0)
    miniBtn.Position = UDim2.new(0, 0, 0.6, 0)
    miniBtn.BackgroundTransparency = 1
    miniBtn.Text = "OPEN"
    miniBtn.TextColor3 = Color3.new(0, 1, 0)
    miniBtn.TextScaled = true
    miniBtn.Font = Enum.Font.GothamBold
    miniBtn.MouseButton1Click:Connect(toggleMinimize)

    -- HUNT LOGIC
    local function checkForTargetFast()
        for _, target in ipairs(targets) do
            local vfxTier = checkVFXFast(target.name)
            if vfxTier then
                print("✨ " .. target.name:upper() .. " " .. vfxTier .. "!")
                return target.name, vfxTier, target.emoji, target.color
            end
        end
        if tick() - lastCheck > 1 then
            lastCheck = tick()
            for _, target in ipairs(targets) do
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:FindFirstChild(target.name) and (obj.Name:find("Secret") or obj.Name:find("Divine")) then
                        return target.name, "SECRET", target.emoji, target.color
                    end
                end
            end
        end
        return nil, nil, nil, nil
    end

    local function spawnEgg()
        pcall(function()
            spawnRemote:FireServer(2, conveyor)
            eggsSpawned = eggsSpawned + 1
        end)
    end

    -- HUNT BUTTON EVENT
    huntBtn.MouseButton1Click:Connect(function()
        hunting = not hunting
        if hunting then
            eggsSpawned = 0
            status.Text = #targets .. "H ACTIVE"
            status.TextColor3 = Color3.new(1, 1, 0)
            huntBtn.Text = "⏹ STOP"
            huntBtn.BackgroundColor3 = Color3.new(0.9, 0.2, 0.1)
            showBubble("🚀 " .. #targets .. " RADIOACTIVE HUNT!", 2)
            
            spawnThread = task.spawn(function()
                while hunting do spawnEgg(); task.wait(0.3) end
            end)
            
            monitorConnection = RunService.Heartbeat:Connect(function()
                if not hunting then return end
                if tick() % CHECK_INTERVAL < 0.01 then
                    local targetType, targetTier, emoji, hitColor = checkForTargetFast()
                    if targetType then
                        hunting = false
                        status.Text = emoji .. " HIT!"
                        status.TextColor3 = Color3.new(0, 1, 0)
                        liveScan.Text = targetType:upper() .. " " .. targetTier
                        huntBtn.Text = emoji .. " WIN!"
                        huntBtn.BackgroundColor3 = Color3.new(0, 0.85, 0)
                        
                        showBubble(targetTier .. " " .. targetType:upper() .. "!", 6, hitColor)
                        
                        game.StarterGui:SetCore("SendNotification", {
                            Title = emoji .. " " .. targetTier,
                            Text = targetType:upper() .. " | Eggs: " .. eggsSpawned,
                            Duration = 10
                        })
                    end
                end
            end)
        else
            status.TextColor3 = Color3.new(1, 0, 0)
            status.Text = "STOPPED | Eggs: " .. eggsSpawned
            huntBtn.Text = "🔥 START HUNT"
            huntBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
            if spawnThread then task.cancel(spawnThread) end
            if monitorConnection then monitorConnection:Disconnect() end
        end
    end)

    -- PENS BUTTON EVENT
    pensBtn.MouseButton1Click:Connect(function()
        autoPens = not autoPens
        if autoPens then
            pensCollected = 0
            pensLabel.Text = "🖊️ PENS: ON | " .. pensCollected
            pensLabel.BackgroundColor3 = Color3.new(0, 0.8, 0.2)
            pensBtn.Text = "⏹ STOP PENS"
            pensBtn.BackgroundColor3 = Color3.new(0.9, 0.2, 0.1)
            showBubble("💰 AUTO PENS!", 2)
            
            penThread = task.spawn(function()
                while autoPens do
                    collectPens()
                    pensLabel.Text = "🖊️ PENS: ON | " .. pensCollected
                    task.wait(PEN_COLLECT_INTERVAL)
                end
            end)
        else
            pensLabel.BackgroundColor3 = Color3.new(0.2, 0.8, 0.4)
            pensLabel.Text = "🖊️ PENS: OFF | " .. pensCollected
            pensBtn.Text = "🖊️ AUTO PENS (82)"
            pensBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
            if penThread then task.cancel(penThread) end
        end
    end)

    -- CLOSE
    closeBtn.MouseButton1Click:Connect(function()
        hunting = false
        autoPens = false
        if spawnThread then task.cancel(spawnThread) end
        if monitorConnection then monitorConnection:Disconnect() end
        if penThread then task.cancel(penThread) end
        screenGui:Destroy()
    end)
end

createUI()
game.StarterGui:SetCore("SendNotification", {
    Title = "🌶️🥤🤠☕️✨📝😂☢️ v14.6 MINI UI",
    Text = "11 Targets + Auto Pens + RADIOACTIVE (No Gold)!",
    Duration = 6
})
print("✅ v14.6 MINI UI - RADIOACTIVE SCAN - READY!")

-- DRAG FUNCTION
local dragging = false
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    local newPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    mainFrame.Position = newPosition
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateInput(input)
    end
end)

-- ANTI-AFK
spawn(function()
    while true do
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
        task.wait(1)
    end
end)

print("✅ ANTI-AFK + RADIOACTIVE SCAN AKTIF!")
