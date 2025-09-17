-- framework.lua
-- Simple Responsive UI Library

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local lib = {}

-- Fungsi draggable
local function MakeDraggable(dragHandle, object)
    local dragging, dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Window
function lib:Window(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 520, 0, 340)
    Main.Position = UDim2.new(0.5, -260, 0.5, -170)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 34)
    Topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Text = title or "UI Framework"
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 8, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.Parent = Topbar

    -- Hide button
    local HideBtn = Instance.new("TextButton")
    HideBtn.Text = "–"
    HideBtn.Size = UDim2.new(0, 32, 0, 32)
    HideBtn.Position = UDim2.new(1, -36, 0, 0)
    HideBtn.Font = Enum.Font.GothamBold
    HideBtn.TextSize = 18
    HideBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    HideBtn.BackgroundTransparency = 1
    HideBtn.Parent = Topbar

    -- Tab Holder
    local TabButtons = Instance.new("Frame")
    TabButtons.Size = UDim2.new(0, 120, 1, -34)
    TabButtons.Position = UDim2.new(0, 0, 0, 34)
    TabButtons.BackgroundTransparency = 1
    TabButtons.Parent = Main

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabButtons
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local TabFolder = Instance.new("Frame")
    TabFolder.Size = UDim2.new(1, -120, 1, -34)
    TabFolder.Position = UDim2.new(0, 120, 0, 34)
    TabFolder.BackgroundTransparency = 1
    TabFolder.Parent = Main

    local tabs = {}

    function tabs:Tab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -10, 0, 28)
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextSize = 14
        TabBtn.TextColor3 = Color3.fromRGB(220,220,220)
        TabBtn.Parent = TabButtons

        local Container = Instance.new("ScrollingFrame")
        Container.Size = UDim2.new(1, 0, 1, 0)
        Container.BackgroundTransparency = 1
        Container.Visible = false
        Container.CanvasSize = UDim2.new(0,0,0,0)
        Container.ScrollBarThickness = 4
        Container.Parent = TabFolder

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 6)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = Container

        local function updateSize()
            Container.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
        end
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

        TabBtn.MouseButton1Click:Connect(function()
            for _,child in pairs(TabFolder:GetChildren()) do
                if child:IsA("ScrollingFrame") then child.Visible = false end
            end
            Container.Visible = true
        end)

        -- auto select first tab
        if #TabButtons:GetChildren() == 1 then
            Container.Visible = true
        end

        local elements = {}

        function elements:Label(text)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -10, 0, 24)
            lbl.BackgroundColor3 = Color3.fromRGB(40,40,40)
            lbl.Text = text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextColor3 = Color3.fromRGB(230,230,230)
            lbl.Parent = Container
            return lbl
        end

        function elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            btn.Text = text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.TextColor3 = Color3.fromRGB(240,240,240)
            btn.Parent = Container
            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        function elements:Toggle(text, callback)
            local toggled = false
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            btn.Text = text .. ": Off"
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.TextColor3 = Color3.fromRGB(240,240,240)
            btn.Parent = Container
            btn.MouseButton1Click:Connect(function()
                toggled = not toggled
                btn.Text = text .. ": " .. (toggled and "On" or "Off")
                if callback then callback(toggled) end
            end)
            return btn
        end

        function elements:Textbox(placeholder, callback)
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -10, 0, 28)
            box.BackgroundColor3 = Color3.fromRGB(50,50,50)
            box.PlaceholderText = placeholder
            box.Text = ""
            box.Font = Enum.Font.Gotham
            box.TextSize = 14
            box.TextColor3 = Color3.fromRGB(240,240,240)
            box.Parent = Container
            box.FocusLost:Connect(function()
                if callback then callback(box.Text) end
            end)
            return box
        end

        return elements
    end

    -- draggable + hide
    MakeDraggable(Topbar, Main)
    HideBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)

    return tabs
end

return lib
