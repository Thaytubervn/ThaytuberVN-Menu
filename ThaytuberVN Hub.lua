local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ModernUI = {}
ModernUI.__index = ModernUI

local Themes = {
    dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Accent = Color3.fromRGB(60, 120, 200),
        Text = Color3.fromRGB(240, 240, 240),
        Border = Color3.fromRGB(255, 0, 100)
    },
    sky = {
        Background = Color3.fromRGB(200, 230, 255),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(0, 0, 0),
        Border = Color3.fromRGB(0, 200, 255)
    },
    water = {
        Background = Color3.fromRGB(15, 30, 60),
        Accent = Color3.fromRGB(0, 100, 200),
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(0, 255, 255)
    }
}

function ModernUI:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Modern UI"
    local keybind = options.Keybind or Enum.KeyCode.K
    local theme = options.Theme or "dark"
    local customTheme = options.CustomTheme

    local usedTheme = typeof(theme) == "string" and Themes[theme] or theme
    if customTheme then
        for k, v in pairs(customTheme) do
            usedTheme[k] = v
        end
    end

    local UI = {}
    setmetatable(UI, self)
    UI.Theme = usedTheme
    UI.CurrentTab = nil
    UI.Tabs = {}

    local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    screenGui.Name = "ModernUI_" .. tostring(math.random(10000, 99999))
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    UI.ScreenGui = screenGui

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = usedTheme.Background
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Visible = false
    mainFrame.ClipsDescendants = false
    mainFrame.BackgroundTransparency = 1
    UI.MainFrame = mainFrame

    -- mở rộng từ trong ra ngoài
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Visible = true
    TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 600, 0, 400),
        BackgroundTransparency = 0
    }):Play()

    -- RGB Border
    local rgbBorder = Instance.new("Frame", mainFrame)
    rgbBorder.Size = UDim2.new(1, 10, 1, 10)
    rgbBorder.Position = UDim2.new(0, -5, 0, -5)
    rgbBorder.BackgroundTransparency = 1
    rgbBorder.ZIndex = 0

    local uiCorner = Instance.new("UICorner", mainFrame)
    uiCorner.CornerRadius = UDim.new(0, 12)

    local uicornerRGB = Instance.new("UICorner", rgbBorder)
    uicornerRGB.CornerRadius = UDim.new(0, 14)

    local gradient = Instance.new("UIGradient", rgbBorder)
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255)),
    }
    gradient.Rotation = 0

    RunService.RenderStepped:Connect(function()
        gradient.Rotation = (gradient.Rotation + 0.5) % 360
    end)

    -- Toggle menu
    local menuVisible = true
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == keybind then
            menuVisible = not menuVisible
            mainFrame.Visible = menuVisible
        end
    end)

    -- Drag
    local dragging = false
    local dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)

    -- Sidebar
    local sidebar = Instance.new("Frame", mainFrame)
    sidebar.Size = UDim2.new(0, 120, 1, 0)
    sidebar.BackgroundColor3 = usedTheme.Accent
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 1
    UI.Sidebar = sidebar

    local content = Instance.new("Frame", mainFrame)
    content.Size = UDim2.new(1, -120, 1, 0)
    content.Position = UDim2.new(0, 120, 0, 0)
    content.BackgroundColor3 = usedTheme.Background
    content.BorderSizePixel = 0
    content.ZIndex = 1
    UI.Content = content

    return UI
end

function ModernUI:CreateTab(name)
    local UI = self
    local tab = {}

    -- Tạo tab button bên sidebar
    local tabButton = Instance.new("TextButton", UI.Sidebar)
    tabButton.Size = UDim2.new(1, 0, 0, 40)
    tabButton.BackgroundColor3 = UI.Theme.Accent
    tabButton.BorderSizePixel = 0
    tabButton.Text = name
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextColor3 = UI.Theme.Text
    tabButton.TextSize = 14

    local tabContent = Instance.new("Frame", UI.Content)
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false

    local layout = Instance.new("UIListLayout", tabContent)
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local padding = Instance.new("UIPadding", tabContent)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)

    tab.Button = tabButton
    tab.Content = tabContent
    tab.Elements = {}

    table.insert(UI.Tabs, tab)

    -- Khi click tab
    tabButton.MouseButton1Click:Connect(function()
        if UI.CurrentTab == tab then
            tabContent.Visible = false
            UI.CurrentTab = nil
        else
            for _, t in ipairs(UI.Tabs) do
                t.Content.Visible = false
            end
            tabContent.Visible = true
            UI.CurrentTab = tab
        end
    end)

    -- API phần tử
    function tab:CreateButton(title, callback)
        local buttonFrame = Instance.new("Frame", tabContent)
        buttonFrame.Size = UDim2.new(1, 0, 0, 36)
        buttonFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        buttonFrame.BorderSizePixel = 0

        local uicorner = Instance.new("UICorner", buttonFrame)
        uicorner.CornerRadius = UDim.new(0, 8)

        local titleLabel = Instance.new("TextLabel", buttonFrame)
        titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.Font = Enum.Font.Gotham
        titleLabel.TextColor3 = UI.Theme.Text
        titleLabel.TextSize = 14
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local button = Instance.new("TextButton", buttonFrame)
        button.Size = UDim2.new(0.3, -10, 1, -10)
        button.Position = UDim2.new(0.7, 0, 0, 5)
        button.AnchorPoint = Vector2.new(0, 0)
        button.BackgroundColor3 = UI.Theme.Accent
        button.Text = "Click"
        button.Font = Enum.Font.GothamBold
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.BorderSizePixel = 0

        local corner = Instance.new("UICorner", button)
        corner.CornerRadius = UDim.new(0, 6)

        button.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
        end)
    end

    -- Lưu tab
    return tab
end

function tab:CreateToggle(title, default, callback)
    local toggleState = default or false

    local toggleFrame = Instance.new("Frame", self.Content)
    toggleFrame.Size = UDim2.new(1, 0, 0, 36)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    toggleFrame.BorderSizePixel = 0

    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 8)

    local titleLabel = Instance.new("TextLabel", toggleFrame)
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextColor3 = ModernUI.Theme.Text
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local toggleButton = Instance.new("Frame", toggleFrame)
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -10)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggleButton.BorderSizePixel = 0

    local corner = Instance.new("UICorner", toggleButton)
    corner.CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", toggleButton)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = toggleState and UDim2.new(1, -19, 0, 1) or UDim2.new(0, 1, 0, 1)
    knob.BackgroundColor3 = toggleState and ModernUI.Theme.Accent or Color3.fromRGB(100, 100, 100)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleState = not toggleState
            knob:TweenPosition(toggleState and UDim2.new(1, -19, 0, 1) or UDim2.new(0, 1, 0, 1), "Out", "Quad", 0.2, true)
            knob.BackgroundColor3 = toggleState and ModernUI.Theme.Accent or Color3.fromRGB(100, 100, 100)
            if callback then callback(toggleState) end
        end
    end)
end

function tab:CreateSlider(title, range, default, suffix, callback)
    local min, max = range[1], range[2]
    local value = default or min
    suffix = suffix or ""

    local sliderFrame = Instance.new("Frame", self.Content)
    sliderFrame.Size = UDim2.new(1, 0, 0, 40)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    sliderFrame.BorderSizePixel = 0
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 8)

    local titleLabel = Instance.new("TextLabel", sliderFrame)
    titleLabel.Size = UDim2.new(1, -10, 0, 14)
    titleLabel.Position = UDim2.new(0, 10, 0, 2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextColor3 = ModernUI.Theme.Text
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel", sliderFrame)
    valueLabel.Size = UDim2.new(0, 50, 0, 14)
    valueLabel.Position = UDim2.new(1, -55, 0, 2)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value) .. suffix
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextColor3 = ModernUI.Theme.Text
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("Frame", sliderFrame)
    bar.Size = UDim2.new(1, -20, 0, 6)
    bar.Position = UDim2.new(0, 10, 1, -12)
    bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = ModernUI.Theme.Accent
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            value = math.floor(min + (max - min) * rel + 0.5)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valueLabel.Text = tostring(value) .. suffix
            if callback then callback(value) end
        end
    end)
end
function tab:CreateKeybind(title, defaultKey, callback)
    local key = defaultKey or Enum.KeyCode.K

    local keybindFrame = Instance.new("Frame", self.Content)
    keybindFrame.Size = UDim2.new(1, 0, 0, 36)
    keybindFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    keybindFrame.BorderSizePixel = 0
    Instance.new("UICorner", keybindFrame).CornerRadius = UDim.new(0, 8)

    local titleLabel = Instance.new("TextLabel", keybindFrame)
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextColor3 = ModernUI.Theme.Text
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local keyButton = Instance.new("TextButton", keybindFrame)
    keyButton.Size = UDim2.new(0, 60, 0, 24)
    keyButton.Position = UDim2.new(1, -70, 0.5, -12)
    keyButton.BackgroundColor3 = ModernUI.Theme.Accent
    keyButton.Text = key.Name
    keyButton.Font = Enum.Font.Gotham
    keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyButton.TextSize = 13
    keyButton.AutoButtonColor = false
    Instance.new("UICorner", keyButton).CornerRadius = UDim.new(0, 6)

    local listening = false

    keyButton.MouseButton1Click:Connect(function()
        keyButton.Text = "..."
        listening = true
    end)

    game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            key = input.KeyCode
            keyButton.Text = key.Name
            listening = false
            if callback then callback(key) end
        end
    end)

    return {
        Get = function() return key end,
        Set = function(k)
            key = k
            keyButton.Text = k.Name
        end
    }
end
function tab:CreateDropdown(title, options, default, callback)
    local current = default or options[1]

    local dropdownFrame = Instance.new("Frame", self.Content)
    dropdownFrame.Size = UDim2.new(1, 0, 0, 36)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dropdownFrame.BorderSizePixel = 0
    Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 8)

    local titleLabel = Instance.new("TextLabel", dropdownFrame)
    titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextColor3 = ModernUI.Theme.Text
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local dropdown = Instance.new("TextButton", dropdownFrame)
    dropdown.Size = UDim2.new(0, 100, 0, 24)
    dropdown.Position = UDim2.new(1, -110, 0.5, -12)
    dropdown.BackgroundColor3 = ModernUI.Theme.Accent
    dropdown.Text = current
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.TextSize = 13
    dropdown.AutoButtonColor = false
    Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)

    dropdown.MouseButton1Click:Connect(function()
        local menu = Instance.new("Frame", dropdownFrame)
        menu.Size = UDim2.new(0, 100, 0, #options * 20)
        menu.Position = UDim2.new(1, -110, 1, 0)
        menu.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        menu.BorderSizePixel = 0
        menu.ZIndex = 10
        Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 6)

        for _, opt in ipairs(options) do
            local btn = Instance.new("TextButton", menu)
            btn.Size = UDim2.new(1, 0, 0, 20)
            btn.BackgroundTransparency = 1
            btn.Text = opt
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 13
            btn.ZIndex = 11
            btn.MouseButton1Click:Connect(function()
                current = opt
                dropdown.Text = opt
                menu:Destroy()
                if callback then callback(opt) end
            end)
        end
    end)
end
function tab:CreateInput(title, defaultText, callback)
    local inputFrame = Instance.new("Frame", self.Content)
    inputFrame.Size = UDim2.new(1, 0, 0, 36)
    inputFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    inputFrame.BorderSizePixel = 0
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 8)

    local titleLabel = Instance.new("TextLabel", inputFrame)
    titleLabel.Size = UDim2.new(0.4, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextColor3 = ModernUI.Theme.Text
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", inputFrame)
    box.Size = UDim2.new(0.5, 0, 0, 24)
    box.Position = UDim2.new(1, -160, 0.5, -12)
    box.BackgroundColor3 = ModernUI.Theme.Accent
    box.PlaceholderText = defaultText or ""
    box.Text = ""
    box.Font = Enum.Font.Gotham
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 13
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    box.FocusLost:Connect(function()
        if callback then callback(box.Text) end
    end)
end
function ModernUI:SetTheme(themeName)
    local themes = {
        dark = { Background = Color3.fromRGB(25,25,25), Accent = Color3.fromRGB(0, 120, 255), Text = Color3.fromRGB(255,255,255) },
        sky = { Background = Color3.fromRGB(60,80,110), Accent = Color3.fromRGB(120,180,255), Text = Color3.fromRGB(255,255,255) },
        water = { Background = Color3.fromRGB(40,70,90), Accent = Color3.fromRGB(0,180,220), Text = Color3.fromRGB(240,240,240) },
    }

    local theme = themes[themeName]
    if theme then
        ModernUI.Theme = theme
    end
end
