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

    function tabs:CreateTab(name)
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

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == toggleKey then
            gui.Enabled = not gui.Enabled
        end
    end)

    return setmetatable({ Main = main, Tabs = tabs, Theme = theme }, Framework)
end

Framework.Elements = {}

return Framework
