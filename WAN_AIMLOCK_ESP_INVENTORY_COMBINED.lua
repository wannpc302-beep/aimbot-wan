--[[
WAN - Game Tools (Ultimate Mobile Combo: AimLock + ESP + RapidFire)
Single-File LocalScript Starter / Executor Script for Roblox (Mobile Optimized)
FEATURES:
Mobile UI: Clean Dark/Neon Cyan theme, Draggable Header, Touch-friendly big buttons.
ESP: Player Highlight (Occluded Mode) + Real-time HP NameTags.
COMBAT:
Aim Lock: Instantly snaps camera to closest target's head.
Triggerbot: Automatically fires when pointing at target (Requires holding a Tool).
Rapid Fire: Multi-level firing rate multiplier (Levels 1 to 5).
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local CONFIG = {
GuiName = "WAN_UltimateTools",
Accent = Color3.fromRGB(0, 229, 255),      -- Neon Cyan
Background = Color3.fromRGB(15, 15, 20),   -- Dark OLED Background
Panel = Color3.fromRGB(24, 24, 32),        -- Panel Container Background
Text = Color3.fromRGB(245, 245, 250),      -- White Text
Muted = Color3.fromRGB(150, 150, 165),     -- Sub-text Color
}
-- Clean up previous copies of either script so only one WAN window remains.
local oldGui = PlayerGui:FindFirstChild(CONFIG.GuiName)
if oldGui then oldGui:Destroy() end
local oldInventoryGui = PlayerGui:FindFirstChild("WAN_InventoryPanel")
if oldInventoryGui then oldInventoryGui:Destroy() end
-- Global System States
local state = {
espEnabled = false,
aimLockEnabled = false,
triggerbotEnabled = false,
rapidFireEnabled = false,
fireRateLevel = 3, -- Default speed level: 3 (Levels: 1 - 5)
highlights = {},
billboards = {},
healthConnections = {},
}
-- Helper function to instantiate instances with properties
local function make(className, props, parent)
local object = Instance.new(className)
for key, value in pairs(props or {}) do
object[key] = value
end
object.Parent = parent
return object
end
local gui = make("ScreenGui", {
Name = CONFIG.GuiName,
ResetOnSpawn = false,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)
-- Main Floating Panel
local main = make("Frame", {
Name = "Main",
Size = UDim2.fromOffset(360, 380),
Position = UDim2.new(0.5, -180, 0.5, -190),
BackgroundColor3 = CONFIG.Background,
BorderSizePixel = 0,
Visible = false,
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 14)}, main)
make("UIStroke", {Color = CONFIG.Accent, Thickness = 1.5}, main)
-- Top Draggable Header
local top = make("Frame", {
Size = UDim2.new(1, 0, 0, 44),
BackgroundColor3 = CONFIG.Panel,
BorderSizePixel = 0,
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 14)}, top)
make("TextLabel", {
Size = UDim2.new(1, -50, 1, 0),
Position = UDim2.fromOffset(14, 0),
BackgroundTransparency = 1,
Text = "AIMBOT WAN",
TextColor3 = CONFIG.Accent,
Font = Enum.Font.GothamBold,
TextSize = 14,
TextXAlignment = Enum.TextXAlignment.Left,
}, top)
local close = make("TextButton", {
Size = UDim2.fromOffset(34, 30),
Position = UDim2.new(1, -40, 0, 7),
BackgroundColor3 = Color3.fromRGB(220, 60, 70),
Text = "×",
TextColor3 = Color3.new(1, 1, 1),
Font = Enum.Font.GothamBold,
TextSize = 22,
BorderSizePixel = 0,
}, top)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, close)

-- Floating square launcher: tap to open/close; drag to reposition.
local launcher = make("TextButton", {
    Name = "WANLauncher", Size = UDim2.fromOffset(54, 54),
    Position = UDim2.new(0, 22, 0.55, -27),
    BackgroundColor3 = CONFIG.Panel, Text = "W",
    TextColor3 = CONFIG.Accent, Font = Enum.Font.GothamBlack,
    TextSize = 24, BorderSizePixel = 0, AutoButtonColor = true, ZIndex = 20,
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, launcher)
make("UIStroke", {Color = CONFIG.Accent, Thickness = 2}, launcher)

local draggingLauncher, dragInput, dragStart, startPosition, moved = false, nil, nil, nil, false
launcher.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingLauncher, moved = true, false
        dragInput, dragStart, startPosition = input, input.Position, launcher.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not draggingLauncher or not dragStart or not startPosition then return end
    local touchMove = dragInput and dragInput.UserInputType == Enum.UserInputType.Touch and input == dragInput
    local mouseMove = dragInput and dragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement
    if touchMove or mouseMove then
        local delta = input.Position - dragStart
        if delta.Magnitude > 6 then moved = true end
        launcher.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingLauncher, dragInput, dragStart, startPosition = false, nil, nil, nil
    end
end)
launcher.Activated:Connect(function()
    if moved then moved = false; return end
    main.Visible = not main.Visible
end)
close.Activated:Connect(function()
main.Visible = false
end)
-- Smooth Touch/Mouse Dragging Mechanism (mouse + touch)
do
    local dragging = false
    local dragInput
    local dragStart, startPosition

    top.InputBegan:Connect(function(input)
        local inputType = input.UserInputType
        if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPosition = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not dragStart or not startPosition then return end
        local touchMove = dragInput and dragInput.UserInputType == Enum.UserInputType.Touch and input == dragInput
        local mouseMove = dragInput and dragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement
        if touchMove or mouseMove then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragInput, dragStart, startPosition = false, nil, nil, nil
        end
    end)
end
-- Navigation Tab Bar Container
local tabBar = make("Frame", {
Size = UDim2.new(1, -20, 0, 36),
Position = UDim2.fromOffset(10, 52),
BackgroundTransparency = 1,
}, main)
-- Main Content Container
local content = make("Frame", {
Size = UDim2.new(1, -20, 1, -102),
Position = UDim2.fromOffset(10, 94),
BackgroundColor3 = CONFIG.Panel,
BorderSizePixel = 0,
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 10)}, content)
local status = make("TextLabel", {
Size = UDim2.new(1, -20, 0, 20),
Position = UDim2.new(0, 10, 1, -22),
BackgroundTransparency = 1,
Text = "Status: Ready",
TextColor3 = CONFIG.Muted,
Font = Enum.Font.Gotham,
TextSize = 10,
TextXAlignment = Enum.TextXAlignment.Left,
}, content)
local pages = {}
local function newPage(name)
local page = make("ScrollingFrame", {
Name = name,
Size = UDim2.new(1, -12, 1, -32),
Position = UDim2.fromOffset(6, 6),
BackgroundTransparency = 1,
BorderSizePixel = 0,
ScrollBarThickness = 3,
ScrollBarImageColor3 = CONFIG.Accent,
CanvasSize = UDim2.new(),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
Visible = false,
}, content)
make("UIListLayout", {
Padding = UDim.new(0, 6),
SortOrder = Enum.SortOrder.LayoutOrder,
}, page)
pages[name] = page
return page
end
local function setStatus(msg)
status.Text = "Status: " .. tostring(msg)
end
local function addLabel(parent, text)
return make("TextLabel", {
Size = UDim2.new(1, -4, 0, 22),
BackgroundTransparency = 1,
Text = text,
TextColor3 = CONFIG.Text,
Font = Enum.Font.Gotham,
TextSize = 11,
TextXAlignment = Enum.TextXAlignment.Left,
}, parent)
end
local function addButton(parent, text, callback)
local button = make("TextButton", {
Size = UDim2.new(1, -4, 0, 38),
BackgroundColor3 = Color3.fromRGB(35, 35, 45),
Text = text,
TextColor3 = CONFIG.Text,
Font = Enum.Font.GothamSemibold,
TextSize = 12,
BorderSizePixel = 0,
AutoButtonColor = true,
}, parent)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, button)
make("UIStroke", {Color = Color3.fromRGB(50, 50, 65), Thickness = 1}, button)
button.Activated:Connect(callback)
return button
end
-- ==========================================
-- 1. ESP System Logic
-- ==========================================
local function clearDebugESP(player)
if state.highlights[player] then
state.highlights[player]:Destroy()
state.highlights[player] = nil
end
if state.billboards[player] then
state.billboards[player]:Destroy()
state.billboards[player] = nil
end
if state.healthConnections[player] then
state.healthConnections[player]:Disconnect()
state.healthConnections[player] = nil
end
end
local function applyDebugESP(player)
if player == LocalPlayer or not state.espEnabled then return end
local character = player.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local root = character and character:FindFirstChild("HumanoidRootPart")
if not character or not humanoid or not root then return end
clearDebugESP(player)
local highlight = Instance.new("Highlight")
highlight.Name = "WAN_Highlight"
highlight.FillColor = CONFIG.Accent
highlight.OutlineColor = Color3.new(1, 1, 1)
highlight.FillTransparency = 0.75
highlight.DepthMode = Enum.HighlightDepthMode.Occluded
highlight.Adornee = character
highlight.Parent = character
state.highlights[player] = highlight
local billboard = Instance.new("BillboardGui")
billboard.Name = "WAN_NameTag"
billboard.Size = UDim2.fromOffset(160, 28)
billboard.StudsOffset = Vector3.new(0, 2.5, 0)
billboard.AlwaysOnTop = true
billboard.Adornee = root
billboard.Parent = PlayerGui
local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Text = string.format("%s | %d HP", player.DisplayName, math.floor(humanoid.Health))
label.TextColor3 = Color3.new(1, 1, 1)
label.TextStrokeTransparency = 0.3
label.Font = Enum.Font.GothamBold
label.TextSize = 11
label.Parent = billboard
state.billboards[player] = billboard
state.healthConnections[player] = humanoid.HealthChanged:Connect(function(health)
if label.Parent then
label.Text = string.format("%s | %d HP", player.DisplayName, math.floor(health))
end
end)
end
local function refreshESP()
for _, player in ipairs(Players:GetPlayers()) do
clearDebugESP(player)
if state.espEnabled then applyDebugESP(player) end
end
end
-- ==========================================
-- 2. Aim Lock System Logic
-- ==========================================
local function getClosestPlayer()
local closestPlayer = nil
local shortestDistance = math.huge
local mousePos = UserInputService:GetMouseLocation()
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer and player.Character then
local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
local head = player.Character:FindFirstChild("Head")
if humanoid and humanoid.Health > 0 and head then
Camera = workspace.CurrentCamera
if not Camera then continue end
local vector, onScreen = Camera:WorldToViewportPoint(head.Position)
if onScreen then
local distance = (Vector2.new(vector.X, vector.Y) - mousePos).Magnitude
if distance < shortestDistance then
shortestDistance = distance
closestPlayer = player
end
end
end
end
end
return closestPlayer
end
RunService.RenderStepped:Connect(function()
if state.aimLockEnabled then
local target = getClosestPlayer()
if target and target.Character and target.Character:FindFirstChild("Head") then
Camera = workspace.CurrentCamera
if Camera then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position) end
end
end
end)
-- ==========================================
-- 3. Triggerbot System Logic (Weapon Equip Check)
-- ==========================================
local function getEquippedWeapon()
local character = LocalPlayer.Character
if character then
return character:FindFirstChildOfClass("Tool")
end
return nil
end
RunService.RenderStepped:Connect(function()
if not state.triggerbotEnabled then return end
local weapon = getEquippedWeapon()
if weapon then
local mouse = LocalPlayer:GetMouse()
local target = mouse.Target
if target and target.Parent then
local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
if targetPlayer and targetPlayer ~= LocalPlayer then
weapon:Activate()
end
end
end
end)
-- ==========================================
-- 4. Rapid Fire System Logic (Levels 1 to 5)
-- ==========================================
local delayTable = { [1] = 0.15, [2] = 0.10, [3] = 0.06, [4] = 0.03, [5] = 0.01 }
local lastShot = 0
RunService.RenderStepped:Connect(function()
if not state.rapidFireEnabled then return end
local weapon = getEquippedWeapon()
if weapon and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
local now = tick()
local currentDelay = delayTable[state.fireRateLevel] or 0.06
if now - lastShot >= currentDelay then
lastShot = now
weapon:Activate()
end
end
end)
-- ==========================================
-- Constructing Page Layouts & Buttons
-- ==========================================
-- COMBAT TAB PAGE
local combatPage = newPage("COMBAT")
addLabel(combatPage, "Combat & Aim Assistance")
local aimBtn
aimBtn = addButton(combatPage, "Aim Lock: OFF", function()
state.aimLockEnabled = not state.aimLockEnabled
aimBtn.Text = state.aimLockEnabled and "Aim Lock: ON" or "Aim Lock: OFF"
setStatus(state.aimLockEnabled and "Aim Lock Activated" or "Aim Lock Deactivated")
end)
local trigBtn
trigBtn = addButton(combatPage, "Triggerbot: OFF", function()
state.triggerbotEnabled = not state.triggerbotEnabled
trigBtn.Text = state.triggerbotEnabled and "Triggerbot: ON" or "Triggerbot: OFF"
setStatus(state.triggerbotEnabled and "Triggerbot Activated (Hold Weapon)" or "Triggerbot Deactivated")
end)
local rapidBtn
rapidBtn = addButton(combatPage, "Rapid Fire: OFF", function()
state.rapidFireEnabled = not state.rapidFireEnabled
rapidBtn.Text = state.rapidFireEnabled and "Rapid Fire: ON" or "Rapid Fire: OFF"
setStatus(state.rapidFireEnabled and ("Rapid Fire ON (Level " .. state.fireRateLevel .. ")") or "Rapid Fire OFF")
end)
local speedBtn
speedBtn = addButton(combatPage, "Set Fire Rate (Level " .. state.fireRateLevel .. ")", function()
state.fireRateLevel = state.fireRateLevel + 1
if state.fireRateLevel > 5 then state.fireRateLevel = 1 end
speedBtn.Text = "Set Fire Rate (Level " .. state.fireRateLevel .. ")"
if state.rapidFireEnabled then
setStatus("Rapid Fire Speed set to Level " .. state.fireRateLevel)
end
end)
-- ESP TAB PAGE
local espPage = newPage("ESP")
addLabel(espPage, "Visual ESP & HP Tracking")
local espBtn
espBtn = addButton(espPage, "ESP Highlight: OFF", function()
state.espEnabled = not state.espEnabled
espBtn.Text = state.espEnabled and "ESP Highlight: ON" or "ESP Highlight: OFF"
refreshESP()
setStatus(state.espEnabled and "ESP Highlights Enabled" or "ESP Highlights Disabled")
end)
-- MISC TAB PAGE
local miscPage = newPage("MISC")
addLabel(miscPage, "Utilities & Controls")
addButton(miscPage, "Refresh All Systems", function()
refreshESP()
setStatus("All Systems Refreshed")
end)
addButton(miscPage, "ซ่อนหน้าต่างหลัก", function()
main.Visible = false
end)

-- INVENTORY: merged inventory system.
-- Shows both equipped Tools and Backpack Tools, including their optional Level.
-- The list refreshes automatically when Tools are added, removed, equipped or unequipped.
local inventoryPage = newPage("INVENTORY")
addLabel(inventoryPage, "ของในตัวละคร / INVENTORY")
addLabel(inventoryPage, "แสดง Tool ในกระเป๋าและ Tool ที่กำลังถือ พร้อม Level")

local inventoryList = make("Frame", {
    Name = "InventoryList",
    Size = UDim2.new(1, -4, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
}, inventoryPage)
local inventoryLayout = make("UIListLayout", {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, inventoryList)

local inventoryContainerConnections = {}
local inventoryPlayerConnections = {}
local inventoryLevelConnections = {}
local inventoryRefreshQueued = false
local refreshInventory

local function disconnectList(connectionList)
    for _, connection in ipairs(connectionList) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(connectionList)
end

local function getToolLevel(tool)
    local attribute = tool:GetAttribute("Level")
    if typeof(attribute) == "number" or typeof(attribute) == "string" then
        return tostring(attribute)
    end

    local value = tool:FindFirstChild("Level")
    if value and (value:IsA("IntValue") or value:IsA("NumberValue") or value:IsA("StringValue")) then
        return tostring(value.Value)
    end
    return "ไม่ระบุ"
end

local function queueInventoryRefresh()
    if inventoryRefreshQueued then return end
    inventoryRefreshQueued = true
    task.defer(function()
        inventoryRefreshQueued = false
        if gui and gui.Parent and refreshInventory then
            refreshInventory(false)
        end
    end)
end

local function addInventoryRow(tool, place, order)
    local row = make("Frame", {
        Name = "InventoryItem_" .. tostring(order),
        Size = UDim2.new(1, -4, 0, 45),
        BackgroundColor3 = Color3.fromRGB(35, 35, 45),
        BorderSizePixel = 0,
        LayoutOrder = order,
    }, inventoryList)
    make("UICorner", {CornerRadius = UDim.new(0, 8)}, row)

    make("TextLabel", {
        Size = UDim2.new(1, -16, 0, 20),
        Position = UDim2.fromOffset(9, 4),
        BackgroundTransparency = 1,
        Text = tool.Name,
        TextColor3 = CONFIG.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)

    make("TextLabel", {
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.fromOffset(9, 25),
        BackgroundTransparency = 1,
        Text = place .. "  |  Level: " .. getToolLevel(tool),
        TextColor3 = place == "กำลังถือ" and CONFIG.Accent or CONFIG.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)

    -- Keep the displayed Level current if the Tool's Attribute/Value changes.
    table.insert(inventoryLevelConnections, tool:GetAttributeChangedSignal("Level"):Connect(queueInventoryRefresh))
    table.insert(inventoryLevelConnections, tool:GetPropertyChangedSignal("Name"):Connect(queueInventoryRefresh))
    table.insert(inventoryLevelConnections, tool.ChildAdded:Connect(function(child)
        if child.Name == "Level" then queueInventoryRefresh() end
    end))
    table.insert(inventoryLevelConnections, tool.ChildRemoved:Connect(function(child)
        if child.Name == "Level" then queueInventoryRefresh() end
    end))
    local levelValue = tool:FindFirstChild("Level")
    if levelValue and (levelValue:IsA("IntValue") or levelValue:IsA("NumberValue") or levelValue:IsA("StringValue")) then
        table.insert(inventoryLevelConnections, levelValue.Changed:Connect(queueInventoryRefresh))
    end
end

refreshInventory = function(updateStatus)
    disconnectList(inventoryLevelConnections)
    for _, child in ipairs(inventoryList:GetChildren()) do
        if child ~= inventoryLayout then
            child:Destroy()
        end
    end

    local items = {}
    local character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

    -- Equipped items are listed first.
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(items, {tool = item, place = "กำลังถือ"})
            end
        end
    end
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(items, {tool = item, place = "Backpack"})
            end
        end
    end

    table.sort(items, function(a, b)
        if a.place ~= b.place then
            return a.place == "กำลังถือ"
        end
        return string.lower(a.tool.Name) < string.lower(b.tool.Name)
    end)

    for index, item in ipairs(items) do
        addInventoryRow(item.tool, item.place, index)
    end

    if #items == 0 then
        make("TextLabel", {
            Name = "EmptyInventoryMessage",
            Size = UDim2.new(1, -4, 0, 34),
            BackgroundTransparency = 1,
            Text = "ไม่พบ Tool ในตัวละครหรือ Backpack",
            TextColor3 = CONFIG.Muted,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, inventoryList)
    end

    if updateStatus then
        setStatus("พบ Tool " .. #items .. " รายการ")
    end
end

local function watchInventoryContainer(container)
    if not container then return end
    table.insert(inventoryContainerConnections, container.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then queueInventoryRefresh() end
    end))
    table.insert(inventoryContainerConnections, container.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then queueInventoryRefresh() end
    end))
end

local function rebindInventoryContainers()
    disconnectList(inventoryContainerConnections)
    watchInventoryContainer(LocalPlayer.Character)
    watchInventoryContainer(LocalPlayer:FindFirstChildOfClass("Backpack"))
    queueInventoryRefresh()
end

rebindInventoryContainers()
table.insert(inventoryPlayerConnections, LocalPlayer.CharacterAdded:Connect(function(character)
    task.defer(rebindInventoryContainers)
end))
table.insert(inventoryPlayerConnections, LocalPlayer.ChildAdded:Connect(function(child)
    if child:IsA("Backpack") then
        task.defer(rebindInventoryContainers)
    end
end))
addButton(inventoryPage, "รีเฟรชรายการของในตัว", function()
    refreshInventory(true)
end)

-- TAB NAVIGATION BUTTON CREATION
local tabNames = {"COMBAT", "ESP", "INVENTORY", "MISC"}
for index, name in ipairs(tabNames) do
local tab = make("TextButton", {
Name = name .. "Tab",
Size = UDim2.new(1 / #tabNames, -4, 1, 0),
Position = UDim2.new((index - 1) / #tabNames, 2, 0, 0),
BackgroundColor3 = Color3.fromRGB(35, 35, 45),
Text = name,
TextColor3 = CONFIG.Text,
Font = Enum.Font.GothamBold,
TextSize = 10,
BorderSizePixel = 0,
}, tabBar)
make("UICorner", {CornerRadius = UDim.new(0, 6)}, tab)
tab.Activated:Connect(function()
for pageName, page in pairs(pages) do
page.Visible = (pageName == name)
end
if name == "INVENTORY" then refreshInventory(false) end
setStatus("Switched to " .. name .. " tab")
end)
end
-- Default View Set to COMBAT
pages.COMBAT.Visible = true
-- Connections for Player Dynamic Spawn Event Handling
Players.PlayerAdded:Connect(function(player)
player.CharacterAdded:Connect(function()
task.wait(1)
if state.espEnabled then applyDebugESP(player) end
end)
end)
Players.PlayerRemoving:Connect(function(player)
clearDebugESP(player)
end)

gui.Destroying:Connect(function()
    -- Stop active features when this UI is removed or replaced by a new copy.
    state.espEnabled = false
    state.aimLockEnabled = false
    state.triggerbotEnabled = false
    state.rapidFireEnabled = false
    disconnectList(inventoryContainerConnections)
    disconnectList(inventoryPlayerConnections)
    disconnectList(inventoryLevelConnections)
    for player in pairs(state.highlights) do
        clearDebugESP(player)
    end
end)

print("[AIMBOT WAN] Combined UI + Inventory Engine Ready.")
