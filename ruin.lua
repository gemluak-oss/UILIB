-- vape_ui.lua (mod: tanpa colorpicker, draggable aktif)
local lib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local ui = Instance.new("ScreenGui")
ui.Name = "ui"
ui.Parent = game.CoreGui
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- helper draggable
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

function lib:Window(title)
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ui
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 560, 0, 319)

    -- drag area
    local DragFrame = Instance.new("Frame")
    DragFrame.Parent = Main
    DragFrame.BackgroundTransparency = 1
    DragFrame.Size = UDim2.new(1, 0, 0, 40)
    MakeDraggable(DragFrame, Main)

    -- title
    local Title = Instance.new("TextLabel")
    Title.Parent = Main
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.03, 0, 0.05, 0)
    Title.Size = UDim2.new(0, 200, 0, 23)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = title
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- tab holder
    local TabHold = Instance.new("Frame")
    TabHold.Parent = Main
    TabHold.BackgroundTransparency = 1
    TabHold.Position = UDim2.new(0.03, 0, 0.15, 0)
    TabHold.Size = UDim2.new(0, 107, 0, 254)

    local TabLayout = Instance.new("UIListLayout", TabHold)
    TabLayout.Padding = UDim.new(0, 8)

    local TabFolder = Instance.new("Folder", Main)

    local tabhold = {}
    function tabhold:Tab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabHold
        TabBtn.Size = UDim2.new(0, 107, 0, 21)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        local TabTitle = Instance.new("TextLabel", TabBtn)
        TabTitle.Size = UDim2.new(1, 0, 1, 0)
        TabTitle.BackgroundTransparency = 1
        TabTitle.Font = Enum.Font.Gotham
        TabTitle.Text = name
        TabTitle.TextColor3 = Color3.fromRGB(200,200,200)
        TabTitle.TextSize = 14
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left

        local Tab = Instance.new("ScrollingFrame")
        Tab.Parent = TabFolder
        Tab.Size = UDim2.new(0, 373, 0, 254)
        Tab.Position = UDim2.new(0.31,0,0.15,0)
        Tab.BackgroundTransparency = 1
        Tab.ScrollBarThickness = 3
        Tab.Visible = false
        local layout = Instance.new("UIListLayout", Tab)
        layout.Padding = UDim.new(0,6)

        if #TabFolder:GetChildren() == 1 then
            Tab.Visible = true
            TabTitle.TextColor3 = Color3.new(1,1,1)
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _,c in ipairs(TabFolder:GetChildren()) do
                if c:IsA("ScrollingFrame") then c.Visible=false end
            end
            Tab.Visible = true
        end)

        local content = {}
        function content:Label(text)
            local lbl = Instance.new("TextLabel", Tab)
            lbl.Size = UDim2.new(0, 363, 0, 30)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
        end
        function content:Button(text, cb)
            local b = Instance.new("TextButton", Tab)
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
            b.MouseButton1Click:Connect(function() if cb then cb() end end)
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
                if cb then cb(on) end
            end)
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
                if cb then cb(box.Text) end
            end)
        end
        return content
    end
    return tabhold
end

return lib
