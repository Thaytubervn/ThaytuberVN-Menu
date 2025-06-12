local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Library = {}
Library.__index = Library

local Themes = {
    dark = {
        Background = Color3.fromRGB(20, 20, 20),
        Topbar = Color3.fromRGB(30, 30, 30),
        Border = Color3.fromRGB(255, 0, 0),
        Text = Color3.fromRGB(255, 255, 255),
        Element = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(0, 170, 255),
    },
    sky = {
        Background = Color3.fromRGB(200, 230, 255),
        Topbar = Color3.fromRGB(150, 200, 255),
        Border = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(0, 0, 0),
        Element = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 170, 255),
    },
    water = {
        Background = Color3.fromRGB(10, 25, 50),
        Topbar = Color3.fromRGB(15, 40, 70),
        Border = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(230, 240, 255),
        Element = Color3.fromRGB(20, 35, 60),
        Accent = Color3.fromRGB(0, 140, 255),
    },
}

-- Load theme
local function ApplyTheme(nameOrTable)
    if type(nameOrTable) == "string" and Themes[nameOrTable:lower()] then
        return Themes[nameOrTable:lower()]
    elseif type(nameOrTable) == "table" then
        return nameOrTable
    else
        return Themes.dark
    end
end

function Library:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "My UI"
    local ToggleKey = config.Keybind or Enum.KeyCode.K
    local Theme = ApplyTheme(config.Theme)
    local UseRainbowBorder = config.RainbowBorder or false

    -- Main Screen
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "ModernUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    -- Main Holder
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 580, 0, 360)
    Main.Position = UDim2.new(0.5, -290, 0.5, -180)
    Main.BackgroundColor3 = Theme.Background
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Parent = ScreenGui
    Main.Visible = false
    Main.ClipsDescendants = true
    Main.BackgroundTransparency = 0
    Main.BorderSizePixel = 0
    Main.Name = "MainWindow"
    Main.Active = true
    Main.Draggable = false

    -- Round corners
    local UICorner = Instance.new("UICorner", Main)
    UICorner.CornerRadius = UDim.new(0, 12)

    -- Scale opening
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Visible = true
    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 580, 0, 360)
    }):Play()

    -- Drag
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    Main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- RGB Border
    local RGB = Instance.new("Frame", Main)
    RGB.Name = "RGBBorder"
    RGB.Size = UDim2.new(1, 10, 1, 10)
    RGB.Position = UDim2.new(0, -5, 0, -5)
    RGB.BorderSizePixel = 0
    RGB.BackgroundColor3 = Color3.new(1, 0, 0)
    RGB.ZIndex = 0

    local RGBCorner = Instance.new("UICorner", RGB)
    RGBCorner.CornerRadius = UDim.new(0, 14)

    if UseRainbowBorder then
        local hue = 0
        RunService.RenderStepped:Connect(function()
            hue = (hue + 1) % 360
            RGB.BackgroundColor3 = Color3.fromHSV(hue / 360, 1, 1)
        end)
    else
        RGB.BackgroundColor3 = Theme.Border
    end

    -- Sidebar tab buttons
    local SideBar = Instance.new("Frame", Main)
    SideBar.Size = UDim2.new(0, 120, 1, 0)
    SideBar.Position = UDim2.new(0, 0, 0, 0)
    SideBar.BackgroundColor3 = Theme.Topbar
    SideBar.BorderSizePixel = 0

    local UICornerSidebar = Instance.new("UICorner", SideBar)
    UICornerSidebar.CornerRadius = UDim.new(0, 12)

    local TabList = Instance.new("UIListLayout", SideBar)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 4)

    local Tabs = {}
    local CurrentTab = nil

    local ContentHolder = Instance.new("Frame", Main)
    ContentHolder.Position = UDim2.new(0, 130, 0, 10)
    ContentHolder.Size = UDim2.new(1, -140, 1, -20)
    ContentHolder.BackgroundTransparency = 1

    -- Toggle UI
    local function toggleUI()
        Main.Visible = not Main.Visible
    end
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == ToggleKey and not UserInputService:GetFocusedTextBox() then
            toggleUI()
        end
    end)

    -- Return window object
    local Window = {}
    Window.Theme = Theme
    Window.Tabs = Tabs
    Window.Content = ContentHolder
    Window.Sidebar = SideBar
    Window.CurrentTab = nil
    Window.Main = Main
    Window.ToggleKey = ToggleKey
    Window.ToggleUI = toggleUI
    Window.ScreenGui = ScreenGui
function Window:CreateTab(Name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = Name .. "TabButton"
    TabButton.Text = Name
    TabButton.Size = UDim2.new(1, -10, 0, 36)
    TabButton.Position = UDim2.new(0, 5, 0, 0)
    TabButton.BackgroundColor3 = Theme.Element
    TabButton.TextColor3 = Theme.Text
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 14
    TabButton.AutoButtonColor = false
    TabButton.Parent = Window.Sidebar

    local corner = Instance.new("UICorner", TabButton)
    corner.CornerRadius = UDim.new(0, 8)

    local TabContent = Instance.new("Frame", Window.Content)
    TabContent.Name = Name .. "TabContent"
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false

    local UIList = Instance.new("UIListLayout", TabContent)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 8)

    Window.Tabs[Name] = {
        Button = TabButton,
        Content = TabContent
    }

    TabButton.MouseButton1Click:Connect(function()
        if Window.CurrentTab == Name then
            -- Tắt nếu click lại
            Window.CurrentTab = nil
            TabContent.Visible = false
            TabButton.BackgroundColor3 = Theme.Element
        else
            -- Ẩn tất cả
            for _, t in pairs(Window.Tabs) do
                t.Content.Visible = false
                t.Button.BackgroundColor3 = Theme.Element
            end
            -- Hiện tab mới
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Theme.Accent
            Window.CurrentTab = Name
        end
    end)

    return setmetatable({
        Container = TabContent,
        Theme = Theme
    }, { __index = Library.Elements })
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
