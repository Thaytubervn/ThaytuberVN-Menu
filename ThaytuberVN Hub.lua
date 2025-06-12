local UI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Themes = {
    dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Border = Color3.fromRGB(0, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 170, 255)
    },
    sky = {
        Background = Color3.fromRGB(20, 30, 40),
        Border = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(240, 240, 240),
        Accent = Color3.fromRGB(80, 180, 255)
    },
    water = {
        Background = Color3.fromRGB(15, 20, 30),
        Border = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(200, 220, 255),
        Accent = Color3.fromRGB(100, 200, 255)
    }
}

function UI:CreateWindow(options)
    options = options or {}
    local name = options.Name or "Modern UI"
    local keybind = options.Keybind or Enum.KeyCode.K
    local theme = Themes[(typeof(options.Theme) == "string" and Themes[options.Theme]) and options.Theme] or Themes.dark
    if typeof(options.Theme) == "table" then
        theme = options.Theme
    end

    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "ModernUI_" .. name
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false

    local Holder = Instance.new("Frame", ScreenGui)
    Holder.Size = UDim2.new(0, 600, 0, 400)
    Holder.Position = UDim2.new(0.5, -300, 0.5, -200)
    Holder.BackgroundColor3 = theme.Background
    Holder.BorderSizePixel = 0
    Holder.AnchorPoint = Vector2.new(0.5, 0.5)
    Holder.Visible = false
    Holder.ClipsDescendants = true

    local Border = Instance.new("Frame", Holder)
    Border.Name = "Border"
    Border.ZIndex = 0
    Border.Position = UDim2.new(0, -2, 0, -2)
    Border.Size = UDim2.new(1, 4, 1, 4)
    Border.BackgroundColor3 = Color3.new(1, 1, 1)
    Border.BorderSizePixel = 0

    local UIGradient = Instance.new("UIGradient", Border)
    UIGradient.Rotation = 0
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
    }

    -- Tween effect RGB border
    task.spawn(function()
        while true do
            UIGradient.Rotation = UIGradient.Rotation + 1
            task.wait(0.01)
        end
    end)

    -- Scale In animation
    Holder.Visible = true
    Holder.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(Holder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 600, 0, 400)
    }):Play()

    -- Dragging logic
    local dragging, dragInput, dragStart, startPos
    Holder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Holder.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Holder.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)

    local Sidebar = Instance.new("Frame", Holder)
    Sidebar.Size = UDim2.new(0, 130, 1, 0)
    Sidebar.BackgroundColor3 = theme.Accent
    Sidebar.BorderSizePixel = 0

    local TabButtons = Instance.new("Frame", Sidebar)
    TabButtons.Size = UDim2.new(1, 0, 1, 0)
    TabButtons.BackgroundTransparency = 1

    local TabList = Instance.new("UIListLayout", TabButtons)
    TabList.FillDirection = Enum.FillDirection.Vertical
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.VerticalAlignment = Enum.VerticalAlignment.Top
    TabList.Padding = UDim.new(0, 10)

    local TabHolder = Instance.new("Frame", Holder)
    TabHolder.Position = UDim2.new(0, 130, 0, 0)
    TabHolder.Size = UDim2.new(1, -130, 1, 0)
    TabHolder.BackgroundTransparency = 1

    local Tabs = {}
    local CurrentTab

    function Tabs:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton", TabButtons)
        TabBtn.Size = UDim2.new(1, -10, 0, 30)
        TabBtn.Text = tabName
        TabBtn.TextColor3 = theme.Text
        TabBtn.BackgroundColor3 = theme.Background
        TabBtn.BorderSizePixel = 0
        TabBtn.AutoButtonColor = false
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextSize = 14
        TabBtn.ClipsDescendants = true

        local ContentFrame = Instance.new("Frame", TabHolder)
        ContentFrame.Size = UDim2.new(1, 0, 1, 0)
        ContentFrame.Visible = false
        ContentFrame.BackgroundTransparency = 1

        local UIList = Instance.new("UIListLayout", ContentFrame)
        UIList.Padding = UDim.new(0, 8)
        UIList.SortOrder = Enum.SortOrder.LayoutOrder

        TabBtn.MouseButton1Click:Connect(function()
            if CurrentTab == ContentFrame then
                CurrentTab.Visible = false
                CurrentTab = nil
            else
                for _, v in pairs(TabHolder:GetChildren()) do
                    if v:IsA("Frame") then
                        v.Visible = false
                    end
                end
                CurrentTab = ContentFrame
                ContentFrame.Visible = true
            end
        end)

        local TabAPI = {}
        function TabAPI:CreateButton(text, callback)
            local ButtonHolder = Instance.new("Frame", ContentFrame)
            ButtonHolder.Size = UDim2.new(1, -20, 0, 30)
            ButtonHolder.BackgroundTransparency = 1

            local Title = Instance.new("TextLabel", ButtonHolder)
            Title.Size = UDim2.new(0.6, 0, 1, 0)
            Title.BackgroundTransparency = 1
            Title.Text = text
            Title.TextColor3 = theme.Text
            Title.Font = Enum.Font.Gotham
            Title.TextSize = 14
            Title.TextXAlignment = Enum.TextXAlignment.Left

            local ClickBtn = Instance.new("TextButton", ButtonHolder)
            ClickBtn.Size = UDim2.new(0.4, 0, 1, 0)
            ClickBtn.Position = UDim2.new(0.6, 0, 0, 0)
            ClickBtn.Text = "Click"
            ClickBtn.TextColor3 = theme.Background
            ClickBtn.BackgroundColor3 = theme.Accent
            ClickBtn.Font = Enum.Font.GothamBold
            ClickBtn.TextSize = 14
            ClickBtn.BorderSizePixel = 0

            ClickBtn.MouseButton1Click:Connect(function()
                if callback then
                    pcall(callback)
                end
            end)
        end
        function TabAPI:CreateToggle(text, default, callback)
            local ToggleHolder = Instance.new("Frame", ContentFrame)
            ToggleHolder.Size = UDim2.new(1, -20, 0, 30)
            ToggleHolder.BackgroundTransparency = 1

            local Title = Instance.new("TextLabel", ToggleHolder)
            Title.Size = UDim2.new(0.6, 0, 1, 0)
            Title.BackgroundTransparency = 1
            Title.Text = text
            Title.TextColor3 = theme.Text
            Title.Font = Enum.Font.Gotham
            Title.TextSize = 14
            Title.TextXAlignment = Enum.TextXAlignment.Left

            local ToggleBtn = Instance.new("TextButton", ToggleHolder)
            ToggleBtn.Size = UDim2.new(0, 50, 0, 24)
            ToggleBtn.Position = UDim2.new(1, -60, 0.5, -12)
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            ToggleBtn.BorderSizePixel = 0
            ToggleBtn.Text = ""

            local Circle = Instance.new("Frame", ToggleBtn)
            Circle.Size = UDim2.new(0, 20, 0, 20)
            Circle.Position = UDim2.new(0, 2, 0, 2)
            Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            Circle.BorderSizePixel = 0
            Circle.BackgroundTransparency = 0
            Circle.AnchorPoint = Vector2.new(0, 0)

            local UICorner1 = Instance.new("UICorner", ToggleBtn)
            UICorner1.CornerRadius = UDim.new(1, 0)

            local UICorner2 = Instance.new("UICorner", Circle)
            UICorner2.CornerRadius = UDim.new(1, 0)

            local state = default or false
            local function updateToggle(animated)
                if state then
                    TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -22, 0, 2)}):Play()
                    ToggleBtn.BackgroundColor3 = theme.Accent
                else
                    TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 2)}):Play()
                    ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                end
                if callback then pcall(callback, state) end
            end

            updateToggle(false)
            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                updateToggle(true)
            end)
        end
        function TabAPI:CreateSlider(name, options)
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local callback = options.Callback

    local SliderHolder = Instance.new("Frame", ContentFrame)
    SliderHolder.Size = UDim2.new(1, -20, 0, 30)
    SliderHolder.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", SliderHolder)
    Title.Size = UDim2.new(0.3, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name
    Title.TextColor3 = theme.Text
    Title.Font = Enum.Font.Gotham
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local bar = Instance.new("Frame", SliderHolder)
    bar.Size = UDim2.new(0.6, 0, 0, 6)
    bar.Position = UDim2.new(0.35, 0, 0.5, -3)
    bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    bar.BorderSizePixel = 0

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = theme.Accent
    fill.BorderSizePixel = 0

    local valueText = Instance.new("TextLabel", SliderHolder)
    valueText.Size = UDim2.new(0.1, 0, 1, 0)
    valueText.Position = UDim2.new(0.95, -30, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.TextColor3 = theme.Text
    valueText.Font = Enum.Font.Gotham
    valueText.TextSize = 14
    valueText.TextXAlignment = Enum.TextXAlignment.Right

    local value = default
    local dragging = false

    local function updateSlider(inputX)
        local relative = math.clamp((inputX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(((max - min) * relative + min) + 0.5)
        value = val
        fill.Size = UDim2.new(relative, 0, 1, 0)
        valueText.Text = tostring(value)
        if callback then
            pcall(callback, value)
        end
    end

    valueText.Text = tostring(default)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

        function TabAPI:CreateDropdown(text, options)
            local DropdownHolder = Instance.new("Frame", ContentFrame)
            DropdownHolder.Size = UDim2.new(1, -20, 0, 30)
            DropdownHolder.BackgroundTransparency = 1

            local Button = Instance.new("TextButton", DropdownHolder)
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.BackgroundColor3 = theme.Accent
            Button.Text = text
            Button.Font = Enum.Font.Gotham
            Button.TextColor3 = theme.Background
            Button.TextSize = 14
            Button.BorderSizePixel = 0

            local List = Instance.new("Frame", DropdownHolder)
            List.Position = UDim2.new(0, 0, 1, 2)
            List.Size = UDim2.new(1, 0, 0, 0)
            List.BackgroundColor3 = theme.Background
            List.ClipsDescendants = true
            List.Visible = false
            List.ZIndex = 5

            local UIList = Instance.new("UIListLayout", List)
            UIList.SortOrder = Enum.SortOrder.LayoutOrder
            UIList.Padding = UDim.new(0, 2)

            local selected = options.CurrentOption or options.Options[1]
            local callback = options.Callback

            local function select(option)
                selected = option
                Button.Text = text .. ": " .. option
                if callback then pcall(callback, option) end
            end

            for _, v in pairs(options.Options) do
                local opt = Instance.new("TextButton", List)
                opt.Size = UDim2.new(1, 0, 0, 24)
                opt.Text = v
                opt.Font = Enum.Font.Gotham
                opt.TextSize = 14
                opt.BackgroundColor3 = theme.Accent
                opt.TextColor3 = theme.Background
                opt.BorderSizePixel = 0
                opt.MouseButton1Click:Connect(function()
                    select(v)
                    List.Visible = false
                    List:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.2, true)
                end)
            end

            Button.MouseButton1Click:Connect(function()
                List.Visible = not List.Visible
                local count = #options.Options
                local height = count * 26
                List:TweenSize(UDim2.new(1, 0, 0, List.Visible and height or 0), "Out", "Quad", 0.2, true)
            end)

            select(selected)
        end
        function TabAPI:CreateKeybind(text, defaultKey, callback)
            local KeybindHolder = Instance.new("Frame", ContentFrame)
            KeybindHolder.Size = UDim2.new(1, -20, 0, 30)
            KeybindHolder.BackgroundTransparency = 1

            local Title = Instance.new("TextLabel", KeybindHolder)
            Title.Size = UDim2.new(0.6, 0, 1, 0)
            Title.BackgroundTransparency = 1
            Title.Text = text
            Title.TextColor3 = theme.Text
            Title.Font = Enum.Font.Gotham
            Title.TextSize = 14
            Title.TextXAlignment = Enum.TextXAlignment.Left

            local KeyBtn = Instance.new("TextButton", KeybindHolder)
            KeyBtn.Size = UDim2.new(0.4, 0, 1, 0)
            KeyBtn.Position = UDim2.new(0.6, 0, 0, 0)
            KeyBtn.Text = tostring(defaultKey)
            KeyBtn.TextColor3 = theme.Background
            KeyBtn.BackgroundColor3 = theme.Accent
            KeyBtn.Font = Enum.Font.GothamBold
            KeyBtn.TextSize = 14
            KeyBtn.BorderSizePixel = 0

            local waiting = false
            KeyBtn.MouseButton1Click:Connect(function()
                KeyBtn.Text = "..."
                waiting = true
            end)

            local uis = game:GetService("UserInputService")
            uis.InputBegan:Connect(function(input, gpe)
                if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
                    local key = input.KeyCode
                    KeyBtn.Text = key.Name
                    waiting = false
                    if callback then pcall(callback, key) end
                end
            end)
        end
        return TabAPI
    end

    return WindowAPI
end

-- Khởi tạo Drag mượt (kéo ra ngoài vẫn giữ)
local function EnableSmoothDrag(frame)
    local UIS = game:GetService("UserInputService")
    local dragging, dragInput, startPos, startInputPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startInputPos = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startInputPos
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Trả về CreateWindow
return Library
