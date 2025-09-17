-- ui_framework.lua
-- Minimal UI Framework dengan Rainbow Theme + Hide/Unhide
-- Raditya Nugroho Saputro

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UI = {}
UI.__index = UI

-- internal state
local windows = {}
local registeredThemedElements = {}
local rainbow = { enabled = true, speed = 0.2, hue = 0 }

local function safeSet(inst, prop, value)
    if inst and inst:IsA("Instance") and inst[prop] ~= nil then
        pcall(function() inst[prop] = value end)
    end
end

local function applyTheme(color3)
    for inst, info in pairs(registeredThemedElements) do
        if inst and inst.Parent then
            safeSet(inst, info.prop, color3)
        end
    end
end

-- Rainbow loop
task.spawn(function()
    while true do
        if rainbow.enabled then
            local dt = RunService.Heartbeat:Wait()
            rainbow.hue = (rainbow.hue + rainbow.speed * (dt or 0.016)) % 1
            local c = Color3.fromHSV(rainbow.hue, 0.9, 0.95)
            applyTheme(c)
        else
            task.wait(0.1)
        end
    end
end)

function UI._registerThemedElement(inst, prop)
    if not inst then return end
    registeredThemedElements[inst] = { prop = prop or "BackgroundColor3" }
end

local function newScreenGui(name)
    local sg = Instance.new("ScreenGui")
    sg.Name = name or ("UIFramework_" .. tostring(math.random(1000)))
    sg.ResetOnSpawn = false
    sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    return sg
end

local function makeFrame(parent, size, pos)
    local f = Instance.new("Frame")
    f.Size = size or UDim2.new(0, 420, 0, 360)
    f.Position = pos or UDim2.new(0.5, -210, 0.5, -180)
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.BorderSizePixel = 0
    f.Parent = parent
    UI._registerThemedElement(f, "BackgroundColor3")
    return f
end

local function makeLabel(parent, text, sizeY)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 0, sizeY or 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text or ""
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(230,230,230)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.Parent = parent
    return lbl
end

-- Window class
local Window = {}
Window.__index = Window

function UI:CreateWindow(opts)
    opts = opts or {}
    local name = opts.Name or "Window"
    local screen = newScreenGui("UIFramework_" .. name)
    local root = makeFrame(screen)

    -- header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 34)
    header.BorderSizePixel = 0
    header.Parent = root
    UI._registerThemedElement(header, "BackgroundColor3")

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -12, 1, 0)
    title.Position = UDim2.new(0, 6, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.fromRGB(245,245,245)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local content = Instance.new("Frame")
    content.Position = UDim2.new(0, 8, 0, 40)
    content.Size = UDim2.new(1, -16, 1, -48)
    content.BackgroundTransparency = 1
    content.Parent = root

    local leftCol = Instance.new("Frame")
    leftCol.Size = UDim2.new(1, 0, 1, 0)
    leftCol.BackgroundTransparency = 1
    leftCol.Parent = content

    -- Hide Button
    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.new(0, 22, 0, 22)
    hideBtn.Position = UDim2.new(1, -26, 0, 6)
    hideBtn.Text = "–"
    hideBtn.Font = Enum.Font.GothamBold
    hideBtn.TextSize = 14
    hideBtn.TextColor3 = Color3.fromRGB(245,245,245)
    hideBtn.Parent = header
    UI._registerThemedElement(hideBtn, "BackgroundColor3")

    -- Unhide Button
    local unhideBtn = Instance.new("TextButton")
    unhideBtn.Size = UDim2.new(0, 40, 0, 24)
    unhideBtn.Position = UDim2.new(0, 8, 0, 8)
    unhideBtn.Text = "☰"
    unhideBtn.Font = Enum.Font.GothamBold
    unhideBtn.TextSize = 16
    unhideBtn.TextColor3 = Color3.fromRGB(245,245,245)
    unhideBtn.Visible = false
    unhideBtn.Parent = screen
    UI._registerThemedElement(unhideBtn, "BackgroundColor3")

    hideBtn.MouseButton1Click:Connect(function()
        root.Visible = false
        hideBtn.Visible = false
        unhideBtn.Visible = true
    end)
    unhideBtn.MouseButton1Click:Connect(function()
        root.Visible = true
        hideBtn.Visible = true
        unhideBtn.Visible = false
    end)

    -- simple drag
    do
        local dragging, dragStart, startPos
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = root.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        header.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local delta = input.Position - dragStart
                root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    local self = setmetatable({
        Name = name,
        ScreenGui = screen,
        Root = root,
        Tabs = {},
    }, Window)

    function self:CreateTab(title)
        local tab = { Title = title }
        local secFrame = Instance.new("Frame")
        secFrame.Size = UDim2.new(1, 0, 0, 0)
        secFrame.BackgroundTransparency = 1
        secFrame.Parent = leftCol

        local titleLbl = makeLabel(secFrame, title, 22)
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 15

        function tab:CreateParagraph(opts)
            local p = Instance.new("TextLabel")
            p.Size = UDim2.new(1, -6, 0, 40)
            p.BackgroundTransparency = 1
            p.TextWrapped = true
            p.Text = opts.Content or ""
            p.TextColor3 = Color3.fromRGB(225,225,225)
            p.Font = Enum.Font.Gotham
            p.TextSize = 13
            p.Parent = secFrame
            return p
        end

        function tab:CreateToggle(opts)
            opts = opts or {}
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 30)
            container.BackgroundTransparency = 1
            container.Parent = secFrame

            local lbl = makeLabel(container, opts.Name or "Toggle", 20)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 80, 0, 22)
            btn.Position = UDim2.new(1, -84, 0, 4)
            btn.Text = opts.CurrentValue and "On" or "Off"
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 12
            btn.Parent = container
            UI._registerThemedElement(btn, "BackgroundColor3")
            btn.MouseButton1Click:Connect(function()
                opts.CurrentValue = not opts.CurrentValue
                btn.Text = opts.CurrentValue and "On" or "Off"
                if opts.Callback then pcall(opts.Callback, opts.CurrentValue) end
            end)
            return btn
        end

        function tab:CreateInput(opts)
            opts = opts or {}
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 34)
            container.BackgroundTransparency = 1
            container.Parent = secFrame

            local lbl = makeLabel(container, opts.Name or "Input", 14)

            local tb = Instance.new("TextBox")
            tb.Size = UDim2.new(1, -6, 0, 20)
            tb.Position = UDim2.new(0, 6, 0, 14)
            tb.Text = opts.CurrentValue or ""
            tb.ClearTextOnFocus = false
            tb.Font = Enum.Font.Gotham
            tb.TextSize = 14
            tb.Parent = container

            tb.FocusLost:Connect(function()
                if opts.Callback then pcall(opts.Callback, tb.Text) end
            end)
            return tb
        end

        table.insert(self.Tabs, tab)
        return tab
    end

    return self
end

-- Simple notification
function UI.Notify(opts)
    local sg = newScreenGui("NotifGui")
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 300, 0, 60)
    f.Position = UDim2.new(0.5, -150, 0.15, 0)
    f.AnchorPoint = Vector2.new(0.5, 0)
    f.Parent = sg
    UI._registerThemedElement(f, "BackgroundColor3")

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 20)
    title.Position = UDim2.new(0, 5, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = opts.Title or "Notification"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(245,245,245)
    title.Parent = f

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1, -10, 0, 30)
    body.Position = UDim2.new(0, 5, 0, 26)
    body.BackgroundTransparency = 1
    body.Text = opts.Content or ""
    body.Font = Enum.Font.Gotham
    body.TextSize = 13
    body.TextColor3 = Color3.fromRGB(230,230,230)
    body.Parent = f

    delay(opts.Duration or 3, function() sg:Destroy() end)
end

function UI.SetRainbow(enabled, speed)
    rainbow.enabled = enabled == nil and true or enabled
    if type(speed) == "number" then rainbow.speed = speed end
end

return UI
