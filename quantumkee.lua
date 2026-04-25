-- Quantum Key System
-- Developers: Beko & Nova

-- ──────────────────────────────────────────────
-- CONFIG — edit these two lines
-- ──────────────────────────────────────────────
local KEYS_URL   = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/keys.json"
local SCRIPT_URL = "https://raw.githubusercontent.com/loapse/Quantum/refs/heads/main/Quantum.lua"

-- ──────────────────────────────────────────────
-- HTTP — works on all major exploits
-- ──────────────────────────────────────────────
local function httpGet(url)
    -- syn / KRNL / Script-Ware / Fluxus all expose one of these
    if syn and syn.request then
        local res = syn.request({ Url = url, Method = "GET" })
        if res and res.StatusCode == 200 then return res.Body end
        return nil, "status " .. tostring(res and res.StatusCode)
    elseif http and http.request then
        local res = http.request({ Url = url, Method = "GET" })
        if res and res.StatusCode == 200 then return res.Body end
        return nil, "status " .. tostring(res and res.StatusCode)
    elseif request then
        local res = request({ Url = url, Method = "GET" })
        if res and res.StatusCode == 200 then return res.Body end
        return nil, "status " .. tostring(res and res.StatusCode)
    elseif game and game.HttpGet then
        -- fallback for some envs
        local ok, body = pcall(function() return game:HttpGet(url) end)
        if ok and body and #body > 0 then return body end
        return nil, "HttpGet failed"
    end
    return nil, "no http function found"
end

-- ──────────────────────────────────────────────
-- UI
-- ──────────────────────────────────────────────
local HttpService = game:GetService("HttpService")

-- remove any existing instance
pcall(function()
    local old = game:GetService("CoreGui"):FindFirstChild("QuantumKeySystem")
    if old then old:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumKeySystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui end

-- Dim background
local BG = Instance.new("Frame")
BG.Size = UDim2.new(1, 0, 1, 0)
BG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BG.BackgroundTransparency = 0.5
BG.BorderSizePixel = 0
BG.ZIndex = 1
BG.Parent = ScreenGui

-- Card
local Card = Instance.new("Frame")
Card.Size = UDim2.new(0, 380, 0, 290)
Card.Position = UDim2.new(0.5, -190, 0.5, -145)
Card.BackgroundColor3 = Color3.fromRGB(14, 14, 26)
Card.BorderSizePixel = 0
Card.ZIndex = 2
Card.Parent = ScreenGui
Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke", Card)
Stroke.Color = Color3.fromRGB(60, 50, 120)
Stroke.Thickness = 1

-- Accent bar
local AccentBar = Instance.new("Frame")
AccentBar.Size = UDim2.new(1, 0, 0, 2)
AccentBar.Position = UDim2.new(0, 0, 0, 0)
AccentBar.BackgroundColor3 = Color3.fromRGB(124, 107, 255)
AccentBar.BorderSizePixel = 0
AccentBar.ZIndex = 3
AccentBar.Parent = Card
Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.Position = UDim2.new(0, 0, 0, 24)
Title.BackgroundTransparency = 1
Title.Text = "Quantum Key System"
Title.TextColor3 = Color3.fromRGB(240, 240, 248)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 3
Title.Parent = Card

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(1, 0, 0, 22)
Sub.Position = UDim2.new(0, 0, 0, 60)
Sub.BackgroundTransparency = 1
Sub.Text = "Enter your license key to continue"
Sub.TextColor3 = Color3.fromRGB(107, 107, 128)
Sub.TextSize = 13
Sub.Font = Enum.Font.Gotham
Sub.ZIndex = 3
Sub.Parent = Card

-- Input
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -48, 0, 46)
InputBox.Position = UDim2.new(0, 24, 0, 100)
InputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 36)
InputBox.BorderSizePixel = 0
InputBox.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
InputBox.PlaceholderColor3 = Color3.fromRGB(70, 70, 100)
InputBox.TextColor3 = Color3.fromRGB(240, 240, 248)
InputBox.TextSize = 16
InputBox.Font = Enum.Font.Code
InputBox.Text = ""
InputBox.ClearTextOnFocus = false
InputBox.ZIndex = 3
InputBox.Parent = Card
Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 8)
local InputStroke = Instance.new("UIStroke", InputBox)
InputStroke.Color = Color3.fromRGB(60, 50, 120)

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -48, 0, 22)
Status.Position = UDim2.new(0, 24, 0, 154)
Status.BackgroundTransparency = 1
Status.Text = ""
Status.TextColor3 = Color3.fromRGB(107, 107, 128)
Status.TextSize = 12
Status.Font = Enum.Font.Code
Status.TextXAlignment = Enum.TextXAlignment.Center
Status.ZIndex = 3
Status.Parent = Card

-- Button
local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(1, -48, 0, 46)
Btn.Position = UDim2.new(0, 24, 0, 186)
Btn.BackgroundColor3 = Color3.fromRGB(124, 107, 255)
Btn.BorderSizePixel = 0
Btn.Text = "Activate"
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.TextSize = 15
Btn.Font = Enum.Font.GothamBold
Btn.ZIndex = 3
Btn.Parent = Card
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

local DevLabel = Instance.new("TextLabel")
DevLabel.Size = UDim2.new(1, 0, 0, 20)
DevLabel.Position = UDim2.new(0, 0, 0, 258)
DevLabel.BackgroundTransparency = 1
DevLabel.Text = "by Beko & Nova"
DevLabel.TextColor3 = Color3.fromRGB(50, 50, 75)
DevLabel.TextSize = 11
DevLabel.Font = Enum.Font.Gotham
DevLabel.ZIndex = 3
DevLabel.Parent = Card

-- ──────────────────────────────────────────────
-- AUTO FORMAT  XXXX-XXXX-XXXX-XXXX
-- ──────────────────────────────────────────────
InputBox:GetPropertyChangedSignal("Text"):Connect(function()
    local raw = InputBox.Text:upper():gsub("[^A-Z0-9]", ""):sub(1, 16)
    local chunks = {}
    for i = 1, #raw, 4 do
        chunks[#chunks + 1] = raw:sub(i, i + 3)
    end
    local formatted = table.concat(chunks, "-")
    if formatted ~= InputBox.Text then
        InputBox.Text = formatted
        InputBox.CursorPosition = #formatted + 1
    end
end)

-- ──────────────────────────────────────────────
-- VALIDATION
-- ──────────────────────────────────────────────
local function setStatus(msg, r, g, b)
    Status.Text = msg
    Status.TextColor3 = Color3.fromRGB(r or 107, g or 107, b or 128)
end

local function isExpired(info)
    if info.dur == "lifetime" then return false end
    local days = tonumber(tostring(info.dur):match("%d+"))
    if not days then return false end
    local createdSec = (info.created or 0) / 1000  -- JS ms -> seconds
    return os.time() - createdSec > days * 86400
end

local function validate(key)
    setStatus("// fetching keys...", 107, 107, 128)

    local body, err = httpGet(KEYS_URL)
    if not body then
        setStatus("// could not reach key server: " .. tostring(err), 255, 85, 102)
        return false
    end

    -- parse JSON
    local ok, keys = pcall(HttpService.JSONDecode, HttpService, body)
    if not ok or type(keys) ~= "table" then
        setStatus("// failed to parse keys.json", 255, 85, 102)
        return false
    end

    local info = keys[key]
    if not info then
        setStatus("// invalid key", 255, 85, 102)
        return false
    end

    if isExpired(info) then
        setStatus("// key expired", 255, 85, 102)
        return false
    end

    local uses = tonumber(info.uses) or -1
    local usesLeft = tonumber(info.usesLeft) or -1
    if uses ~= -1 and usesLeft <= 0 then
        setStatus("// no uses remaining", 255, 85, 102)
        return false
    end

    return true
end

-- ──────────────────────────────────────────────
-- BUTTON
-- ──────────────────────────────────────────────
local busy = false

local function doActivate()
    if busy then return end
    local key = InputBox.Text:gsub("%s+", "")
    if #key < 19 then
        setStatus("// key must be 19 characters", 255, 85, 102)
        return
    end

    busy = true
    Btn.Text = "Checking..."
    Btn.BackgroundColor3 = Color3.fromRGB(70, 60, 140)
    setStatus("// validating...", 107, 107, 128)

    task.spawn(function()
        local ok = validate(key)
        if ok then
            setStatus("// accepted — loading Quantum...", 0, 229, 192)
            Btn.Text = "Activated ✓"
            Btn.BackgroundColor3 = Color3.fromRGB(0, 140, 110)
            task.wait(0.8)
            ScreenGui:Destroy()
            loadstring(game:HttpGet(SCRIPT_URL, true))()
        else
            Btn.Text = "Activate"
            Btn.BackgroundColor3 = Color3.fromRGB(124, 107, 255)
            busy = false
        end
    end)
end

Btn.MouseButton1Click:Connect(doActivate)
InputBox.FocusLost:Connect(function(enter) if enter then doActivate() end end)
