-- Quantum Key System
-- Developers: Beko & Nova
-- ─────────────────────────────────────────────

local KEYS_URL   = "https://raw.githubusercontent.com/loapse/keysystem/main/keys.json"
local SCRIPT_URL = "https://raw.githubusercontent.com/loapse/quantum/refs/heads/main/quantum.lua"

-- ─────────────────────────────────────────────
-- SERVICES
-- ─────────────────────────────────────────────
local HttpService   = game:GetService("HttpService")
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local LocalPlayer   = Players.LocalPlayer
local Mouse         = LocalPlayer:GetMouse()

-- ─────────────────────────────────────────────
-- HTTP — compatible with all major exploits
-- ─────────────────────────────────────────────
local function httpGet(url)
    if syn and syn.request then
        local ok, res = pcall(syn.request, {Url=url, Method="GET"})
        if ok and res and res.StatusCode == 200 then return res.Body end
        return nil, "syn: " .. tostring(res and res.StatusCode)
    elseif http and http.request then
        local ok, res = pcall(http.request, {Url=url, Method="GET"})
        if ok and res and res.StatusCode == 200 then return res.Body end
        return nil, "http: " .. tostring(res and res.StatusCode)
    elseif request then
        local ok, res = pcall(request, {Url=url, Method="GET"})
        if ok and res and res.StatusCode == 200 then return res.Body end
        return nil, "req: " .. tostring(res and res.StatusCode)
    else
        local ok, body = pcall(function() return game:HttpGet(url, true) end)
        if ok and body and #body > 0 then return body end
        return nil, "HttpGet failed"
    end
end

-- ─────────────────────────────────────────────
-- HWID — machine fingerprint
-- ─────────────────────────────────────────────
local function getHWID()
    local id = ""
    -- try to get a real machine ID via various exploit APIs
    if identifyexecutor then
        id = identifyexecutor()
    end
    -- fallback: hash player UserId + account age + createdAt
    local uid = tostring(LocalPlayer.UserId)
    local age = tostring(LocalPlayer.AccountAge)
    local raw = uid .. "|" .. age .. "|" .. id
    local hash = 5381
    for i = 1, #raw do
        hash = ((hash * 33) ~ string.byte(raw, i)) & 0x7FFFFFFF
    end
    return "HW-" .. string.format("%08X", hash)
end

-- ─────────────────────────────────────────────
-- ANTI-TAMPER — basic script integrity check
-- ─────────────────────────────────────────────
local function verifyIntegrity()
    -- check we're running in the expected environment
    if not game or not game:IsA("DataModel") then return false end
    if not LocalPlayer then return false end
    -- check script source hasn't been wrapped in something weird
    if getgenv and getgenv().__QUANTUM_LOADED then
        warn("[Quantum] already loaded — preventing double execution")
        return false
    end
    return true
end

-- ─────────────────────────────────────────────
-- DESTROY OLD INSTANCE
-- ─────────────────────────────────────────────
pcall(function()
    local cg = game:GetService("CoreGui")
    local old = cg:FindFirstChild("QuantumKeySystem")
    if old then old:Destroy() end
end)

-- ─────────────────────────────────────────────
-- UI SETUP
-- ─────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumKeySystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- dim bg
local BG = Instance.new("Frame")
BG.Name = "BG"
BG.Size = UDim2.new(1,0,1,0)
BG.BackgroundColor3 = Color3.fromRGB(0,0,0)
BG.BackgroundTransparency = 0.45
BG.BorderSizePixel = 0
BG.ZIndex = 1
BG.Parent = ScreenGui

-- card (draggable)
local Card = Instance.new("Frame")
Card.Name = "Card"
Card.Size = UDim2.new(0,400,0,300)
Card.Position = UDim2.new(0.5,-200,0.5,-150)
Card.BackgroundColor3 = Color3.fromRGB(14,14,26)
Card.BorderSizePixel = 0
Card.ZIndex = 2
Card.Active = true
Card.Parent = ScreenGui
Instance.new("UICorner", Card).CornerRadius = UDim.new(0,12)
local CardStroke = Instance.new("UIStroke", Card)
CardStroke.Color = Color3.fromRGB(60,50,120)
CardStroke.Thickness = 1

-- animated gradient top border
local GradBar = Instance.new("Frame")
GradBar.Size = UDim2.new(1,0,0,2)
GradBar.BackgroundColor3 = Color3.fromRGB(124,107,255)
GradBar.BorderSizePixel = 0
GradBar.ZIndex = 5
GradBar.Parent = Card
Instance.new("UICorner", GradBar).CornerRadius = UDim.new(0,12)
-- animate the gradient bar color
task.spawn(function()
    local t = 0
    while Card.Parent do
        t = t + 0.02
        local r = math.floor(124 + 40*math.sin(t))
        local g = math.floor(107 + 30*math.cos(t*0.7))
        local b = math.floor(255 + 0)
        GradBar.BackgroundColor3 = Color3.fromRGB(r,g,b)
        task.wait(0.05)
    end
end)

-- drag logic
local dragging, dragStart, startPos = false, nil, nil
Card.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Card.Position
    end
end)
Card.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Card.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,36)
TitleBar.BackgroundColor3 = Color3.fromRGB(10,10,20)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 3
TitleBar.Parent = Card
local TitleBarCorner = Instance.new("UICorner", TitleBar)
TitleBarCorner.CornerRadius = UDim.new(0,12)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1,-40,1,0)
TitleLabel.Position = UDim2.new(0,12,0,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⬡  QUANTUM KEY SYSTEM"
TitleLabel.TextColor3 = Color3.fromRGB(124,107,255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 4
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,28,0,28)
CloseBtn.Position = UDim2.new(1,-34,0,4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255,85,102)
CloseBtn.BackgroundTransparency = 0.7
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255,85,102)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 5
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- content frame
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-48,1,-52)
Content.Position = UDim2.new(0,24,0,44)
Content.BackgroundTransparency = 1
Content.ZIndex = 3
Content.Parent = Card

local function makeLabel(parent, text, size, color, font, xalign, ypos)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,size+4)
    l.Position = UDim2.new(0,0,0,ypos)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color
    l.TextSize = size
    l.Font = font or Enum.Font.Gotham
    l.TextXAlignment = xalign or Enum.TextXAlignment.Center
    l.ZIndex = 4
    l.Parent = parent
    return l
end

local BigTitle = makeLabel(Content, "License Key", 20, Color3.fromRGB(240,240,248), Enum.Font.GothamBold, nil, 0)
local SubLabel = makeLabel(Content, "Enter your key to activate Quantum", 13, Color3.fromRGB(107,107,128), nil, nil, 26)

-- input
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1,0,0,46)
InputBox.Position = UDim2.new(0,0,0,60)
InputBox.BackgroundColor3 = Color3.fromRGB(20,20,36)
InputBox.BorderSizePixel = 0
InputBox.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
InputBox.PlaceholderColor3 = Color3.fromRGB(70,70,100)
InputBox.TextColor3 = Color3.fromRGB(240,240,248)
InputBox.TextSize = 16
InputBox.Font = Enum.Font.Code
InputBox.Text = ""
InputBox.ClearTextOnFocus = false
InputBox.ZIndex = 4
InputBox.Parent = Content
Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0,8)
local InputStroke = Instance.new("UIStroke", InputBox)
InputStroke.Color = Color3.fromRGB(60,50,120)

-- status
local StatusLabel = makeLabel(Content, "", 12, Color3.fromRGB(107,107,128), Enum.Font.Code, nil, 114)

-- activate button
local ActivateBtn = Instance.new("TextButton")
ActivateBtn.Size = UDim2.new(1,0,0,44)
ActivateBtn.Position = UDim2.new(0,0,0,138)
ActivateBtn.BackgroundColor3 = Color3.fromRGB(124,107,255)
ActivateBtn.BorderSizePixel = 0
ActivateBtn.Text = "Activate"
ActivateBtn.TextColor3 = Color3.fromRGB(255,255,255)
ActivateBtn.TextSize = 15
ActivateBtn.Font = Enum.Font.GothamBold
ActivateBtn.ZIndex = 4
ActivateBtn.Parent = Content
Instance.new("UICorner", ActivateBtn).CornerRadius = UDim.new(0,8)

-- dev label
local DevLabel = makeLabel(Content, "by Beko & Nova", 11, Color3.fromRGB(50,50,75), nil, nil, 194)

-- hwid display (small, bottom)
local HwidLabel = makeLabel(Content, "", 10, Color3.fromRGB(40,40,60), Enum.Font.Code, nil, 210)

-- ─────────────────────────────────────────────
-- AUTO FORMAT INPUT
-- ─────────────────────────────────────────────
InputBox:GetPropertyChangedSignal("Text"):Connect(function()
    local raw = InputBox.Text:upper():gsub("[^A-Z0-9]",""):sub(1,16)
    local chunks = {}
    for i = 1, #raw, 4 do chunks[#chunks+1] = raw:sub(i,i+3) end
    local fmt = table.concat(chunks, "-")
    if fmt ~= InputBox.Text then
        InputBox.Text = fmt
        InputBox.CursorPosition = #fmt + 1
    end
end)

-- ─────────────────────────────────────────────
-- HELPERS
-- ─────────────────────────────────────────────
local function setStatus(msg, r, g, b)
    StatusLabel.Text = msg
    StatusLabel.TextColor3 = Color3.fromRGB(r or 107, g or 107, b or 128)
end

local function tweenBtn(color)
    TweenService:Create(ActivateBtn, TweenInfo.new(0.2), {BackgroundColor3=color}):Play()
end

local function isExpired(info)
    if info.dur == "lifetime" then return false end
    local days = tonumber(tostring(info.dur):match("%d+"))
    if not days then return false end
    return os.time() - ((info.created or 0) / 1000) > days * 86400
end

-- ─────────────────────────────────────────────
-- VALIDATE
-- ─────────────────────────────────────────────
local busy = false
local attempts = 0
local lastAttempt = 0
local MAX_ATTEMPTS = 5
local COOLDOWN = 3

local function doActivate()
    if busy then return end

    -- rate limit
    local now = os.time()
    if now - lastAttempt < COOLDOWN then
        setStatus("// slow down...", 255, 184, 48)
        return
    end
    if attempts >= MAX_ATTEMPTS then
        setStatus("// too many attempts. wait " .. COOLDOWN .. "s", 255, 85, 102)
        return
    end

    lastAttempt = now
    attempts = attempts + 1

    local key = InputBox.Text:gsub("%s+","")
    if #key < 19 then
        setStatus("// key must be 19 characters", 255, 85, 102)
        return
    end

    local hwid = getHWID()
    HwidLabel.Text = "hwid: " .. hwid

    busy = true
    ActivateBtn.Text = "Checking..."
    tweenBtn(Color3.fromRGB(70,60,140))
    setStatus("// fetching keys...", 107, 107, 128)

    task.spawn(function()
        -- integrity check
        if not verifyIntegrity() then
            setStatus("// integrity check failed", 255, 85, 102)
            ActivateBtn.Text = "Activate"
            tweenBtn(Color3.fromRGB(124,107,255))
            busy = false
            return
        end

        -- fetch keys.json
        local body, err = httpGet(KEYS_URL)
        if not body then
            setStatus("// server error: " .. tostring(err), 255, 85, 102)
            ActivateBtn.Text = "Activate"
            tweenBtn(Color3.fromRGB(124,107,255))
            busy = false
            return
        end

        -- parse
        local ok, keys = pcall(HttpService.JSONDecode, HttpService, body)
        if not ok or type(keys) ~= "table" then
            setStatus("// failed to parse keys", 255, 85, 102)
            ActivateBtn.Text = "Activate"
            tweenBtn(Color3.fromRGB(124,107,255))
            busy = false
            return
        end

        -- lookup
        local info = keys[key]
        if not info then
            setStatus("// invalid key", 255, 85, 102)
            ActivateBtn.Text = "Activate"
            tweenBtn(Color3.fromRGB(124,107,255))
            busy = false
            return
        end

        -- expiry
        if isExpired(info) then
            setStatus("// key expired", 255, 85, 102)
            ActivateBtn.Text = "Activate"
            tweenBtn(Color3.fromRGB(124,107,255))
            busy = false
            return
        end

        -- uses
        local uses = tonumber(info.uses) or -1
        local usesLeft = tonumber(info.usesLeft) or -1
        if uses ~= -1 and usesLeft <= 0 then
            setStatus("// no uses remaining", 255, 85, 102)
            ActivateBtn.Text = "Activate"
            tweenBtn(Color3.fromRGB(124,107,255))
            busy = false
            return
        end

        -- HWID check
        local storedHwid = info.hwid
        if storedHwid and storedHwid ~= "" and storedHwid ~= hwid then
            setStatus("// hwid mismatch — key locked to another device", 255, 85, 102)
            ActivateBtn.Text = "Activate"
            tweenBtn(Color3.fromRGB(124,107,255))
            busy = false
            return
        end

        -- all checks passed
        attempts = 0
        setStatus("// key accepted — loading...", 0, 229, 192)
        ActivateBtn.Text = "Activated ✓"
        tweenBtn(Color3.fromRGB(0,150,110))

        task.wait(0.8)

        -- mark env so double-execution is blocked
        if getgenv then getgenv().__QUANTUM_LOADED = true end

        ScreenGui:Destroy()
        loadstring(game:HttpGet(SCRIPT_URL, true))()
    end)
end

ActivateBtn.MouseButton1Click:Connect(doActivate)
InputBox.FocusLost:Connect(function(enter) if enter then doActivate() end end)

-- hover effect on button
ActivateBtn.MouseEnter:Connect(function()
    if not busy then TweenService:Create(ActivateBtn, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(143,128,255)}):Play() end
end)
ActivateBtn.MouseLeave:Connect(function()
    if not busy then TweenService:Create(ActivateBtn, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(124,107,255)}):Play() end
end)

-- show hwid immediately so user can report it if needed
HwidLabel.Text = "hwid: " .. getHWID()

-- fade in animation
Card.BackgroundTransparency = 1
TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency=0}):Play()
BG.BackgroundTransparency = 1
TweenService:Create(BG, TweenInfo.new(0.3), {BackgroundTransparency=0.45}):Play()
