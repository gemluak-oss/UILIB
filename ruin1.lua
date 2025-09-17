-- Vape UI Library (mod)
-- Versi asli: https://raw.githubusercontent.com/dawid-scripts/UI-Libs/refs/heads/main/Vape.txt
-- Modifikasi: Tambahkan Hide/Unhide Toggle di Window

local lib = { RainbowColorValue = 0, HueSelectionPosition = 0 }
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PresetColor = Color3.fromRGB(44, 120, 224)

local ui = Instance.new("ScreenGui")
ui.Name = "VapeUI"
ui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Rainbow update
RunService.RenderStepped:Connect(function(dt)
    lib.RainbowColorValue = (lib.RainbowColorValue + dt * 1) % 1
    lib.HueSelectionPosition = (lib.HueSelectionPosition + dt * 80) % 80
end)

-- fungsi draggable
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
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Window
function lib:Window(title)
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Main.BorderSizePixel = 0
    Main.Size = UDim2.new(0, 560, 0, 320)
    Main.Position = UDim2.new(0.5, -280, 0.5, -160)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.ClipsDescendants = true
    Main.Parent = ui

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Main

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -50, 1, 0)
    TitleLbl.Position = UDim2.new(0, 10, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title or "Vape UI"
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 18
    TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = TopBar

    -- Tombol hide
    local HideBtn = Instance.new("TextButton")
    HideBtn.Size = UDim2.new(0, 30, 0, 30)
    HideBtn.Position = UDim2.new(1, -35, 0, 5)
    HideBtn.Text = "–"
    HideBtn.Font = Enum.Font.GothamBold
    HideBtn.TextSize = 18
    HideBtn.TextColor3 = Color3.fromRGB(255,255,255)
    HideBtn.BackgroundTransparency = 1
    HideBtn.Parent = TopBar

    -- Tombol unhide
    local UnhideBtn = Instance.new("TextButton")
    UnhideBtn.Size = UDim2.new(0, 60, 0, 25)
    UnhideBtn.Position = UDim2.new(0, 10, 0, 10)
    UnhideBtn.Text = "☰ Menu"
    UnhideBtn.Font = Enum.Font.GothamBold
    UnhideBtn.TextSize = 14
    UnhideBtn.TextColor3 = Color3.fromRGB(255,255,255)
    UnhideBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    UnhideBtn.Visible = false
    UnhideBtn.Parent = ui

    HideBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
        HideBtn.Visible = false
        UnhideBtn.Visible = true
    end)
    UnhideBtn.MouseButton1Click:Connect(function()
        Main.Visible = true
        HideBtn.Visible = true
        UnhideBtn.Visible = false
    end)

    MakeDraggable(TopBar, Main)

    -- Container tab kiri
    local TabHold = Instance.new("Frame")
    TabHold.Size = UDim2.new(0, 120, 1, -40)
    TabHold.Position = UDim2.new(0, 0, 0, 40)
    TabHold.BackgroundTransparency = 1
    TabHold.Parent = Main

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabHold
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 8)

    -- Konten kanan
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -120, 1, -40)
    ContentArea.Position = UDim2.new(0, 120, 0, 40)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = Main

    -- Tab API
    local Window = {}
    Window.__index = Window

    function Window:Tab(tabName)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.Text = tabName
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Parent = TabHold

        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabFrame.ScrollBarThickness = 4
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = false
        tabFrame.Parent = ContentArea

        local layout = Instance.new("UIListLayout")
        layout.Parent = tabFrame
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            for _, child in ipairs(ContentArea:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            for _, b in ipairs(TabHold:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
                    b.TextColor3 = Color3.fromRGB(200,200,200)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            tabFrame.Visible = true
        end)

        local tabObj = {}

        function tabObj:Button(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -10, 0, 30)
            b.BackgroundColor3 = Color3.fromRGB(45,45,45)
            b.Text = text
            b.Font = Enum.Font.Gotham
            b.TextSize = 14
            b.TextColor3 = Color3.fromRGB(240,240,240)
            b.Parent = tabFrame
            b.MouseButton1Click:Connect(callback)
        end

        return tabObj
    end

    return Window
end

return lib
