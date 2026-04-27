-- Quantum Key System
-- Developers: Beko & Nova

local KEYS_URL   = "https://raw.githubusercontent.com/loapse/keysystem/main/keys.json"
local SCRIPT_URL = "https://raw.githubusercontent.com/loapse/quantumkee/refs/heads/main/quantumkee.lua"

-- ─────────────────────────────────────────────
-- SERVICES
-- ─────────────────────────────────────────────
local HttpService  = game:GetService("HttpService")
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local LocalPlayer  = Players.LocalPlayer

-- ─────────────────────────────────────────────
-- HTTP — tries every known exploit method
-- ─────────────────────────────────────────────
local function httpGet(url)
    -- Xeno / Fluxus / Solara use request()
    if request then
        local ok, res = pcall(request, { Url = url, Method = "GET" })
        if ok and res and res.StatusCode == 200 then return res.Body end
    end
    if syn and syn.request then
        local ok, res = pcall(syn.request, { Url = url, Method = "GET" })
        if ok and res and res.StatusCode == 200 then return res.Body end
    end
    if http and http.request then
        local ok, res = pcall(http.request, { Url = url, Method = "GET" })
        if ok and res and res.StatusCode == 200 then return res.Body end
    end
    -- last resort
    local ok, body = pcall(function() return game:HttpGet(url, true) end)
    if ok and body and #body > 2 then return body end
    return nil
end

-- ─────────────────────────────────────────────
-- HWID
-- ─────────────────────────────────────────────
local function getHWID()
    local raw = tostring(LocalPlayer.UserId) .. tostring(LocalPlayer.AccountAge)
    local h = 5381
    for i = 1, #raw do
        h = ((h * 33) ~ string.byte(raw, i)) & 0x7FFFFFFF
    end
    return "HW-" .. string.format("%08X", h)
end

-- ─────────────────────────────────────────────
-- DESTROY OLD
-- ─────────────────────────────────────────────
for _, v in ipairs({ gethui and gethui(), pcall(game.GetService, game, "CoreGui") and game:GetService("CoreGui"), LocalPlayer:FindFirstChild("PlayerGui") }) do
    if v and typeof(v) == "Instance" then
        local old = v:FindFirstChild("QuantumKeySystem")
        if old then old:Destroy() end
    end
end

-- ─────────────────────────────────────────────
-- PARENT GUI
-- ─────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumKeySystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Enabled = true

if gethui then
    pcall(function() ScreenGui.Parent = gethui() end)
end
if not ScreenGui.Parent then
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
end
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 10)
end

-- ─────────────────────────────────────────────
-- UI
-- ─────────────────────────────────────────────
local BG = Instance.new("Frame")
BG.Size = UDim2.new(1, 0, 1, 0)
BG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BG.BackgroundTransparency = 0.4
BG.BorderSizePixel = 0
BG.ZIndex = 1
BG.Parent = ScreenGui

local Card = Instance.new("Frame")
Card.Size = UDim2.new(0, 380, 0, 260)
Card.Position = UDim2.new(0.5, -190, 0.5, -130)
Card.BackgroundColor3 = Color3.fromRGB(14, 14, 26)
Card.BorderSizePixel = 0
Card.ZIndex = 2
Card.Active = true
Card.Parent = ScreenGui
Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)

-- top accent line
local Accent = Instance.new("Frame")
Accent.Size = UDim2.new(1, 0, 0, 2)
Accent.BackgroundColor3 = Color3.fromRGB(124, 107, 255)
Accent.BorderSizePixel = 0
Accent.ZIndex = 3
Accent.Parent = Card

-- title bar (used for dragging)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.Position = UDim2.new(0, 0, 0, 2)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 22)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 3
TitleBar.Active = true
TitleBar.Parent = Card
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleTxt = Instance.new("TextLabel")
TitleTxt.Size = UDim2.new(1, -40, 1, 0)
TitleTxt.Position = UDim2.new(0, 12, 0, 0)
TitleTxt.BackgroundTransparency = 1
TitleTxt.Text = "QUANTUM KEY SYSTEM"
TitleTxt.TextColor3 = Color3.fromRGB(124, 107, 255)
TitleTxt.TextSize = 11
TitleTxt.Font = Enum.Font.Code
TitleTxt.TextXAlignment = Enum.TextXAlignment.Left
TitleTxt.ZIndex = 4
TitleTxt.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 25)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 85, 102)
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 5
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- drag
local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = Card.Position
    end
end)
TitleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Card.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- content
local function lbl(parent, text, size, color, font, ypos, xalign)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -48, 0, size + 6)
    l.Position = UDim2.new(0, 24, 0, ypos)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color
    l.TextSize = size
    l.Font = font or Enum.Font.Gotham
    l.TextXAlignment = xalign or Enum.TextXAlignment.Center
    l.TextWrapped = true
    l.ZIndex = 4
    l.Parent = parent
    return l
end

local Title   = lbl(Card, "License Key",                        20, Color3.fromRGB(240,240,248), Enum.Font.GothamBold, 44)
local Sub     = lbl(Card, "Enter your key to activate Quantum", 12, Color3.fromRGB(107,107,128), nil,                  68)

local Input = Instance.new("TextBox")
Input.Size = UDim2.new(1, -48, 0, 44)
Input.Position = UDim2.new(0, 24, 0, 96)
Input.BackgroundColor3 = Color3.fromRGB(20, 20, 36)
Input.BorderSizePixel = 0
Input.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
Input.PlaceholderColor3 = Color3.fromRGB(70, 70, 100)
Input.TextColor3 = Color3.fromRGB(240, 240, 248)
Input.TextSize = 15
Input.Font = Enum.Font.Code
Input.Text = ""
Input.ClearTextOnFocus = false
Input.ZIndex = 4
Input.Parent = Card
Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", Input).Color = Color3.fromRGB(50, 40, 100)

local Status = lbl(Card, "", 12, Color3.fromRGB(107,107,128), Enum.Font.Code, 148)

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(1, -48, 0, 42)
Btn.Position = UDim2.new(0, 24, 0, 170)
Btn.BackgroundColor3 = Color3.fromRGB(124, 107, 255)
Btn.BorderSizePixel = 0
Btn.Text = "Activate"
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.TextSize = 14
Btn.Font = Enum.Font.GothamBold
Btn.ZIndex = 4
Btn.Parent = Card
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

local DevLbl  = lbl(Card, "by Beko & Nova",  11, Color3.fromRGB(50,50,75),   nil, 220)
local HwidLbl = lbl(Card, "hwid: ...",        10, Color3.fromRGB(40,40,60),   Enum.Font.Code, 234)

-- ─────────────────────────────────────────────
-- AUTO FORMAT
-- ─────────────────────────────────────────────
Input:GetPropertyChangedSignal("Text"):Connect(function()
    local raw = Input.Text:upper():gsub("[^A-Z0-9]", ""):sub(1, 16)
    local t = {}
    for i = 1, #raw, 4 do t[#t+1] = raw:sub(i, i+3) end
    local fmt = table.concat(t, "-")
    if fmt ~= Input.Text then
        Input.Text = fmt
        Input.CursorPosition = #fmt + 1
    end
end)

-- ─────────────────────────────────────────────
-- VALIDATION
-- ─────────────────────────────────────────────
local function setStatus(msg, r, g, b)
    Status.Text = msg
    Status.TextColor3 = Color3.fromRGB(r or 107, g or 107, b or 128)
end

local function isExpired(info)
    if info.dur == "lifetime" then return false end
    local days = tonumber(tostring(info.dur):match("%d+"))
    if not days then return false end
    return os.time() - ((info.created or 0) / 1000) > days * 86400
end

local busy = false

local function activate()
    if busy then return end
    local key = Input.Text:gsub("%s+", "")
    if #key < 19 then
        setStatus("// key must be 19 characters", 255, 85, 102)
        return
    end

    busy = true
    Btn.Text = "Checking..."
    Btn.BackgroundColor3 = Color3.fromRGB(70, 60, 140)
    setStatus("// fetching keys...", 107, 107, 128)

    task.spawn(function()
        local body = httpGet(KEYS_URL)

        if not body then
            setStatus("// could not reach key server", 255, 85, 102)
            Btn.Text = "Activate"
            Btn.BackgroundColor3 = Color3.fromRGB(124, 107, 255)
            busy = false
            return
        end

        local ok, keys = pcall(HttpService.JSONDecode, HttpService, body)
        if not ok or type(keys) ~= "table" then
            setStatus("// failed to parse keys.json", 255, 85, 102)
            Btn.Text = "Activate"
            Btn.BackgroundColor3 = Color3.fromRGB(124, 107, 255)
            busy = false
            return
        end

        local info = keys[key]
        if not info then
            setStatus("// invalid key", 255, 85, 102)
            Btn.Text = "Activate"
            Btn.BackgroundColor3 = Color3.fromRGB(124, 107, 255)
            busy = false
            return
        end

        if isExpired(info) then
            setStatus("// key expired", 255, 85, 102)
            Btn.Text = "Activate"
            Btn.BackgroundColor3 = Color3.fromRGB(124, 107, 255)
            busy = false
            return
        end

        local uses = tonumber(info.uses) or -1
        local usesLeft = tonumber(info.usesLeft) or -1
        if uses ~= -1 and usesLeft <= 0 then
            setStatus("// no uses remaining", 255, 85, 102)
            Btn.Text = "Activate"
            Btn.BackgroundColor3 = Color3.fromRGB(124, 107, 255)
            busy = false
            return
        end

        local hwid = getHWID()
        local storedHwid = info.hwid
        if storedHwid and storedHwid ~= "" and storedHwid ~= hwid then
            setStatus("// hwid mismatch", 255, 85, 102)
            Btn.Text = "Activate"
            Btn.BackgroundColor3 = Color3.fromRGB(124, 107, 255)
            busy = false
            return
        end

        -- all good
        setStatus("// accepted — loading...", 0, 229, 192)
        Btn.Text = "Activated ✓"
        Btn.BackgroundColor3 = Color3.fromRGB(0, 140, 110)
        task.wait(0.6)
        ScreenGui:Destroy()
        loadstring(game:HttpGet(SCRIPT_URL, true))()
    end)
end

Btn.MouseButton1Click:Connect(activate)
Input.FocusLost:Connect(function(enter) if enter then activate() end end)

HwidLbl.Text = "hwid: " .. getHWID()
