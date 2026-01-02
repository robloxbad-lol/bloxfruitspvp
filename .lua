local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- GUI作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RobloxCheat"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 220)
frame.Position = UDim2.new(0.35, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.Parent = screenGui

-- タイトル
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Text = "Roblox Cheat"
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.TextScaled = true
title.Parent = frame

-- 閉じるボタン
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 40, 0, 25)
closeButton.Position = UDim2.new(1, -45, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = frame
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- スクロールフレーム
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,0,1,-40)
scrollFrame.Position = UDim2.new(0,0,0,40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 8
scrollFrame.CanvasSize = UDim2.new(0,0,2,0)
scrollFrame.Parent = frame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,5)
layout.Parent = scrollFrame

-- GUIドラッグ（タイトルバーのみ）
local dragging, dragInput, dragStart, startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)


-- ボタン作成関数
local function createButton(name, color, textColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 50)
    btn.BackgroundColor3 = color
    btn.TextColor3 = textColor
    btn.Text = name
    btn.TextScaled = true
    btn.Parent = scrollFrame
    return btn
end

-- =========================
-- ESP
-- =========================
local espEnabled = false
local espButton = createButton("ESP: OFF", Color3.fromRGB(0,200,0), Color3.fromRGB(0,0,0))
local espObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    if espObjects[player] then return end

    local function onCharacter(char)
        local head = char:WaitForChild("Head",5)
        if not head then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0,200,0,50)
        billboard.StudsOffset = Vector3.new(0,2,0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1,0,1,0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(0,255,0)
        textLabel.TextScaled = true
        textLabel.Parent = billboard

        RunService.RenderStepped:Connect(function()
            if espEnabled and char:FindFirstChild("Humanoid") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = char.Humanoid
                local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude)
                textLabel.Text = string.format("%s | HP:%d | %dm", player.Name, humanoid.Health, distance)
                billboard.Enabled = true
            else
                billboard.Enabled = false
            end
        end)
    end

    if player.Character then
        onCharacter(player.Character)
    end
    player.CharacterAdded:Connect(onCharacter)
    espObjects[player] = true
end

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = espEnabled and "ESP: ON" or "ESP: OFF"

    if espEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            createESP(plr)
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if espEnabled then
            task.wait(1)
            createESP(player)
        end
    end)
end)

-- =========================
-- Aimbot
-- =========================
local aimbotEnabled = false
local rightMouseDown = false
local aimbotButton = createButton("Aimbot: OFF", Color3.fromRGB(200,0,200), Color3.fromRGB(255,255,255))

aimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimbotButton.Text = aimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseDown = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseDown = false
    end
end)

local function getClosestEnemy()
    local closest, distance = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if dist < distance then
                    distance = dist
                    closest = head
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and rightMouseDown then
        local target = getClosestEnemy()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- =========================
-- FOV Aimbot
-- =========================
local fovEnabled = false
local fovRadius = 300
local fovButton = createButton("FOV Aimbot: OFF", Color3.fromRGB(0,0,200), Color3.fromRGB(255,255,255))

local fovCircle = Drawing.new("Circle")
fovCircle.Radius = fovRadius
fovCircle.Color = Color3.fromRGB(255,0,0)
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Visible = false
fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

fovButton.MouseButton1Click:Connect(function()
    fovEnabled = not fovEnabled
    fovButton.Text = fovEnabled and "FOV Aimbot: ON" or "FOV Aimbot: OFF"
    fovCircle.Visible = fovEnabled
end)

local function getClosestInFOV()
    local closest, distance = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist <= fovRadius and dist < distance then
                    distance = dist
                    closest = head
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    if fovEnabled and rightMouseDown then
        local target = getClosestInFOV()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- スクロールフレームのCanvasSize自動調整
local function updateCanvas()
    scrollFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
updateCanvas()
local noclipEnabled = false

local noclipButton = createButton("NoClip: OFF", Color3.fromRGB(255,165,0), Color3.fromRGB(0,0,0))

noclipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipButton.Text = noclipEnabled and "NoClip: ON" or "NoClip: OFF"
end)

local function applyNoClip()
    local char = LocalPlayer.Character
    if not char then return end

    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclipEnabled and true or false
        end
    end
end

RunService.Stepped:Connect(applyNoClip)
-- 既存GUIの下に追加
local function createSlider(name, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.9,0,0,40)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    sliderFrame.Parent = scrollFrame

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1,0,0.5,0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = name .. ": " .. default
    sliderLabel.TextColor3 = Color3.fromRGB(255,255,255)
    sliderLabel.TextScaled = true
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = sliderFrame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1,0,0.3,0)
    sliderBar.Position = UDim2.new(0,0,0.5,0)
    sliderBar.BackgroundColor3 = Color3.fromRGB(0,200,255)
    sliderBar.Parent = sliderFrame

    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0,20,1,0)
    handle.Position = UDim2.new((default-min)/(max-min),0,0,0)
    handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    handle.Parent = sliderBar

    local dragging = false
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X - handle.AbsoluteSize.X/2, 0, sliderBar.AbsoluteSize.X)
            handle.Position = UDim2.new(0, relativeX,0,0)
            local value = math.floor((relativeX / sliderBar.AbsoluteSize.X) * (max - min) + min)
            sliderLabel.Text = name .. ": " .. value
            callback(value)
        end
    end)
end

-- Dash Length スライダー追加
createSlider("Dash Length", 10, 100, 10, function(value)
    LocalPlayer.Character:SetAttribute("DashLength", value)
end)

-- スクロールフレームのCanvasSize自動調整
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

-- スライダー作成関数（roblox cheat GUI用）
local function createSlider(name, min, max, default, increment, suffix, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.9,0,0,40)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    sliderFrame.Parent = scrollFrame

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1,0,0.5,0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = name .. ": " .. default .. suffix
    sliderLabel.TextColor3 = Color3.fromRGB(255,255,255)
    sliderLabel.TextScaled = true
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = sliderFrame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1,0,0.3,0)
    sliderBar.Position = UDim2.new(0,0,0.5,0)
    sliderBar.BackgroundColor3 = Color3.fromRGB(0,200,255)
    sliderBar.Parent = sliderFrame

    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0,20,1,0)
    handle.Position = UDim2.new((default - min)/(max - min),0,0,0)
    handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    handle.Parent = sliderBar

    local dragging = false
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X - handle.AbsoluteSize.X/2, 0, sliderBar.AbsoluteSize.X)
            handle.Position = UDim2.new(0, relativeX,0,0)
            local value = math.floor((relativeX / sliderBar.AbsoluteSize.X) * (max - min)/increment + 0.5) * increment + min
            value = math.floor(value * 10)/10  -- 小数点以下の丸め
            sliderLabel.Text = name .. ": " .. value .. suffix
            callback(value)
        end
    end)
end

-- Speed Multiplier スライダー追加
createSlider("Speed Multiplier", 1, 10, 1, 0.1, "x", function(value)
    local lp = game.Players.LocalPlayer
    if lp.Character then
        lp.Character:SetAttribute("SpeedMultiplier", value)
        print("SpeedMultiplier を", value, "に設定しました")
    else
        print("キャラが存在しません")
    end
end)
-- スクロールフレームに追加するボタン関数
local function createButton(name, color, textColor, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 50)
    btn.BackgroundColor3 = color
    btn.TextColor3 = textColor
    btn.Text = name
    btn.TextScaled = true
    btn.Parent = scrollFrame -- ← ここが重要
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ▼ ボタン1: Gキー & GUIボタン
createButton("Teleport Spot 1 (Gキーでも可)", Color3.fromRGB(0,200,255), Color3.fromRGB(0,0,0), function()
    local lp = game.Players.LocalPlayer
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(970.4629, 252.0259, 32872.1875))
    end
end)

-- ▼ ボタン2: Vキー & GUIボタン
createButton("Teleport Spot 2 (Vキーでも可)", Color3.fromRGB(255,165,0), Color3.fromRGB(0,0,0), function()
    local lp = game.Players.LocalPlayer
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(-285.2947082519531, 305.8865966796875, 590.4352416792188))
    end
end)

-- ▼ キー操作
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    local lp = game.Players.LocalPlayer
    if not (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")) then return end
    if input.KeyCode == Enum.KeyCode.G then
        lp.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(970.4629, 252.0259, 32872.1875))
    elseif input.KeyCode == Enum.KeyCode.V then
        lp.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(-285.2947082519531, 305.8865966796875, 590.4352416792188))
    end
end)
-- ▼ Flyボタン作成
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0.9, 0, 0, 50)
flyButton.Position = UDim2.new(0.05, 0, 0, 0) -- scrollFrame 内のレイアウト次第で調整
flyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Text = "Fly"
flyButton.TextScaled = true
flyButton.Parent = scrollFrame

flyButton.MouseButton1Click:Connect(function()
    -- 指定URLのスクリプトを取得して実行
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end)
    if not success then
        warn("Flyスクリプトの実行に失敗しました:", err)
    end
end)
-- ▼ オブジェクトダメージ無効化フラグ
local hitDisable = false

-- ▼ スクロールフレーム用トグル作成関数
local function createToggle(name, default, callback)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    toggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    toggleBtn.TextScaled = true
    toggleBtn.Text = name .. ": OFF"
    toggleBtn.Parent = scrollFrame -- 既存の scrollFrame に追加

    local state = default

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = name .. (state and ": ON" or ": OFF")
        callback(state)
    end)
end

-- ▼ Roblox Cheat用トグルとして追加
createToggle("オブジェクトダメージ無効化", false, function(state)
    hitDisable = state
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanTouch = not hitDisable
        end
    end
end)
-- ==================================================
-- FastAttack 統合版 (完全対応)
-- ==================================================

-- サービスの再定義（必要に応じて）
local FA_ReplicatedStorage = game:GetService("ReplicatedStorage")
local FA_Net = FA_ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local FA_RE_RegisterAttack = FA_Net["RE/RegisterAttack"]
local FA_RE_RegisterHit = FA_Net["RE/RegisterHit"]
local FA_Characters = workspace:WaitForChild("Characters")
local FA_Enemies = workspace:WaitForChild("Enemies")

-- 設定
local FA_Enabled = false
local FA_ClickDelay = 0.01
local FA_Distance = 100

-- ターゲット取得ロジック
local function GetFATargets()
    local targets = {}
    local nearestPart
    local char = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil, {} end

    local function scan(folder)
        if not folder then return end
        for _, obj in pairs(folder:GetChildren()) do
            if obj ~= char then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                if root and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    if dist <= FA_Distance then
                        table.insert(targets, { obj, root })
                        nearestPart = root
                    end
                end
            end
        end
    end

    scan(FA_Enemies)
    scan(FA_Characters)

    return nearestPart, targets
end

-- 攻撃実行
local function ExecuteFA()
    local char = LocalPlayer.Character
    if not (char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0) then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local tip = tool.ToolTip
    if tip ~= "Melee" and tip ~= "Sword" and tip ~= "Blox Fruit" then return end

    local targetPart, enemies = GetFATargets()
    if not targetPart or #enemies == 0 then return end

    FA_RE_RegisterAttack:FireServer(FA_ClickDelay)
    FA_RE_RegisterHit:FireServer(targetPart, enemies)

    if tool:FindFirstChild("LeftClickRemote") then
        tool.LeftClickRemote:FireServer(
            (targetPart.Position - char:GetPivot().Position).Unit,
            1
        )
    end
end

-- ボタン作成 (既存の createButton 関数を使用)
local fastAttackBtn = createButton("FastAttack: OFF", Color3.fromRGB(255, 80, 80), Color3.fromRGB(255, 255, 255), function()
    FA_Enabled = not FA_Enabled
    
    -- ボタンの見た目更新
    if FA_Enabled then
        -- 外部変数経由でアクセスするため、直接更新
        -- ※createButton内で作成されたbtnインスタンスは内部変数ですが、
        -- 既存のスクリプトの構造上、ループで文字を変えるのが確実です。
    end
end)

-- ボタンのテキストと色の同期ループ
task.spawn(function()
    while task.wait(0.1) do
        if FA_Enabled then
            fastAttackBtn.Text = "FastAttack: ON"
            fastAttackBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
            fastAttackBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            fastAttackBtn.Text = "FastAttack: OFF"
            fastAttackBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            fastAttackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
end)

-- メイン攻撃ループ
task.spawn(function()
    while true do
        if FA_Enabled then
            pcall(ExecuteFA)
        end
        task.wait(FA_ClickDelay)
    end
end)
-- ==================================================
-- 【完全統合・修正版】全機能一括追加セクション
-- ==================================================

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- リモートの取得（Buso用の正しい名称 CommF_ を使用）
local CommF_Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- 1. Auto Buso Haki (提示されたロジックに完全修正)
_G.AutoBuso = false
local busoBtn = createButton("Auto Buso Haki: OFF", Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255), function()
    _G.AutoBuso = not _G.AutoBuso
end)

task.spawn(function()
    while task.wait(0.5) do
        -- ボタンの見た目更新（連打にならないよう0.5秒間隔）
        busoBtn.Text = "Auto Buso Haki: " .. (_G.AutoBuso and "ON" or "OFF")
        busoBtn.BackgroundColor3 = _G.AutoBuso and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(50, 50, 50)
        busoBtn.TextColor3 = _G.AutoBuso and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)

        -- メインロジック（提示された通りの判定条件）
        if _G.AutoBuso then
            local char = LocalPlayer.Character
            if char
            and CollectionService:HasTag(char, "Buso")
            and not char:FindFirstChild("HasBuso") then
                pcall(function()
                    CommF_Remote:InvokeServer("Buso")
                end)
            end
        end
    end
end)

-- 2. Infinite Energy
_G.InfiniteEnergy = false
local energyBtn = createButton("Infinite Energy: OFF", Color3.fromRGB(0, 150, 200), Color3.fromRGB(255, 255, 255), function()
    _G.InfiniteEnergy = not _G.InfiniteEnergy
end)

RunService.Heartbeat:Connect(function()
    energyBtn.Text = "Infinite Energy: " .. (_G.InfiniteEnergy and "ON" or "OFF")
    energyBtn.BackgroundColor3 = _G.InfiniteEnergy and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(0, 150, 200)
    
    if _G.InfiniteEnergy then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Energy") then
                char.Energy.Value = char.Energy.MaxValue
            end
        end)
    end
end)

-- 3. Water Walk
_G.WaterWalk = false
local waterPart = Instance.new("Part")
waterPart.Size = Vector3.new(100, 1, 100)
waterPart.Anchored = true
waterPart.Transparency = 1
waterPart.CanCollide = false
waterPart.Parent = workspace

local waterBtn = createButton("Water Walk: OFF", Color3.fromRGB(0, 100, 255), Color3.fromRGB(255, 255, 255), function()
    _G.WaterWalk = not _G.WaterWalk
end)

task.spawn(function()
    while task.wait() do
        waterBtn.Text = "Water Walk: " .. (_G.WaterWalk and "ON" or "OFF")
        waterBtn.BackgroundColor3 = _G.WaterWalk and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(0, 100, 255)
        
        if _G.WaterWalk then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and root.Position.Y < 5 and root.Position.Y > -10 then
                waterPart.CFrame = CFrame.new(root.Position.X, 0.5, root.Position.Z)
                waterPart.CanCollide = true
            else
                waterPart.CanCollide = false
            end
        else
            waterPart.CanCollide = false
        end
    end
end)

-- 4. Auto Race V4
_G.AutoRaceV4 = false
local raceV4Btn = createButton("Auto Race V4: OFF", Color3.fromRGB(150, 0, 255), Color3.fromRGB(255, 255, 255), function()
    _G.AutoRaceV4 = not _G.AutoRaceV4
end)

task.spawn(function()
    while task.wait(0.2) do
        raceV4Btn.Text = "Auto Race V4: " .. (_G.AutoRaceV4 and "ON" or "OFF")
        raceV4Btn.BackgroundColor3 = _G.AutoRaceV4 and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(150, 0, 255)
        
        if _G.AutoRaceV4 then
            local char = LocalPlayer.Character
            if char then
                local RaceEnergy = char:FindFirstChild("RaceEnergy")
                local RaceTransformed = char:FindFirstChild("RaceTransformed")
                if RaceEnergy and RaceTransformed then
                    if RaceEnergy.Value >= 1 and not RaceTransformed.Value then
                        ReplicatedStorage.Events.ActivateRaceV4:Fire()
                    end
                end
            end
        end
    end
end)

-- 5. Auto Race Ability
_G.AutoRaceAbility = false
local raceAbilityBtn = createButton("Auto Race Ability: OFF", Color3.fromRGB(255, 100, 0), Color3.fromRGB(255, 255, 255), function()
    _G.AutoRaceAbility = not _G.AutoRaceAbility
end)

local raceAbilities = { "Last Resort","Agility","Water Body","Heavenly Blood", "Heightened Senses","Energy Core","Primordial Reign" }
local raceCooldown = 0

RunService.Heartbeat:Connect(function(dt)
    raceAbilityBtn.Text = "Auto Race Ability: " .. (_G.AutoRaceAbility and "ON" or "OFF")
    raceAbilityBtn.BackgroundColor3 = _G.AutoRaceAbility and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 0)
    
    if not _G.AutoRaceAbility then return end
    local char = LocalPlayer.Character
    if not (char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0) then return end
    
    local hasAbility = false
    for _, v in ipairs(raceAbilities) do
        if LocalPlayer.Backpack:FindFirstChild(v) or char:FindFirstChild(v) then
            hasAbility = true; break
        end
    end
    if not hasAbility then return end

    raceCooldown = raceCooldown - dt
    if raceCooldown <= 0 then
        ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility")
        raceCooldown = 0.2
    end
end)
