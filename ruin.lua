-- vape_ui.lua (mod tanpa colorpicker / rainbow)

local lib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local PresetColor = Color3.fromRGB(44, 120, 224)
local CloseBind = Enum.KeyCode.RightControl

local ui = Instance.new("ScreenGui")
ui.Name = "ui"
ui.Parent = game.CoreGui
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- draggable helper
local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition
    local function Update(input)
        local Delta = input.Position - DragStart
        object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
    end
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then Update(input) end
    end)
end

function lib:Window(text, preset, closebind)
    CloseBind = closebind or Enum.KeyCode.RightControl
    PresetColor = preset or PresetColor
    local Main = Instance.new("Frame")
    local TabHold = Instance.new("Frame")
    local TabHoldLayout = Instance.new("UIListLayout")
    local Title = Instance.new("TextLabel")
    local TabFolder = Instance.new("Folder")
    local DragFrame = Instance.new("Frame")

    Main.Name = "Main"
    Main.Parent = ui
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.ClipsDescendants = true

    TabHold.Parent = Main
    TabHold.BackgroundTransparency = 1
    TabHold.Position = UDim2.new(0.03, 0, 0.15, 0)
    TabHold.Size = UDim2.new(0, 107, 0, 254)
    TabHoldLayout.Parent = TabHold
    TabHoldLayout.Padding = UDim.new(0, 11)

    Title.Parent = Main
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.03, 0, 0.05, 0)
    Title.Size = UDim2.new(0, 200, 0, 23)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = text
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    DragFrame.Parent = Main
    DragFrame.BackgroundTransparency = 1
    DragFrame.Size = UDim2.new(0, 560, 0, 41)
    Main:TweenSize(UDim2.new(0, 560, 0, 319), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .6, true)
    MakeDraggable(DragFrame, Main)

    -- hide/unhide dengan RightControl
    local hidden = false
    UserInputService.InputBegan:Connect(function(io,gp)
        if io.KeyCode == CloseBind then
            if not hidden then
                Main:TweenSize(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .5,true,function()
                    ui.Enabled = false
                end)
            else
                ui.Enabled = true
                Main:TweenSize(UDim2.new(0,560,0,319), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .5,true)
            end
            hidden = not hidden
        end
    end)

    TabFolder.Parent = Main

    local tabhold = {}
    function tabhold:Tab(name)
        local TabBtn = Instance.new("TextButton")
        local TabTitle = Instance.new("TextLabel")
        local Indicator = Instance.new("Frame")

        TabBtn.Parent = TabHold
        TabBtn.Size = UDim2.new(0, 107, 0, 21)
        TabBtn.BackgroundTransparency = 1
        TabTitle.Parent = TabBtn
        TabTitle.Size = UDim2.new(0,107,0,21)
        TabTitle.Font = Enum.Font.Gotham
        TabTitle.Text = name
        TabTitle.TextColor3 = Color3.fromRGB(200,200,200)
        Indicator.Parent = TabBtn
        Indicator.BackgroundColor3 = PresetColor
        Indicator.BorderSizePixel = 0
        Indicator.Position = UDim2.new(0,0,1,0)
        Indicator.Size = UDim2.new(0,0,0,2)

        local Tab = Instance.new("ScrollingFrame")
        Tab.Parent = TabFolder
        Tab.Size = UDim2.new(0,373,0,254)
        Tab.Position = UDim2.new(0.31,0,0.15,0)
        Tab.BackgroundTransparency = 1
        Tab.ScrollBarThickness = 3
        Tab.Visible = false
        local layout = Instance.new("UIListLayout", Tab)
        layout.Padding = UDim.new(0,6)

        if TabFolder:FindFirstChild("Tab") == nil then
            Tab.Visible = true
            Indicator.Size = UDim2.new(0,13,0,2)
            TabTitle.TextColor3 = Color3.new(1,1,1)
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _,c in ipairs(TabFolder:GetChildren()) do if c:IsA("ScrollingFrame") then c.Visible=false end end
            Tab.Visible=true
        end)

        local content = {}
        function content:Button(text,cb)
            local b = Instance.new("TextButton",Tab)
            b.Size = UDim2.new(0,363,0,42)
            b.BackgroundColor3=Color3.fromRGB(34,34,34)
            b.Text=""
            local t=Instance.new("TextLabel",b)
            t.Size=UDim2.new(1,-10,1,0)
            t.BackgroundTransparency=1
            t.Text=text
            t.TextColor3=Color3.new(1,1,1)
            t.Font=Enum.Font.Gotham
            t.TextSize=14
            b.MouseButton1Click:Connect(function() pcall(cb) end)
        end
        function content:Toggle(text,default,cb)
            local on=default or false
            local b=Instance.new("TextButton",Tab)
            b.Size=UDim2.new(0,363,0,42)
            b.BackgroundColor3=Color3.fromRGB(34,34,34)
            b.Text=""
            local t=Instance.new("TextLabel",b)
            t.Size=UDim2.new(1,-50,1,0)
            t.BackgroundTransparency=1
            t.Text=text
            t.TextColor3=Color3.new(1,1,1)
            t.Font=Enum.Font.Gotham
            t.TextSize=14
            local state=Instance.new("TextLabel",b)
            state.Size=UDim2.new(0,40,1,0)
            state.Position=UDim2.new(1,-40,0,0)
            state.BackgroundTransparency=1
            state.Text=(on and "ON" or "OFF")
            state.TextColor3=Color3.new(1,1,1)
            b.MouseButton1Click:Connect(function()
                on=not on
                state.Text=(on and "ON" or "OFF")
                if cb then pcall(cb,on) end
            end)
        end
        function content:Label(text)
            local l=Instance.new("TextLabel",Tab)
            l.Size=UDim2.new(0,363,0,30)
            l.BackgroundTransparency=1
            l.Text=text
            l.TextColor3=Color3.new(1,1,1)
            l.Font=Enum.Font.Gotham
            l.TextSize=14
            l.TextXAlignment=Enum.TextXAlignment.Left
        end
        function content:Textbox(text,cb)
            local f=Instance.new("Frame",Tab)
            f.Size=UDim2.new(0,363,0,42)
            f.BackgroundColor3=Color3.fromRGB(34,34,34)
            local lbl=Instance.new("TextLabel",f)
            lbl.Size=UDim2.new(0.5,0,1,0)
            lbl.BackgroundTransparency=1
            lbl.Text=text
            lbl.TextColor3=Color3.new(1,1,1)
            lbl.Font=Enum.Font.Gotham
            lbl.TextSize=14
            lbl.TextXAlignment=Enum.TextXAlignment.Left
            local box=Instance.new("TextBox",f)
            box.Size=UDim2.new(0.5,-10,1,0)
            box.Position=UDim2.new(0.5,0,0,0)
            box.BackgroundTransparency=1
            box.Text=""
            box.TextColor3=Color3.new(1,1,1)
            box.Font=Enum.Font.Gotham
            box.TextSize=14
            box.FocusLost:Connect(function()
                if cb then pcall(cb,box.Text) end
            end)
        end
        return content
    end
    return tabhold
end

return lib
