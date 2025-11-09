
local Library = {}
Library.Flags = {}

--// Services
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// Helper
local function new(class, props)
    local obj = Instance.new(class)
    for i,v in pairs(props or {}) do obj[i] = v end
    return obj
end

local function MakeDraggable(frame, dragToggle)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
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
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

--// Notification
function Library:Notify(text, duration)
    duration = duration or 3
    local gui = new("ScreenGui", {Parent=game:GetService("CoreGui"), Name="FluentNotify"})
    local frame = new("Frame", {
        Size=UDim2.new(0,250,0,50),
        Position=UDim2.new(1,-260,1,-60),
        BackgroundColor3=Color3.fromRGB(10,10,10),
        BorderSizePixel=0,
        Parent=gui,
        AnchorPoint=Vector2.new(1,1)
    })
    new("UICorner",{Parent=frame, CornerRadius=UDim.new(0,8)})
    local label = new("TextLabel", {
        Text=text,
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        TextColor3=Color3.fromRGB(255,255,255),
        Font=Enum.Font.Gotham,
        TextSize=16,
        Parent=frame
    })
    frame.Position = frame.Position + UDim2.new(0,300,0,0)
    TweenService:Create(frame,TweenInfo.new(0.5),{Position=frame.Position - UDim2.new(0,300,0,0)}):Play()
    delay(duration,function()
        TweenService:Create(frame,TweenInfo.new(0.5),{Position=frame.Position + UDim2.new(0,300,0,0)}):Play()
        wait(0.5)
        gui:Destroy()
    end)
end

--// Create Window
function Library:CreateWindow(config)
    local window = {}
    window.Tabs = {}

    local gui = new("ScreenGui", {Parent=game:GetService("CoreGui"), Name="FluentUI"})
    local main = new("Frame", {
        Size = UDim2.new(0,550,0,350),
        Position = UDim2.new(0.5,-275,0.5,-175),
        BackgroundColor3 = Color3.fromRGB(30,30,30),
        BorderSizePixel = 0,
        Parent = gui
    })
    new("UICorner",{CornerRadius=UDim.new(0,8), Parent=main})
    MakeDraggable(main,true)

    local title = new("TextLabel",{
        Size=UDim2.new(1,0,0,40),
        BackgroundColor3=Color3.fromRGB(25,25,25),
        Text=config.Title or "Fluent Hub",
        Font=Enum.Font.GothamBold,
        TextSize=18,
        TextColor3=Color3.fromRGB(255,255,255),
        Parent=main
    })
    new("UICorner",{CornerRadius=UDim.new(0,8), Parent=title})

    local tabHolder = new("Frame",{
        Size=UDim2.new(0,130,1,-40),
        Position=UDim2.new(0,0,0,40),
        BackgroundColor3=Color3.fromRGB(20,20,20),
        BorderSizePixel=0,
        Parent=main
    })
    local content = new("Frame",{
        Size=UDim2.new(1,-130,1,-40),
        Position=UDim2.new(0,130,0,40),
        BackgroundColor3=Color3.fromRGB(35,35,35),
        BorderSizePixel=0,
        Parent=main
    })

    function window:CreateTab(tabName, icon)
        local tab = {}
        tab.Elements = {}

        local button = new("TextButton",{
            Size=UDim2.new(1,-10,0,30),
            Position=UDim2.new(0,5,0,#window.Tabs*35 +5),
            BackgroundColor3=Color3.fromRGB(45,45,45),
            Text=tabName,
            TextColor3=Color3.fromRGB(255,255,255),
            Font=Enum.Font.Gotham,
            TextSize=14,
            Parent=tabHolder
        })
        new("UICorner",{CornerRadius=UDim.new(0,6), Parent=button})

        local page = new("ScrollingFrame",{
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            ScrollBarThickness=6,
            Visible=false,
            Parent=content
        })
        new("UIListLayout",{Padding=UDim.new(0,6), Parent=page})

        button.MouseButton1Click:Connect(function()
            for _, t in pairs(window.Tabs) do
                t.Page.Visible = false
            end
            page.Visible = true
        end)

        function tab:CreateButton(name,callback)
            local btn = new("TextButton",{
                Size=UDim2.new(0,360,0,32),
                BackgroundColor3=Color3.fromRGB(0,122,255),
                Text=name,
                TextColor3=Color3.fromRGB(255,255,255),
                Font=Enum.Font.Gotham,
                TextSize=14,
                Parent=page
            })
            new("UICorner",{CornerRadius=UDim.new(0,5), Parent=btn})
            btn.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end

        function tab:CreateToggle(name,default,callback)
            local state = default or false
            local btn = new("TextButton",{
                Size=UDim2.new(0,360,0,32),
                BackgroundColor3=Color3.fromRGB(0,122,255),
                Text=name.." : "..tostring(state),
                TextColor3=Color3.fromRGB(255,255,255),
                Font=Enum.Font.Gotham,
                TextSize=14,
                Parent=page
            })
            new("UICorner",{CornerRadius=UDim.new(0,5), Parent=btn})
            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.Text = name.." : "..tostring(state)
                pcall(callback,state)
            end)
        end

        function tab:CreateSlider(name,min,max,default,callback)
            local val = default or min
            local frame = new("Frame",{
                Size=UDim2.new(0,360,0,32),
                BackgroundColor3=Color3.fromRGB(45,45,45),
                Parent=page
            })
            new("UICorner",{CornerRadius=UDim.new(0,5), Parent=frame})
            local label = new("TextLabel",{
                Size=UDim2.new(1,-60,1,0),
                Position=UDim2.new(0,5,0,0),
                BackgroundTransparency=1,
                Text=name.." : "..tostring(val),
                TextColor3=Color3.fromRGB(255,255,255),
                Font=Enum.Font.Gotham,
                TextSize=14,
                Parent=frame
            })
            local sliderBg = new("Frame",{
                Size=UDim2.new(1,-10,0,8),
                Position=UDim2.new(0,5,1,-12),
                BackgroundColor3=Color3.fromRGB(0,122,255),
                Parent=frame
            })
            new("UICorner",{CornerRadius=UDim.new(0,4), Parent=sliderBg})
            sliderBg.MouseButton1Down:Connect(function(input)
                local mouse = UIS:GetMouseLocation()
                local dragging = true
                local conn; conn = UIS.InputChanged:Connect(function(move)
                    if dragging and move.UserInputType==Enum.UserInputType.MouseMovement then
                        local rel = math.clamp((move.Position.X-(sliderBg.AbsolutePosition.X))/sliderBg.AbsoluteSize.X,0,1)
                        val = math.floor(rel*(max-min)+min)
                        label.Text = name.." : "..tostring(val)
                        pcall(callback,val)
                    end
                end)
                local endConn; endConn = UIS.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType==Enum.UserInputType.MouseButton1 then
                        dragging = false
                        conn:Disconnect()
                        endConn:Disconnect()
                    end
                end)
            end)
        end

        function tab:CreateTextbox(name,callback)
            local box = new("TextBox",{
                Size=UDim2.new(0,360,0,32),
                Text=name,
                TextColor3=Color3.fromRGB(255,255,255),
                BackgroundColor3=Color3.fromRGB(45,45,45),
                Font=Enum.Font.Gotham,
                TextSize=14,
                ClearTextOnFocus=false,
                Parent=page
            })
            new("UICorner",{CornerRadius=UDim.new(0,5), Parent=box})
            box.FocusLost:Connect(function(enter)
                if enter then
                    pcall(callback,box.Text)
                end
            end)
        end

        function tab:CreateDropdown(name,options,callback)
            local selected = options[1]
            local mainBtn = new("TextButton",{
                Size=UDim2.new(0,360,0,32),
                Text=name.." : "..tostring(selected),
                TextColor3=Color3.fromRGB(255,255,255),
                BackgroundColor3=Color3.fromRGB(0,122,255),
                Font=Enum.Font.Gotham,
                TextSize=14,
                Parent=page
            })
            new("UICorner",{CornerRadius=UDim.new(0,5), Parent=mainBtn})
            local list = new("Frame",{
                Size=UDim2.new(0,360,0,#options*30),
                Position=UDim2.new(0,0,0,32),
                BackgroundColor3=Color3.fromRGB(35,35,35),
                Visible=false,
                Parent=mainBtn
            })
            new("UICorner",{CornerRadius=UDim.new(0,5), Parent=list})
            for i,opt in ipairs(options) do
                local btn = new("TextButton",{
                    Size=UDim2.new(1,0,0,30),
                    Position=UDim2.new(0,0,0,(i-1)*30),
                    Text=opt,
                    BackgroundColor3=Color3.fromRGB(0,122,255),
                    TextColor3=Color3.fromRGB(255,255,255),
                    Font=Enum.Font.Gotham,
                    TextSize=14,
                    Parent=list
                })
                btn.MouseButton1Click:Connect(function()
                    selected = opt
                    mainBtn.Text = name.." : "..tostring(selected)
                    list.Visible = false
                    pcall(callback,selected)
                end)
            end
            mainBtn.MouseButton1Click:Connect(function()
                list.Visible = not list.Visible
            end)
        end

        function tab:CreateMultiDropdown(name,options,callback)
            local selected = {}
            local mainBtn = new("TextButton",{
                Size=UDim2.new(0,360,0,32),
                Text=name.." : None",
                TextColor3=Color3.fromRGB(255,255,255),
                BackgroundColor3=Color3.fromRGB(0,122,255),
                Font=Enum.Font.Gotham,
                TextSize=14,
                Parent=page
            })
            new("UICorner",{CornerRadius=UDim.new(0,5), Parent=mainBtn})
            local list = new("Frame",{
                Size=UDim2.new(0,360,0,#options*30),
                Position=UDim2.new(0,0,0,32),
                BackgroundColor3=Color3.fromRGB(35,35,35),
                Visible=false,
                Parent=mainBtn
            })
            new("UICorner",{CornerRadius=UDim.new(0,5), Parent=list})
            for i,opt in ipairs(options) do
                local btn = new("TextButton",{
                    Size=UDim2.new(1,0,0,30),
                    Position=UDim2.new(0,0,0,(i-1)*30),
                    Text=opt,
                    BackgroundColor3=Color3.fromRGB(0,122,255),
                    TextColor3=Color3.fromRGB(255,255,255),
                    Font=Enum.Font.Gotham,
                    TextSize=14,
                    Parent=list
                })
                btn.MouseButton1Click:Connect(function()
                    if table.find(selected,opt) then
                        for k,v in pairs(selected) do if v==opt then table.remove(selected,k) break end end
                    else
                        table.insert(selected,opt)
                    end
                    mainBtn.Text = name.." : "..(#selected>0 and table.concat(selected,", ") or "None")
                    pcall(callback,selected)
                end)
            end
            mainBtn.MouseButton1Click:Connect(function()
                list.Visible = not list.Visible
            end)
        end

        function tab:CreateKeybind(name,key,callback)
            local btn = new("TextButton",{
                Size=UDim2.new(0,360,0,32),
                Text=name.." : "..tostring(key.Name),
                TextColor3=Color3.fromRGB(255,255,255),
                BackgroundColor3=Color3.fromRGB(0,122,255),
                Font=Enum.Font.Gotham,
                TextSize=14,
                Parent=page
            })
            new("UICorner",{CornerRadius=UDim.new(0,5), Parent=btn})
            UIS.InputBegan:Connect(function(input,gp)
                if input.KeyCode==key then
                    pcall(callback)
                end
            end)
        end

        window.Tabs[#window.Tabs+1]={Page=page}
        if #window.Tabs==1 then page.Visible=true end
        return tab
    end

    -- Toggle UI
    UIS.InputBegan:Connect(function(input)
        if input.KeyCode==Enum.KeyCode.RightControl then
            gui.Enabled = not gui.Enabled
        end
    end)

    return window
end

return Library
