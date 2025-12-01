-- Modern Minimalist UI Library V2
-- Created by ChatGPT (custom remake)

local UI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Draggable helper
local function MakeDraggable(trigger, object)
    local dragging = false
    local dragStart, startPos

    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    trigger.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end


function UI:Window(title)
    local Screen = Instance.new("ScreenGui")
    Screen.Name = "ModernUI"
    Screen.Parent = LocalPlayer:WaitForChild("PlayerGui")
    Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Window
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 600, 0, 365)
    Main.Position = UDim2.new(0.5, -300, 0.5, -180)
    Main.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Main.BorderSizePixel = 0
    Main.Parent = Screen
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

    -- Top Bar
    local Top = Instance.new("Frame")
    Top.Size = UDim2.new(1, 0, 0, 42)
    Top.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    Top.BorderSizePixel = 0
    Top.Parent = Main
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 16, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Modern UI"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Top

    -- Close Button
    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 32, 0, 32)
    Close.Position = UDim2.new(1, -40, 0, 5)
    Close.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Close.Text = "✕"
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 14
    Close.TextColor3 = Color3.fromRGB(255, 130, 130)
    Close.Parent = Top
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

    Close.MouseButton1Click:Connect(function()
        Screen:Destroy()
    end)

    -- Hide button
    local Hide = Instance.new("TextButton")
    Hide.Size = UDim2.new(0, 32, 0, 32)
    Hide.Position = UDim2.new(1, -80, 0, 5)
    Hide.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Hide.Text = "–"
    Hide.Font = Enum.Font.GothamBold
    Hide.TextSize = 16
    Hide.TextColor3 = Color3.fromRGB(255,255,255)
    Hide.Parent = Top
    Instance.new("UICorner", Hide).CornerRadius = UDim.new(0, 6)

    local unhideBtn = Instance.new("TextButton")
    unhideBtn.Size = UDim2.new(0, 100, 0, 32)
    unhideBtn.Position = UDim2.new(0, 10, 0, 10)
    unhideBtn.Text = "☰ Open Menu"
    unhideBtn.Font = Enum.Font.GothamBold
    unhideBtn.TextSize = 14
    unhideBtn.TextColor3 = Color3.fromRGB(255,255,255)
    unhideBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    unhideBtn.Visible = false
    unhideBtn.Parent = Screen
    Instance.new("UICorner", unhideBtn).CornerRadius = UDim.new(0, 6)

    Hide.MouseButton1Click:Connect(function()
        Main.Visible = false
        Hide.Visible = false
        unhideBtn.Visible = true
    end)
    unhideBtn.MouseButton1Click:Connect(function()
        Main.Visible = true
        Hide.Visible = true
        unhideBtn.Visible = false
    end)

    MakeDraggable(Top, Main)

    -- Sidebar
    local Side = Instance.new("Frame")
    Side.Size = UDim2.new(0, 130, 1, -42)
    Side.Position = UDim2.new(0, 0, 0, 42)
    Side.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    Side.BorderSizePixel = 0
    Side.Parent = Main

    local SideList = Instance.new("UIListLayout")
    SideList.SortOrder = Enum.SortOrder.LayoutOrder
    SideList.Padding = UDim.new(0, 6)
    SideList.Parent = Side

    -- Content Area
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -130, 1, -42)
    Content.Position = UDim2.new(0, 130, 0, 42)
    Content.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    Content.BorderSizePixel = 0
    Content.Parent = Main

    local Window = {}

    function Window:Tab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -12, 0, 36)
        TabBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextSize = 14
        TabBtn.TextColor3 = Color3.fromRGB(220,220,220)
        TabBtn.Parent = Side
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.ScrollBarThickness = 4
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.Visible = false
        TabPage.Parent = Content

        local Layout = Instance.new("UIListLayout")
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 8)
        Layout.Parent = TabPage

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in ipairs(Content:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            for _, b in ipairs(Side:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
                    b.TextColor3 = Color3.fromRGB(220,220,220)
                end
            end
            TabBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
            TabBtn.TextColor3 = Color3.fromRGB(255,255,255)
            TabPage.Visible = true
        end)

        local API = {}

        function API:Button(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -14, 0, 36)
            b.BackgroundColor3 = Color3.fromRGB(40,40,40)
            b.Text = text
            b.Font = Enum.Font.Gotham
            b.TextSize = 14
            b.TextColor3 = Color3.fromRGB(240,240,240)
            b.Parent = TabPage
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

            b.MouseButton1Click:Connect(callback)
        end

        return API
    end

    return Window
end

return UI
