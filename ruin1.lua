-- Sidebar UI Framework
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Framework = {}
Framework.__index = Framework

local function MakeDraggable(topbar, frame)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
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
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Framework:CreateWindow(title)
    local gui = Instance.new("ScreenGui")
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 600, 0, 350)
    main.Position = UDim2.new(0.5, -300, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    main.Parent = gui

    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 30)
    topbar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    topbar.Parent = main

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -10, 1, 0)
    titleLbl.Position = UDim2.new(0, 5, 0, 0)
    titleLbl.Text = title or "Framework"
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = topbar

    MakeDraggable(topbar, main)

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 160, 1, -30)
    sidebar.Position = UDim2.new(0, 0, 0, 30)
    sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    sidebar.Parent = main

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -160, 1, -30)
    content.Position = UDim2.new(0, 160, 0, 30)
    content.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    content.Parent = main

    local tabHolder = Instance.new("Frame")
    tabHolder.Size = UDim2.new(1, 0, 1, 0)
    tabHolder.BackgroundTransparency = 1
    tabHolder.Parent = sidebar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabHolder
    tabLayout.Padding = UDim.new(0, 5)

    local self = setmetatable({
        Main = main,
        Sidebar = sidebar,
        Content = content,
        Tabs = {},
    }, Framework)

    function self:CreateTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.Text = name
        btn.Font = Enum.Font.Gotham
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Parent = tabHolder

        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabFrame.ScrollBarThickness = 4
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = false
        tabFrame.Parent = content

        local layout = Instance.new("UIListLayout")
        layout.Parent = tabFrame
        layout.Padding = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(self.Tabs) do
                t.Frame.Visible = false
            end
            tabFrame.Visible = true
        end)

        local tabObj = {
            Button = btn,
            Frame = tabFrame,
        }
        table.insert(self.Tabs, tabObj)

        function tabObj:Button(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -10, 0, 30)
            b.Text = text
            b.Font = Enum.Font.Gotham
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            b.Parent = tabFrame
            b.MouseButton1Click:Connect(callback)
        end

        function tabObj:Label(text)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -10, 0, 25)
            l.Text = text
            l.Font = Enum.Font.Gotham
            l.TextColor3 = Color3.fromRGB(200, 200, 200)
            l.BackgroundTransparency = 1
            l.Parent = tabFrame
        end

        return tabObj
    end

    return self
end

return Framework
