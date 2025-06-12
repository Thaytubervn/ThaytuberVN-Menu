--// ModernUI Framework (Rewritten for Stability & Clarity)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Framework = {}
Framework.__index = Framework

local Themes = {
    dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Border = Color3.fromRGB(255, 0, 0),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 170, 255),
        Element = Color3.fromRGB(40, 40, 40),
    },
    sky = {
        Background = Color3.fromRGB(200, 230, 255),
        Border = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(0, 170, 255),
        Element = Color3.fromRGB(240, 240, 255),
    },
    water = {
        Background = Color3.fromRGB(10, 25, 50),
        Border = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(230, 240, 255),
        Accent = Color3.fromRGB(0, 140, 255),
        Element = Color3.fromRGB(20, 35, 60),
    }
}

local function ApplyTheme(input)
    if typeof(input) == "table" then return input end
    return Themes[string.lower(input)] or Themes.dark
end

function Framework:CreateWindow(config)
    config = config or {}
    local theme = ApplyTheme(config.Theme)
    local toggleKey = config.ToggleUIKeybind or Enum.KeyCode.K
    local rainbow = config.RainbowBorder or false

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "ModernUI"
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 580, 0, 360)
    main.Position = UDim2.new(0.5, -290, 0.5, -180)
    main.BackgroundColor3 = theme.Background
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BorderSizePixel = 0

    local border = Instance.new("Frame", main)
    border.Position = UDim2.new(0, -3, 0, -3)
    border.Size = UDim2.new(1, 6, 1, 6)
    border.ZIndex = 0
    border.BorderSizePixel = 0
    border.BackgroundColor3 = rainbow and Color3.fromRGB(255,0,0) or theme.Border

    local uicorner = Instance.new("UICorner", main)
    uicorner.CornerRadius = UDim.new(0, 10)
    Instance.new("UICorner", border).CornerRadius = UDim.new(0, 10)

    if rainbow then
        coroutine.wrap(function()
            while true do
                local t = tick() * 100
                border.BackgroundColor3 = Color3.fromHSV((t % 255) / 255, 1, 1)
                task.wait()
            end
        end)()
    end

    main.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(main, TweenInfo.new(0.25), { Size = UDim2.new(0, 580, 0, 360) }):Play()

    local dragging = false
    local dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0, 120, 1, 0)
    sidebar.BackgroundColor3 = theme.Element
    sidebar.BorderSizePixel = 0

    local content = Instance.new("Frame", main)
    content.Position = UDim2.new(0, 130, 0, 10)
    content.Size = UDim2.new(1, -140, 1, -20)
    content.BackgroundTransparency = 1

    local tabs = {}
    local currentTab = nil

    local layout = Instance.new("UIListLayout", sidebar)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)

    function Framework:CreateTab(name)
        local tabBtn = Instance.new("TextButton", sidebar)
        tabBtn.Size = UDim2.new(1, -10, 0, 36)
        tabBtn.Text = name
        tabBtn.BackgroundColor3 = theme.Element
        tabBtn.TextColor3 = theme.Text
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextSize = 14

        local tabPage = Instance.new("Frame", content)
        tabPage.Size = UDim2.new(1, 0, 1, 0)
        tabPage.BackgroundTransparency = 1
        tabPage.Visible = false
        local list = Instance.new("UIListLayout", tabPage)
        list.Padding = UDim.new(0, 6)
        list.SortOrder = Enum.SortOrder.LayoutOrder

        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(content:GetChildren()) do if t:IsA("Frame") then t.Visible = false end end
            tabPage.Visible = true
            currentTab = tabPage
        end)

        return setmetatable({ Container = tabPage, Theme = theme }, Framework.Elements)
    end

function Library.Elements:CreateButton(Name, Callback)
    Callback = Callback or function() end

    local Holder = Instance.new("Frame", self.Container)
    Holder.Size = UDim2.new(1, 0, 0, 40)
    Holder.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Holder)
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Name
    Label.TextColor3 = self.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Button = Instance.new("TextButton", Holder)
    Button.Size = UDim2.new(0, 70, 0, 28)
    Button.Position = UDim2.new(1, -70, 0.5, -14)
    Button.BackgroundColor3 = self.Theme.Accent
    Button.Text = "Click"
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 13
    Button.AutoButtonColor = true

    local corner = Instance.new("UICorner", Button)
    corner.CornerRadius = UDim.new(1, 0)

    Button.MouseButton1Click:Connect(function()
        pcall(Callback)
    end)
end
function Library.Elements:CreateToggle(Name, Flag, CurrentValue, Callback)
    Callback = Callback or function() end
    local State = CurrentValue or false

    local Holder = Instance.new("Frame", self.Container)
    Holder.Size = UDim2.new(1, 0, 0, 40)
    Holder.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Holder)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Name
    Label.TextColor3 = self.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Toggle = Instance.new("Frame", Holder)
    Toggle.Size = UDim2.new(0, 50, 0, 22)
    Toggle.Position = UDim2.new(1, -50, 0.5, -11)
    Toggle.BackgroundColor3 = State and self.Theme.Accent or Color3.fromRGB(80, 80, 80)
    Toggle.ClipsDescendants = true

    local corner = Instance.new("UICorner", Toggle)
    corner.CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame", Toggle)
    Circle.Size = UDim2.new(0, 20, 0, 20)
    Circle.Position = UDim2.new(State and 1 or 0, State and -22 or 2, 0, 1)
    Circle.BackgroundColor3 = Color3.new(1, 1, 1)
    Circle.Parent = Toggle

    local CircleCorner = Instance.new("UICorner", Circle)
    CircleCorner.CornerRadius = UDim.new(1, 0)

    local function SetToggle(On)
        State = On
        Toggle.BackgroundColor3 = On and self.Theme.Accent or Color3.fromRGB(80, 80, 80)
        Circle:TweenPosition(UDim2.new(On and 1 or 0, On and -22 or 2, 0, 1), "Out", "Quad", 0.2, true)
        pcall(Callback, On)
    end

    Toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            SetToggle(not State)
        end
    end)

    if Flag then Library.Flags[Flag] = function() return State end end
end

function Library.Elements:CreateSlider(Name, Flag, Range, CurrentValue, Suffix, Callback)
    Callback = Callback or function() end
    local Min, Max = Range[1], Range[2]
    local Value = CurrentValue or Min

    local Holder = Instance.new("Frame", self.Container)
    Holder.Size = UDim2.new(1, 0, 0, 48)
    Holder.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Holder)
    Label.Size = UDim2.new(1, 0, 0, 16)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Text = Name .. ": " .. tostring(Value) .. (Suffix or "")
    Label.TextColor3 = self.Theme.Text
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local SliderBack = Instance.new("Frame", Holder)
    SliderBack.Size = UDim2.new(1, 0, 0, 8)
    SliderBack.Position = UDim2.new(0, 0, 0, 24)
    SliderBack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderBack.ClipsDescendants = true

    local Corner = Instance.new("UICorner", SliderBack)
    Corner.CornerRadius = UDim.new(1, 0)

    local SliderFill = Instance.new("Frame", SliderBack)
    SliderFill.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
    SliderFill.BackgroundColor3 = self.Theme.Accent
    SliderFill.ZIndex = 2

    local FillCorner = Instance.new("UICorner", SliderFill)
    FillCorner.CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function Set(v)
        v = math.clamp(math.floor(v + 0.5), Min, Max)
        Value = v
        SliderFill.Size = UDim2.new((v - Min) / (Max - Min), 0, 1, 0)
        Label.Text = Name .. ": " .. tostring(v) .. (Suffix or "")
        pcall(Callback, v)
    end

    SliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Set((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X * (Max - Min) + Min)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Set((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X * (Max - Min) + Min)
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    if Flag then Library.Flags[Flag] = function() return Value end end
end

function Library.Elements:CreateKeybind(Name, Flag, CurrentKey, Callback)
    Callback = Callback or function() end
    local Key = CurrentKey or Enum.KeyCode.K
    local Binding = false

    local Holder = Instance.new("Frame", self.Container)
    Holder.Size = UDim2.new(1, 0, 0, 40)
    Holder.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Holder)
    Label.Size = UDim2.new(1, -100, 1, 0)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Name
    Label.TextColor3 = self.Theme.Text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local KeyButton = Instance.new("TextButton", Holder)
    KeyButton.Size = UDim2.new(0, 80, 0, 26)
    KeyButton.Position = UDim2.new(1, -90, 0.5, -13)
    KeyButton.BackgroundColor3 = self.Theme.Main
    KeyButton.TextColor3 = self.Theme.Text
    KeyButton.Font = Enum.Font.Gotham
    KeyButton.TextSize = 13
    KeyButton.Text = Key.Name
    KeyButton.AutoButtonColor = false

    local Corner = Instance.new("UICorner", KeyButton)
    Corner.CornerRadius = UDim.new(0, 6)

    KeyButton.MouseButton1Click:Connect(function()
        KeyButton.Text = "Press a key..."
        Binding = true
    end)

    game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
        if Binding and not gpe then
            Binding = false
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Key = input.KeyCode
                KeyButton.Text = Key.Name
                pcall(Callback, Key)
            else
                KeyButton.Text = "Invalid"
                task.wait(0.5)
                KeyButton.Text = Key.Name
            end
        end
    end)

    if Flag then
        Library.Flags[Flag] = function() return Key end
    end
end

function Library.Elements:CreateDropdown(Name, Flag, Options, CurrentOption, Callback)
    Callback = Callback or function() end
    local Selected = CurrentOption or Options[1]

    local Holder = Instance.new("Frame", self.Container)
    Holder.Size = UDim2.new(1, 0, 0, 48)
    Holder.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Holder)
    Label.Size = UDim2.new(1, 0, 0, 16)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Text = Name
    Label.TextColor3 = self.Theme.Text
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Drop = Instance.new("TextButton", Holder)
    Drop.Size = UDim2.new(1, 0, 0, 26)
    Drop.Position = UDim2.new(0, 0, 0, 20)
    Drop.BackgroundColor3 = self.Theme.Main
    Drop.TextColor3 = self.Theme.Text
    Drop.Font = Enum.Font.Gotham
    Drop.TextSize = 13
    Drop.Text = Selected
    Drop.AutoButtonColor = false

    local Corner = Instance.new("UICorner", Drop)
    Corner.CornerRadius = UDim.new(0, 6)

    local List = Instance.new("Frame", Drop)
    List.Size = UDim2.new(1, 0, 0, #Options * 26)
    List.Position = UDim2.new(0, 0, 1, 0)
    List.BackgroundColor3 = self.Theme.Main
    List.Visible = false
    List.ClipsDescendants = true

    local ListCorner = Instance.new("UICorner", List)
    ListCorner.CornerRadius = UDim.new(0, 6)

    for _, option in ipairs(Options) do
        local Button = Instance.new("TextButton", List)
        Button.Size = UDim2.new(1, 0, 0, 26)
        Button.Position = UDim2.new(0, 0, 0, (_ - 1) * 26)
        Button.BackgroundColor3 = self.Theme.DarkContrast
        Button.TextColor3 = self.Theme.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 13
        Button.Text = option
        Button.AutoButtonColor = false

        Button.MouseButton1Click:Connect(function()
            Selected = option
            Drop.Text = option
            List.Visible = false
            pcall(Callback, option)
        end)
    end

    Drop.MouseButton1Click:Connect(function()
        List.Visible = not List.Visible
    end)

    if Flag then Library.Flags[Flag] = function() return Selected end end
end

return Library
