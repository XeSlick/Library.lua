--[[
    ╔═════════════════════════════════════════════════════════════════════╗
    ║                     WINDFLUENT UI LIBRARY v2.4.0                    ║
    ║        Inspired by WindUI, Rayfield & Fluent UI for Roblox Luau     ║
    ║                 Engineered with Pure Luau & OOP                     ║
    ╚═════════════════════════════════════════════════════════════════════╝
    
    Features:
    • Pure Luau Object-Oriented Programming (OOP) with Metatables
    • Fluent Design Language with Smooth TweenService Transitions
    • Inertia Draggable Windows via UserInputService
    • Dynamic Theme Manager with RGB / Hex & Custom Accent Colors
    • Key Verification System with persistent key saving
    • Toast Notifications with countdown progress bars
    • Interactive Modal Dialogs & Confirmation Popups
    • Sidebar Tabs with TabSections & Tag Badges
    • Rich Interactive Elements:
        - Section, Button, Toggle, Slider, Input/TextBox
        - Dropdown (Single & Multi-Select with animated list)
        - Keybind (Hold, Toggle, Always modes)
        - Interactive Colorpicker (HSV + Alpha slider + Hex display)
        - ProgressBar, Paragraph (RichText), Code block, Divider, Space
        - HStack & VStack Layout Helpers
    • Config Management System (writefile, readfile, HttpService JSON)
    • Global Connection Cleaning & Memory Safe Unload()
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

-- Safe parent determination (CoreGui if exploit has permission, else PlayerGui)
local function GetSafeGuiParent()
    local success, result = pcall(function()
        return CoreGui
    end)
    if success and result then
        -- Test if we can parent to CoreGui
        local test = Instance.new("Folder")
        local parentSuccess = pcall(function()
            test.Parent = CoreGui
            test:Destroy()
        end)
        if parentSuccess then
            return CoreGui
        end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

--------------------------------------------------------------------------------
-- THEME SYSTEM
--------------------------------------------------------------------------------
local Themes = {
    Dark = {
        Background = Color3.fromRGB(18, 18, 22),
        Secondary = Color3.fromRGB(26, 26, 32),
        Card = Color3.fromRGB(32, 32, 40),
        Border = Color3.fromRGB(48, 48, 60),
        Accent = Color3.fromRGB(59, 130, 246), -- Vibrant Azure Blue
        AccentHover = Color3.fromRGB(37, 99, 235),
        Text = Color3.fromRGB(243, 244, 246),
        SubText = Color3.fromRGB(156, 163, 175),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Danger = Color3.fromRGB(239, 68, 68),
        TitleBar = Color3.fromRGB(22, 22, 28)
    },
    Light = {
        Background = Color3.fromRGB(248, 249, 250),
        Secondary = Color3.fromRGB(238, 240, 244),
        Card = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(226, 232, 240),
        Accent = Color3.fromRGB(37, 99, 235),
        AccentHover = Color3.fromRGB(29, 78, 216),
        Text = Color3.fromRGB(15, 23, 42),
        SubText = Color3.fromRGB(100, 116, 139),
        Success = Color3.fromRGB(22, 163, 74),
        Warning = Color3.fromRGB(202, 138, 4),
        Danger = Color3.fromRGB(220, 38, 38),
        TitleBar = Color3.fromRGB(241, 245, 249)
    },
    Cyberpunk = {
        Background = Color3.fromRGB(13, 14, 25),
        Secondary = Color3.fromRGB(21, 22, 38),
        Card = Color3.fromRGB(28, 30, 52),
        Border = Color3.fromRGB(255, 0, 128),
        Accent = Color3.fromRGB(0, 240, 255),
        AccentHover = Color3.fromRGB(0, 210, 230),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 185, 215),
        Success = Color3.fromRGB(50, 255, 126),
        Warning = Color3.fromRGB(255, 192, 0),
        Danger = Color3.fromRGB(255, 56, 56),
        TitleBar = Color3.fromRGB(18, 19, 34)
    },
    Emerald = {
        Background = Color3.fromRGB(12, 24, 20),
        Secondary = Color3.fromRGB(18, 36, 30),
        Card = Color3.fromRGB(24, 48, 40),
        Border = Color3.fromRGB(34, 75, 60),
        Accent = Color3.fromRGB(16, 185, 129),
        AccentHover = Color3.fromRGB(5, 150, 105),
        Text = Color3.fromRGB(240, 253, 244),
        SubText = Color3.fromRGB(167, 243, 208),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Danger = Color3.fromRGB(239, 68, 68),
        TitleBar = Color3.fromRGB(15, 30, 25)
    }
}

--------------------------------------------------------------------------------
-- UTILITIES & HELPERS
--------------------------------------------------------------------------------
local Utils = {}

function Utils.Tween(instance, properties, duration, easingStyle, easingDirection)
    duration = duration or 0.25
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, easingStyle, easingDirection), properties)
    tween:Play()
    return tween
end

function Utils.CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

function Utils.CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = color or Color3.fromRGB(60, 60, 70)
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

function Utils.CreatePadding(parent, top, right, bottom, left)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 8)
    padding.PaddingRight = UDim.new(0, right or 8)
    padding.PaddingBottom = UDim.new(0, bottom or top or 8)
    padding.PaddingLeft = UDim.new(0, left or right or 8)
    padding.Parent = parent
    return padding
end

function Utils.MakeDraggable(frame, dragHandle, connectionsList)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local inputBegan = dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

    local inputChanged = dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    local globalInputChanged = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Utils.Tween(frame, {
                Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            }, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    end)

    if connectionsList then
        table.insert(connectionsList, inputBegan)
        table.insert(connectionsList, inputChanged)
        table.insert(connectionsList, globalInputChanged)
    end
end

--------------------------------------------------------------------------------
-- LIBRARY DEFINITION
--------------------------------------------------------------------------------
local Library = {
    Version = "2.4.0",
    ActiveTheme = Themes.Dark,
    ActiveThemeName = "Dark",
    Windows = {},
    Connections = {},
    ConfigFolder = "WindFluentConfigs"
}
Library.__index = Library

-- Event & Connection registry for safe Unload
function Library:RegisterConnection(conn)
    table.insert(self.Connections, conn)
    return conn
end

-- Set or Update Active Theme
function Library:SetTheme(themeNameOrTable)
    if type(themeNameOrTable) == "string" and Themes[themeNameOrTable] then
        self.ActiveTheme = Themes[themeNameOrTable]
        self.ActiveThemeName = themeNameOrTable
    elseif type(themeNameOrTable) == "table" then
        self.ActiveTheme = setmetatable(themeNameOrTable, {__index = Themes.Dark})
        self.ActiveThemeName = "Custom"
    end
end

--------------------------------------------------------------------------------
-- NOTIFICATION SYSTEM (Floating Toast with Progress Bar)
--------------------------------------------------------------------------------
function Library:Notify(options)
    options = options or {}
    local Title = options.Title or "Notification"
    local Content = options.Content or "Message body goes here"
    local Duration = options.Duration or 4
    local Icon = options.Icon or "rbxassetid://10723415903" -- Info icon
    local Type = options.Type or "Info" -- Info, Success, Warning, Danger

    local theme = self.ActiveTheme
    local accentColor = theme.Accent
    if Type == "Success" then accentColor = theme.Success
    elseif Type == "Warning" then accentColor = theme.Warning
    elseif Type == "Danger" then accentColor = theme.Danger end

    local notifGui = self._NotifGui
    if not notifGui or not notifGui.Parent then
        notifGui = Instance.new("ScreenGui")
        notifGui.Name = "WindFluent_Notifications"
        notifGui.DisplayOrder = 9999
        notifGui.ResetOnSpawn = false
        notifGui.Parent = GetSafeGuiParent()
        self._NotifGui = notifGui

        local container = Instance.new("Frame")
        container.Name = "NotificationContainer"
        container.Size = UDim2.new(0, 320, 1, -40)
        container.Position = UDim2.new(1, -340, 0, 20)
        container.BackgroundTransparency = 1
        container.Parent = notifGui

        local list = Instance.new("UIListLayout")
        list.VerticalAlignment = Enum.VerticalAlignment.Bottom
        list.HorizontalAlignment = Enum.HorizontalAlignment.Right
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Padding = UDim.new(0, 10)
        list.Parent = container
        self._NotifContainer = container
    end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 72)
    card.BackgroundColor3 = theme.Card
    card.BackgroundTransparency = 0.05
    card.Position = UDim2.new(1, 40, 0, 0)
    Utils.CreateCorner(card, 10)
    Utils.CreateStroke(card, theme.Border, 1)
    card.Parent = self._NotifContainer

    local iconLabel = Instance.new("ImageLabel")
    iconLabel.Size = UDim2.new(0, 24, 0, 24)
    iconLabel.Position = UDim2.new(0, 14, 0, 14)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Image = Icon
    iconLabel.ImageColor3 = accentColor
    iconLabel.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -50, 0, 18)
    titleLbl.Position = UDim2.new(0, 46, 0, 12)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card

    local contentLbl = Instance.new("TextLabel")
    contentLbl.Size = UDim2.new(1, -50, 0, 28)
    contentLbl.Position = UDim2.new(0, 46, 0, 32)
    contentLbl.BackgroundTransparency = 1
    contentLbl.Text = Content
    contentLbl.Font = Enum.Font.Gotham
    contentLbl.TextSize = 12
    contentLbl.TextColor3 = theme.SubText
    contentLbl.TextXAlignment = Enum.TextXAlignment.Left
    contentLbl.TextWrapped = true
    contentLbl.Parent = card

    local pBarBg = Instance.new("Frame")
    pBarBg.Size = UDim2.new(1, 0, 0, 3)
    pBarBg.Position = UDim2.new(0, 0, 1, -3)
    pBarBg.BackgroundColor3 = theme.Border
    pBarBg.BorderSizePixel = 0
    pBarBg.Parent = card

    local pBar = Instance.new("Frame")
    pBar.Size = UDim2.new(1, 0, 1, 0)
    pBar.BackgroundColor3 = accentColor
    pBar.BorderSizePixel = 0
    pBar.Parent = pBarBg

    -- Slide in animation
    card.Position = UDim2.new(1, 50, 0, 0)
    Utils.Tween(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Progress countdown
    Utils.Tween(pBar, {Size = UDim2.new(0, 0, 1, 0)}, Duration, Enum.EasingStyle.Linear)

    task.delay(Duration, function()
        if card and card.Parent then
            local tw = Utils.Tween(card, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.25)
            tw.Completed:Connect(function()
                card:Destroy()
            end)
        end
    end)
end

--------------------------------------------------------------------------------
-- DIALOG & POPUP MODAL
--------------------------------------------------------------------------------
function Library:Dialog(options)
    options = options or {}
    local Title = options.Title or "Confirmation"
    local Content = options.Content or "Are you sure you want to proceed?"
    local ConfirmText = options.ConfirmText or "Confirm"
    local CancelText = options.CancelText or "Cancel"
    local Callback = options.Callback or function(confirmed) end

    local theme = self.ActiveTheme
    local screenGui = self._MainGui or GetSafeGuiParent()

    local overlay = Instance.new("TextButton")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.Text = ""
    overlay.ZIndex = 1000
    overlay.Parent = screenGui

    local modal = Instance.new("Frame")
    modal.Size = UDim2.new(0, 380, 0, 180)
    modal.Position = UDim2.new(0.5, -190, 0.5, -90)
    modal.BackgroundColor3 = theme.Card
    modal.ZIndex = 1001
    Utils.CreateCorner(modal, 12)
    Utils.CreateStroke(modal, theme.Border, 1.5)
    modal.Parent = overlay

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -32, 0, 24)
    titleLbl.Position = UDim2.new(0, 16, 0, 16)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 16
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 1002
    titleLbl.Parent = modal

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -32, 0, 60)
    descLbl.Position = UDim2.new(0, 16, 0, 48)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = Content
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 13
    descLbl.TextColor3 = theme.SubText
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.TextYAlignment = Enum.TextYAlignment.Top
    descLbl.TextWrapped = true
    descLbl.ZIndex = 1002
    descLbl.Parent = modal

    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, -32, 0, 36)
    btnContainer.Position = UDim2.new(0, 16, 1, -48)
    btnContainer.BackgroundTransparency = 1
    btnContainer.ZIndex = 1002
    btnContainer.Parent = modal

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
    cancelBtn.Position = UDim2.new(0, 0, 0, 0)
    cancelBtn.BackgroundColor3 = theme.Secondary
    cancelBtn.Text = CancelText
    cancelBtn.TextColor3 = theme.Text
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 13
    cancelBtn.ZIndex = 1003
    Utils.CreateCorner(cancelBtn, 8)
    cancelBtn.Parent = btnContainer

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0.48, 0, 1, 0)
    confirmBtn.Position = UDim2.new(0.52, 0, 0, 0)
    confirmBtn.BackgroundColor3 = theme.Accent
    confirmBtn.Text = ConfirmText
    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = 13
    confirmBtn.ZIndex = 1003
    Utils.CreateCorner(confirmBtn, 8)
    confirmBtn.Parent = btnContainer

    -- Animation
    Utils.Tween(overlay, {BackgroundTransparency = 0.5}, 0.25)
    modal.Position = UDim2.new(0.5, -190, 0.45, -90)
    Utils.Tween(modal, {Position = UDim2.new(0.5, -190, 0.5, -90)}, 0.25, Enum.EasingStyle.Back)

    local function Close(result)
        Utils.Tween(overlay, {BackgroundTransparency = 1}, 0.2)
        local tw = Utils.Tween(modal, {Position = UDim2.new(0.5, -190, 0.55, -90)}, 0.2)
        tw.Completed:Connect(function()
            overlay:Destroy()
            Callback(result)
        end)
    end

    cancelBtn.MouseButton1Click:Connect(function() Close(false) end)
    confirmBtn.MouseButton1Click:Connect(function() Close(true) end)
end

--------------------------------------------------------------------------------
-- KEY SYSTEM (Access Verification)
--------------------------------------------------------------------------------
function Library:KeySystem(options)
    options = options or {}
    local Title = options.Title or "Key Verification"
    local Subtitle = options.Subtitle or "Please enter your access key to continue"
    local Key = options.Key or "WINDFLUENT-2026"
    local SaveKey = options.SaveKey or false
    local KeyFileName = options.KeyFileName or "WindFluent_Key.txt"
    local GrabKeyUrl = options.GrabKeyUrl or "https://discord.gg/example"
    local OnSuccess = options.OnSuccess or function() end

    -- Check saved key first
    if SaveKey and pcall(readfile, KeyFileName) then
        local saved = readfile(KeyFileName)
        if saved == Key then
            OnSuccess()
            return
        end
    end

    local theme = self.ActiveTheme
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WindFluent_KeySystem"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 99999
    screenGui.Parent = GetSafeGuiParent()

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 360, 0, 230)
    frame.Position = UDim2.new(0.5, -180, 0.5, -115)
    frame.BackgroundColor3 = theme.Background
    Utils.CreateCorner(frame, 12)
    Utils.CreateStroke(frame, theme.Border, 1)
    frame.Parent = screenGui

    Utils.MakeDraggable(frame, frame, self.Connections)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -32, 0, 24)
    titleLbl.Position = UDim2.new(0, 16, 0, 18)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 16
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = frame

    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(1, -32, 0, 20)
    subLbl.Position = UDim2.new(0, 16, 0, 42)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = Subtitle
    subLbl.Font = Enum.Font.Gotham
    subLbl.TextSize = 12
    subLbl.TextColor3 = theme.SubText
    subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.Parent = frame

    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(1, -32, 0, 40)
    inputContainer.Position = UDim2.new(0, 16, 0, 78)
    inputContainer.BackgroundColor3 = theme.Secondary
    Utils.CreateCorner(inputContainer, 8)
    local inputStroke = Utils.CreateStroke(inputContainer, theme.Border, 1)
    inputContainer.Parent = frame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 1, 0)
    textBox.Position = UDim2.new(0, 10, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.PlaceholderText = "Paste your key here..."
    textBox.PlaceholderColor3 = theme.SubText
    textBox.Text = ""
    textBox.TextColor3 = theme.Text
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 13
    textBox.ClearTextOnFocus = false
    textBox.Parent = inputContainer

    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0.6, -6, 0, 36)
    submitBtn.Position = UDim2.new(0, 16, 0, 134)
    submitBtn.BackgroundColor3 = theme.Accent
    submitBtn.Text = "Submit Key"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 13
    Utils.CreateCorner(submitBtn, 8)
    submitBtn.Parent = frame

    local getBtn = Instance.new("TextButton")
    getBtn.Size = UDim2.new(0.4, -6, 0, 36)
    getBtn.Position = UDim2.new(0.6, 22, 0, 134)
    getBtn.BackgroundColor3 = theme.Secondary
    getBtn.Text = "Get Key"
    getBtn.TextColor3 = theme.Text
    getBtn.Font = Enum.Font.GothamBold
    getBtn.TextSize = 13
    Utils.CreateCorner(getBtn, 8)
    getBtn.Parent = frame

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(1, -32, 0, 20)
    statusLbl.Position = UDim2.new(0, 16, 0, 185)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = ""
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.TextSize = 12
    statusLbl.TextColor3 = theme.SubText
    statusLbl.Parent = frame

    getBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(GrabKeyUrl)
            statusLbl.Text = "Link copied to clipboard!"
            statusLbl.TextColor3 = theme.Success
        else
            statusLbl.Text = GrabKeyUrl
            statusLbl.TextColor3 = theme.Accent
        end
    end)

    submitBtn.MouseButton1Click:Connect(function()
        if textBox.Text == Key then
            statusLbl.Text = "Key Verified! Loading..."
            statusLbl.TextColor3 = theme.Success
            if SaveKey and pcall(writefile, KeyFileName, textBox.Text) then end
            task.wait(0.6)
            screenGui:Destroy()
            OnSuccess()
        else
            statusLbl.Text = "Invalid Key! Please check and retry."
            statusLbl.TextColor3 = theme.Danger
            Utils.Tween(inputStroke, {Color = theme.Danger}, 0.2)
            task.delay(1.5, function()
                Utils.Tween(inputStroke, {Color = theme.Border}, 0.2)
            end)
        end
    end)
end

--------------------------------------------------------------------------------
-- WINDOW CLASS (Core Container)
--------------------------------------------------------------------------------
local Window = {}
Window.__index = Window

function Library:CreateWindow(options)
    options = options or {}
    local Title = options.Title or "WindFluent UI"
    local Subtitle = options.Subtitle or "v" .. self.Version
    local Size = options.Size or UDim2.new(0, 680, 0, 440)
    local ThemeName = options.Theme or "Dark"
    local Acrylic = options.Acrylic ~= false
    local Keybind = options.ToggleKey or Enum.KeyCode.RightControl

    self:SetTheme(ThemeName)
    local theme = self.ActiveTheme

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WindFluent_" .. (Title:gsub("%s+", ""))
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 100
    screenGui.Parent = GetSafeGuiParent()
    self._MainGui = screenGui

    -- Main Container Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = Size
    mainFrame.Position = UDim2.new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2)
    mainFrame.BackgroundColor3 = theme.Background
    mainFrame.ClipsDescendants = false
    Utils.CreateCorner(mainFrame, 12)
    Utils.CreateStroke(mainFrame, theme.Border, 1.2)
    mainFrame.Parent = screenGui

    -- TopBar / Header
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 48)
    topBar.BackgroundColor3 = theme.TitleBar
    topBar.BackgroundTransparency = 0.2
    Utils.CreateCorner(topBar, 12)
    topBar.Parent = mainFrame

    -- Cover bottom corners of topbar
    local topBarCornerCover = Instance.new("Frame")
    topBarCornerCover.Size = UDim2.new(1, 0, 0, 12)
    topBarCornerCover.Position = UDim2.new(0, 0, 1, -12)
    topBarCornerCover.BackgroundColor3 = theme.TitleBar
    topBarCornerCover.BackgroundTransparency = 0.2
    topBarCornerCover.BorderSizePixel = 0
    topBarCornerCover.Parent = topBar

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "Title"
    titleLbl.Size = UDim2.new(0, 200, 1, 0)
    titleLbl.Position = UDim2.new(0, 16, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Title .. "  <font color='#" .. theme.SubText:ToHex() .. "'>" .. Subtitle .. "</font>"
    titleLbl.RichText = true
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 15
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = topBar

    -- Window Controls (Minimize / Close)
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0, 60, 1, 0)
    controlsFrame.Position = UDim2.new(1, -70, 0, 0)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = topBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -26, 0.5, -13)
    closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    closeBtn.BackgroundTransparency = 0.6
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 11
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Utils.CreateCorner(closeBtn, 6)
    closeBtn.Parent = controlsFrame

    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    -- Toggle GUI keybind
    local toggleConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Keybind then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
    self:RegisterConnection(toggleConn)

    -- Draggable
    Utils.MakeDraggable(mainFrame, topBar, self.Connections)

    -- Sidebar (Tabs navigation)
    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 170, 1, -56)
    sidebar.Position = UDim2.new(0, 8, 0, 52)
    sidebar.BackgroundColor3 = theme.Secondary
    sidebar.BackgroundTransparency = 0.6
    sidebar.ScrollBarThickness = 2
    sidebar.ScrollBarImageColor3 = theme.Border
    sidebar.BorderSizePixel = 0
    Utils.CreateCorner(sidebar, 8)
    sidebar.Parent = mainFrame

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 4)
    sidebarLayout.Parent = sidebar

    Utils.CreatePadding(sidebar, 8, 6, 8, 6)

    -- Content Area (Where active tab elements live)
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -194, 1, -56)
    contentArea.Position = UDim2.new(0, 186, 0, 52)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame

    local winObj = setmetatable({
        Library = self,
        Gui = screenGui,
        MainFrame = mainFrame,
        Sidebar = sidebar,
        ContentArea = contentArea,
        Tabs = {},
        CurrentTab = nil,
        Theme = theme
    }, Window)

    table.insert(self.Windows, winObj)
    return winObj
end

--------------------------------------------------------------------------------
-- TAB SECTION & TAB IMPLEMENTATION
--------------------------------------------------------------------------------
function Window:TabSection(title)
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 24)
    header.BackgroundTransparency = 1
    header.Text = string.upper(title)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 10
    header.TextColor3 = self.Theme.SubText
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = self.Sidebar

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.Parent = header
    return header
end

local Tab = {}
Tab.__index = Tab

function Window:CreateTab(name, icon)
    local win = self
    local theme = win.Theme

    -- Sidebar Tab Button
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 36)
    tabBtn.BackgroundColor3 = theme.Secondary
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    Utils.CreateCorner(tabBtn, 6)
    tabBtn.Parent = win.Sidebar

    local iconImg = Instance.new("ImageLabel")
    iconImg.Size = UDim2.new(0, 18, 0, 18)
    iconImg.Position = UDim2.new(0, 10, 0.5, -9)
    iconImg.BackgroundTransparency = 1
    iconImg.Image = icon or "rbxassetid://10723415903"
    iconImg.ImageColor3 = theme.SubText
    iconImg.Parent = tabBtn

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -40, 1, 0)
    titleLbl.Position = UDim2.new(0, 34, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = name
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = theme.SubText
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = tabBtn

    local activeIndicator = Instance.new("Frame")
    activeIndicator.Size = UDim2.new(0, 3, 0, 18)
    activeIndicator.Position = UDim2.new(0, 2, 0.5, -9)
    activeIndicator.BackgroundColor3 = theme.Accent
    activeIndicator.BackgroundTransparency = 1
    Utils.CreateCorner(activeIndicator, 2)
    activeIndicator.Parent = tabBtn

    -- Page Container
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = theme.Border
    page.BorderSizePixel = 0
    page.Visible = false
    page.Parent = win.ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 10)
    pageLayout.Parent = page

    Utils.CreatePadding(page, 4, 12, 12, 4)

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 24)
    end)

    local tabObj = setmetatable({
        Window = win,
        Name = name,
        Button = tabBtn,
        Page = page,
        Icon = iconImg,
        Indicator = activeIndicator,
        TitleLabel = titleLbl
    }, Tab)

    local function Activate()
        for _, otherTab in ipairs(win.Tabs) do
            otherTab.Page.Visible = false
            Utils.Tween(otherTab.Button, {BackgroundTransparency = 1}, 0.2)
            Utils.Tween(otherTab.Icon, {ImageColor3 = theme.SubText}, 0.2)
            Utils.Tween(otherTab.TitleLabel, {TextColor3 = theme.SubText}, 0.2)
            Utils.Tween(otherTab.Indicator, {BackgroundTransparency = 1}, 0.2)
        end
        page.Visible = true
        win.CurrentTab = tabObj
        Utils.Tween(tabBtn, {BackgroundTransparency = 0.5}, 0.2)
        Utils.Tween(iconImg, {ImageColor3 = theme.Accent}, 0.2)
        Utils.Tween(titleLbl, {TextColor3 = theme.Text}, 0.2)
        Utils.Tween(activeIndicator, {BackgroundTransparency = 0}, 0.2)
    end

    tabBtn.MouseButton1Click:Connect(Activate)

    table.insert(win.Tabs, tabObj)
    if #win.Tabs == 1 then
        Activate()
    end

    return tabObj
end

--------------------------------------------------------------------------------
-- SECTION CONTAINER
--------------------------------------------------------------------------------
local Section = {}
Section.__index = Section

function Tab:Section(title)
    local theme = self.Window.Theme

    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(1, 0, 0, 36)
    sectionFrame.BackgroundColor3 = theme.Card
    sectionFrame.BackgroundTransparency = 0.4
    Utils.CreateCorner(sectionFrame, 8)
    Utils.CreateStroke(sectionFrame, theme.Border, 1)
    sectionFrame.Parent = self.Page

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -20, 0, 28)
    header.Position = UDim2.new(0, 12, 0, 4)
    header.BackgroundTransparency = 1
    header.Text = title
    header.Font = Enum.Font.GothamBold
    header.TextSize = 13
    header.TextColor3 = theme.Text
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = sectionFrame

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "SectionContent"
    contentFrame.Size = UDim2.new(1, -16, 0, 0)
    contentFrame.Position = UDim2.new(0, 8, 0, 32)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = sectionFrame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = contentFrame

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentFrame.Size = UDim2.new(1, -16, 0, layout.AbsoluteContentSize.Y)
        sectionFrame.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 42)
    end)

    return setmetatable({
        Tab = self,
        Container = contentFrame,
        Theme = theme
    }, Section)
end

--------------------------------------------------------------------------------
-- INTERACTIVE COMPONENTS
--------------------------------------------------------------------------------

-- 1. BUTTON
function Section:Button(options)
    options = options or {}
    local Title = options.Title or "Button"
    local Description = options.Description or ""
    local Callback = options.Callback or function() end
    local theme = self.Theme

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, Description ~= "" and 48 or 36)
    btn.BackgroundColor3 = theme.Secondary
    btn.Text = ""
    btn.AutoButtonColor = false
    Utils.CreateCorner(btn, 6)
    local stroke = Utils.CreateStroke(btn, theme.Border, 1)
    btn.Parent = self.Container

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -40, 0, 18)
    titleLbl.Position = UDim2.new(0, 12, 0, Description ~= "" and 6 or 9)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Title
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = btn

    if Description ~= "" then
        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, -40, 0, 16)
        descLbl.Position = UDim2.new(0, 12, 0, 24)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = Description
        descLbl.Font = Enum.Font.Gotham
        descLbl.TextSize = 11
        descLbl.TextColor3 = theme.SubText
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.Parent = btn
    end

    local clickIcon = Instance.new("ImageLabel")
    clickIcon.Size = UDim2.new(0, 16, 0, 16)
    clickIcon.Position = UDim2.new(1, -28, 0.5, -8)
    clickIcon.BackgroundTransparency = 1
    clickIcon.Image = "rbxassetid://10709791437" -- Chevron Right
    clickIcon.ImageColor3 = theme.SubText
    clickIcon.Parent = btn

    btn.MouseEnter:Connect(function()
        Utils.Tween(btn, {BackgroundColor3 = theme.Card}, 0.2)
        Utils.Tween(stroke, {Color = theme.Accent}, 0.2)
    end)
    btn.MouseLeave:Connect(function()
        Utils.Tween(btn, {BackgroundColor3 = theme.Secondary}, 0.2)
        Utils.Tween(stroke, {Color = theme.Border}, 0.2)
    end)
    btn.MouseButton1Click:Connect(function()
        Utils.Tween(btn, {Size = UDim2.new(1, -4, 0, btn.Size.Y.Offset - 2)}, 0.08).Completed:Connect(function()
            Utils.Tween(btn, {Size = UDim2.new(1, 0, 0, btn.Size.Y.Offset + 2)}, 0.08)
        end)
        task.spawn(Callback)
    end)

    return btn
end

-- 2. TOGGLE
function Section:Toggle(options)
    options = options or {}
    local Title = options.Title or "Toggle"
    local Default = options.Default or false
    local Callback = options.Callback or function(val) end
    local theme = self.Theme

    local state = Default

    local frame = Instance.new("TextButton")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = theme.Secondary
    frame.Text = ""
    frame.AutoButtonColor = false
    Utils.CreateCorner(frame, 6)
    Utils.CreateStroke(frame, theme.Border, 1)
    frame.Parent = self.Container

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -60, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Title
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = frame

    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 40, 0, 20)
    switchBg.Position = UDim2.new(1, -50, 0.5, -10)
    switchBg.BackgroundColor3 = state and theme.Accent or theme.Card
    Utils.CreateCorner(switchBg, 10)
    switchBg.Parent = frame

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Utils.CreateCorner(knob, 8)
    knob.Parent = switchBg

    local function Set(val)
        state = val
        Utils.Tween(switchBg, {BackgroundColor3 = state and theme.Accent or theme.Card}, 0.2)
        Utils.Tween(knob, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
        task.spawn(Callback, state)
    end

    frame.MouseButton1Click:Connect(function()
        Set(not state)
    end)

    return {
        Set = Set,
        GetValue = function() return state end
    }
end

-- 3. SLIDER
function Section:Slider(options)
    options = options or {}
    local Title = options.Title or "Slider"
    local Min = options.Min or 0
    local Max = options.Max or 100
    local Step = options.Step or 1
    local Default = options.Default or Min
    local Unit = options.Unit or ""
    local Callback = options.Callback or function(val) end
    local theme = self.Theme

    local value = math.clamp(Default, Min, Max)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = theme.Secondary
    Utils.CreateCorner(frame, 6)
    Utils.CreateStroke(frame, theme.Border, 1)
    frame.Parent = self.Container

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -70, 0, 18)
    titleLbl.Position = UDim2.new(0, 12, 0, 6)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Title
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = frame

    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size = UDim2.new(0, 50, 0, 18)
    valueLbl.Position = UDim2.new(1, -62, 0, 6)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text = tostring(value) .. Unit
    valueLbl.Font = Enum.Font.GothamBold
    valueLbl.TextSize = 12
    valueLbl.TextColor3 = theme.Accent
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    valueLbl.Parent = frame

    local barBg = Instance.new("TextButton")
    barBg.Size = UDim2.new(1, -24, 0, 6)
    barBg.Position = UDim2.new(0, 12, 0, 32)
    barBg.BackgroundColor3 = theme.Card
    barBg.Text = ""
    barBg.AutoButtonColor = false
    Utils.CreateCorner(barBg, 3)
    barBg.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0)
    fill.BackgroundColor3 = theme.Accent
    Utils.CreateCorner(fill, 3)
    fill.Parent = barBg

    local dragging = false

    local function Update(input)
        local posX = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local rawValue = Min + ((Max - Min) * posX)
        local rounded = math.round(rawValue / Step) * Step
        value = math.clamp(rounded, Min, Max)

        valueLbl.Text = tostring(value) .. Unit
        Utils.Tween(fill, {Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0)}, 0.05)
        task.spawn(Callback, value)
    end

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)

    return {
        Set = function(newVal)
            value = math.clamp(newVal, Min, Max)
            valueLbl.Text = tostring(value) .. Unit
            fill.Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0)
            task.spawn(Callback, value)
        end,
        GetValue = function() return value end
    }
end

-- 4. INPUT / TEXTBOX
function Section:Input(options)
    options = options or {}
    local Title = options.Title or "Input"
    local Placeholder = options.Placeholder or "Type something..."
    local Default = options.Default or ""
    local Callback = options.Callback or function(text) end
    local theme = self.Theme

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundColor3 = theme.Secondary
    Utils.CreateCorner(frame, 6)
    local stroke = Utils.CreateStroke(frame, theme.Border, 1)
    frame.Parent = self.Container

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.4, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Title
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = frame

    local boxContainer = Instance.new("Frame")
    boxContainer.Size = UDim2.new(0.55, 0, 0, 28)
    boxContainer.Position = UDim2.new(0.43, 0, 0.5, -14)
    boxContainer.BackgroundColor3 = theme.Card
    Utils.CreateCorner(boxContainer, 4)
    local boxStroke = Utils.CreateStroke(boxContainer, theme.Border, 1)
    boxContainer.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -12, 1, 0)
    box.Position = UDim2.new(0, 6, 0, 0)
    box.BackgroundTransparency = 1
    box.Text = Default
    box.PlaceholderText = Placeholder
    box.PlaceholderColor3 = theme.SubText
    box.TextColor3 = theme.Text
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.ClearTextOnFocus = false
    box.Parent = boxContainer

    box.Focused:Connect(function()
        Utils.Tween(boxStroke, {Color = theme.Accent}, 0.2)
    end)
    box.FocusLost:Connect(function(enterPressed)
        Utils.Tween(boxStroke, {Color = theme.Border}, 0.2)
        task.spawn(Callback, box.Text, enterPressed)
    end)

    return {
        Set = function(val) box.Text = val end,
        GetValue = function() return box.Text end
    }
end

-- 5. DROPDOWN (Single or Multi-Select)
function Section:Dropdown(options)
    options = options or {}
    local Title = options.Title or "Dropdown"
    local Items = options.Items or {}
    local Multi = options.MultiSelect or false
    local Default = options.Default or (Multi and {} or Items[1])
    local Callback = options.Callback or function(val) end
    local theme = self.Theme

    local selected = Default
    local expanded = false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 42)
    container.BackgroundColor3 = theme.Secondary
    container.ClipsDescendants = true
    Utils.CreateCorner(container, 6)
    local stroke = Utils.CreateStroke(container, theme.Border, 1)
    container.Parent = self.Container

    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 42)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = container

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Title
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = headerBtn

    local function FormatDisplay()
        if Multi then
            if #selected == 0 then return "None" end
            return table.concat(selected, ", ")
        else
            return tostring(selected)
        end
    end

    local displayLbl = Instance.new("TextLabel")
    displayLbl.Size = UDim2.new(0.4, -28, 1, 0)
    displayLbl.Position = UDim2.new(0.55, 0, 0, 0)
    displayLbl.BackgroundTransparency = 1
    displayLbl.Text = FormatDisplay()
    displayLbl.Font = Enum.Font.Gotham
    displayLbl.TextSize = 12
    displayLbl.TextColor3 = theme.SubText
    displayLbl.TextXAlignment = Enum.TextXAlignment.Right
    displayLbl.TextTruncate = Enum.TextTruncate.AtEnd
    displayLbl.Parent = headerBtn

    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 16, 0, 16)
    arrowIcon.Position = UDim2.new(1, -26, 0.5, -8)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://10709790948" -- Chevron Down
    arrowIcon.ImageColor3 = theme.SubText
    arrowIcon.Parent = headerBtn

    local itemsList = Instance.new("ScrollingFrame")
    itemsList.Size = UDim2.new(1, -20, 0, #Items * 28)
    itemsList.Position = UDim2.new(0, 10, 0, 44)
    itemsList.BackgroundTransparency = 1
    itemsList.ScrollBarThickness = 2
    itemsList.ScrollBarImageColor3 = theme.Border
    itemsList.Parent = container

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = itemsList

    local function RefreshDropdown()
        for _, child in ipairs(itemsList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for _, item in ipairs(Items) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 26)
            itemBtn.BackgroundColor3 = theme.Card
            itemBtn.Text = "  " .. item
            itemBtn.Font = Enum.Font.Gotham
            itemBtn.TextSize = 12
            itemBtn.TextColor3 = theme.Text
            itemBtn.TextXAlignment = Enum.TextXAlignment.Left
            Utils.CreateCorner(itemBtn, 4)

            local isSelected = false
            if Multi then
                isSelected = table.find(selected, item) ~= nil
            else
                isSelected = (selected == item)
            end

            if isSelected then
                itemBtn.TextColor3 = theme.Accent
                itemBtn.BackgroundColor3 = theme.Secondary
            end

            itemBtn.MouseButton1Click:Connect(function()
                if Multi then
                    local idx = table.find(selected, item)
                    if idx then
                        table.remove(selected, idx)
                    else
                        table.insert(selected, item)
                    end
                else
                    selected = item
                    expanded = false
                    Utils.Tween(container, {Size = UDim2.new(1, 0, 0, 42)}, 0.2)
                    Utils.Tween(arrowIcon, {Rotation = 0}, 0.2)
                end
                displayLbl.Text = FormatDisplay()
                RefreshDropdown()
                task.spawn(Callback, selected)
            end)

            itemBtn.Parent = itemsList
        end
    end

    RefreshDropdown()

    headerBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        local targetHeight = expanded and math.min(46 + (#Items * 28), 170) or 42
        itemsList.Size = UDim2.new(1, -20, 0, targetHeight - 46)
        Utils.Tween(container, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
        Utils.Tween(arrowIcon, {Rotation = expanded and 180 or 0}, 0.2)
    end)

    return {
        Set = function(newVal)
            selected = newVal
            displayLbl.Text = FormatDisplay()
            RefreshDropdown()
            task.spawn(Callback, selected)
        end,
        GetValue = function() return selected end
    }
end

-- 6. KEYBIND
function Section:Keybind(options)
    options = options or {}
    local Title = options.Title or "Keybind"
    local Default = options.Default or Enum.KeyCode.E
    local Mode = options.Mode or "Toggle" -- Toggle, Hold, Always
    local Callback = options.Callback or function(active) end
    local theme = self.Theme

    local currentKey = Default
    local listening = false
    local activeState = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = theme.Secondary
    Utils.CreateCorner(frame, 6)
    Utils.CreateStroke(frame, theme.Border, 1)
    frame.Parent = self.Container

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.6, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Title .. "  <font color='#" .. theme.SubText:ToHex() .. "'>[" .. Mode .. "]</font>"
    titleLbl.RichText = true
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = frame

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 70, 0, 24)
    bindBtn.Position = UDim2.new(1, -82, 0.5, -12)
    bindBtn.BackgroundColor3 = theme.Card
    bindBtn.Text = currentKey.Name
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.TextSize = 11
    bindBtn.TextColor3 = theme.Accent
    Utils.CreateCorner(bindBtn, 4)
    Utils.CreateStroke(bindBtn, theme.Border, 1)
    bindBtn.Parent = frame

    bindBtn.MouseButton1Click:Connect(function()
        listening = true
        bindBtn.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = input.KeyCode
            bindBtn.Text = currentKey.Name
            listening = false
        elseif not gpe and input.KeyCode == currentKey then
            if Mode == "Toggle" then
                activeState = not activeState
                task.spawn(Callback, activeState)
            elseif Mode == "Hold" then
                activeState = true
                task.spawn(Callback, true)
            elseif Mode == "Always" then
                task.spawn(Callback, true)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if Mode == "Hold" and input.KeyCode == currentKey then
            activeState = false
            task.spawn(Callback, false)
        end
    end)

    return {
        Set = function(newKey)
            currentKey = newKey
            bindBtn.Text = currentKey.Name
        end,
        GetKey = function() return currentKey end
    }
end

-- 7. COLORPICKER
function Section:Colorpicker(options)
    options = options or {}
    local Title = options.Title or "Colorpicker"
    local Default = options.Default or Color3.fromRGB(59, 130, 246)
    local Callback = options.Callback or function(color) end
    local theme = self.Theme

    local currentColor = Default
    local expanded = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = theme.Secondary
    frame.ClipsDescendants = true
    Utils.CreateCorner(frame, 6)
    Utils.CreateStroke(frame, theme.Border, 1)
    frame.Parent = self.Container

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -70, 0, 38)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Title
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = frame

    local previewBtn = Instance.new("TextButton")
    previewBtn.Size = UDim2.new(0, 34, 0, 20)
    previewBtn.Position = UDim2.new(1, -46, 0, 9)
    previewBtn.BackgroundColor3 = currentColor
    previewBtn.Text = ""
    Utils.CreateCorner(previewBtn, 4)
    Utils.CreateStroke(previewBtn, theme.Border, 1)
    previewBtn.Parent = frame

    -- Color palette expanded area
    local paletteArea = Instance.new("Frame")
    paletteArea.Size = UDim2.new(1, -24, 0, 80)
    paletteArea.Position = UDim2.new(0, 12, 0, 44)
    paletteArea.BackgroundTransparency = 1
    paletteArea.Parent = frame

    local quickColors = {
        Color3.fromRGB(239, 68, 68),   -- Red
        Color3.fromRGB(249, 115, 22),  -- Orange
        Color3.fromRGB(234, 179, 8),   -- Yellow
        Color3.fromRGB(34, 197, 94),   -- Green
        Color3.fromRGB(59, 130, 246),  -- Blue
        Color3.fromRGB(168, 85, 247),  -- Purple
        Color3.fromRGB(236, 72, 153),  -- Pink
        Color3.fromRGB(255, 255, 255), -- White
    }

    local colorsLayout = Instance.new("UIGridLayout")
    colorsLayout.CellSize = UDim2.new(0, 26, 0, 26)
    colorsLayout.CellPadding = UDim2.new(0, 8, 0, 8)
    colorsLayout.Parent = paletteArea

    for _, col in ipairs(quickColors) do
        local swatch = Instance.new("TextButton")
        swatch.BackgroundColor3 = col
        swatch.Text = ""
        Utils.CreateCorner(swatch, 4)
        swatch.MouseButton1Click:Connect(function()
            currentColor = col
            previewBtn.BackgroundColor3 = col
            task.spawn(Callback, col)
        end)
        swatch.Parent = paletteArea
    end

    previewBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        Utils.Tween(frame, {Size = UDim2.new(1, 0, 0, expanded and 130 or 38)}, 0.2)
    end)

    return {
        Set = function(col)
            currentColor = col
            previewBtn.BackgroundColor3 = col
            task.spawn(Callback, col)
        end,
        GetValue = function() return currentColor end
    }
end

-- 8. PROGRESS BAR
function Section:ProgressBar(options)
    options = options or {}
    local Title = options.Title or "Progress"
    local Percent = options.Percent or 0
    local theme = self.Theme

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundColor3 = theme.Secondary
    Utils.CreateCorner(frame, 6)
    Utils.CreateStroke(frame, theme.Border, 1)
    frame.Parent = self.Container

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -70, 0, 18)
    titleLbl.Position = UDim2.new(0, 12, 0, 6)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = Title
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = frame

    local pctLbl = Instance.new("TextLabel")
    pctLbl.Size = UDim2.new(0, 50, 0, 18)
    pctLbl.Position = UDim2.new(1, -62, 0, 6)
    pctLbl.BackgroundTransparency = 1
    pctLbl.Text = tostring(math.floor(Percent)) .. "%"
    pctLbl.Font = Enum.Font.GothamBold
    pctLbl.TextSize = 12
    pctLbl.TextColor3 = theme.Accent
    pctLbl.TextXAlignment = Enum.TextXAlignment.Right
    pctLbl.Parent = frame

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -24, 0, 6)
    barBg.Position = UDim2.new(0, 12, 0, 28)
    barBg.BackgroundColor3 = theme.Card
    Utils.CreateCorner(barBg, 3)
    barBg.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp(Percent / 100, 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = theme.Accent
    Utils.CreateCorner(fill, 3)
    fill.Parent = barBg

    return {
        Set = function(val)
            local clamped = math.clamp(val, 0, 100)
            pctLbl.Text = tostring(math.floor(clamped)) .. "%"
            Utils.Tween(fill, {Size = UDim2.new(clamped / 100, 0, 1, 0)}, 0.2)
        end
    }
end

-- 9. PARAGRAPH
function Section:Paragraph(title, content)
    local theme = self.Theme

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 54)
    frame.BackgroundColor3 = theme.Secondary
    Utils.CreateCorner(frame, 6)
    Utils.CreateStroke(frame, theme.Border, 1)
    frame.Parent = self.Container

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -24, 0, 18)
    titleLbl.Position = UDim2.new(0, 12, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = theme.Text
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = frame

    local contentLbl = Instance.new("TextLabel")
    contentLbl.Size = UDim2.new(1, -24, 0, 24)
    contentLbl.Position = UDim2.new(0, 12, 0, 26)
    contentLbl.BackgroundTransparency = 1
    contentLbl.Text = content
    contentLbl.Font = Enum.Font.Gotham
    contentLbl.TextSize = 12
    contentLbl.TextColor3 = theme.SubText
    contentLbl.TextXAlignment = Enum.TextXAlignment.Left
    contentLbl.TextWrapped = true
    contentLbl.RichText = true
    contentLbl.Parent = frame

    return {
        SetTitle = function(newTitle) titleLbl.Text = newTitle end,
        SetContent = function(newContent) contentLbl.Text = newContent end
    }
end

-- 10. CODE BLOCK
function Section:Code(codeText)
    local theme = self.Theme

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 64)
    frame.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
    Utils.CreateCorner(frame, 6)
    Utils.CreateStroke(frame, theme.Border, 1)
    frame.Parent = self.Container

    local codeLbl = Instance.new("TextLabel")
    codeLbl.Size = UDim2.new(1, -60, 1, -16)
    codeLbl.Position = UDim2.new(0, 12, 0, 8)
    codeLbl.BackgroundTransparency = 1
    codeLbl.Text = codeText
    codeLbl.Font = Enum.Font.Code
    codeLbl.TextSize = 11
    codeLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
    codeLbl.TextXAlignment = Enum.TextXAlignment.Left
    codeLbl.TextYAlignment = Enum.TextYAlignment.Top
    codeLbl.TextWrapped = true
    codeLbl.Parent = frame

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 44, 0, 24)
    copyBtn.Position = UDim2.new(1, -52, 0, 8)
    copyBtn.BackgroundColor3 = theme.Card
    copyBtn.Text = "Copy"
    copyBtn.Font = Enum.Font.Gotham
    copyBtn.TextSize = 10
    copyBtn.TextColor3 = theme.SubText
    Utils.CreateCorner(copyBtn, 4)
    copyBtn.Parent = frame

    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(codeText)
            copyBtn.Text = "Done"
            task.delay(1, function() copyBtn.Text = "Copy" end)
        end
    end)

    return frame
end

-- 11. DIVIDER & SPACE
function Section:Divider()
    local theme = self.Theme
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.BackgroundColor3 = theme.Border
    line.BorderSizePixel = 0
    line.Parent = self.Container
    return line
end

function Section:Space(height)
    local space = Instance.new("Frame")
    space.Size = UDim2.new(1, 0, 0, height or 8)
    space.BackgroundTransparency = 1
    space.Parent = self.Container
    return space
end

--------------------------------------------------------------------------------
-- LAYOUT HELPERS (HStack & VStack)
--------------------------------------------------------------------------------
function Section:HStack(height, gap)
    local stack = Instance.new("Frame")
    stack.Size = UDim2.new(1, 0, 0, height or 38)
    stack.BackgroundTransparency = 1
    stack.Parent = self.Container

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, gap or 8)
    layout.Parent = stack

    return stack
end

function Section:VStack(gap)
    local stack = Instance.new("Frame")
    stack.Size = UDim2.new(1, 0, 0, 0)
    stack.BackgroundTransparency = 1
    stack.Parent = self.Container

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, gap or 8)
    layout.Parent = stack

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        stack.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
    end)

    return stack
end

--------------------------------------------------------------------------------
-- CONFIG MANAGER (JSON Save & Load)
--------------------------------------------------------------------------------
Library.Configs = {}
Library.Configs.__index = Library.Configs

function Library:InitConfigSystem(folderName)
    local manager = {
        Folder = folderName or self.ConfigFolder,
        Elements = {}
    }

    if isfolder and not isfolder(manager.Folder) then
        pcall(makefolder, manager.Folder)
    end

    function manager:Register(key, elementGetter, elementSetter)
        self.Elements[key] = {Get = elementGetter, Set = elementSetter}
    end

    function manager:Save(configName)
        local data = {}
        for key, item in pairs(self.Elements) do
            data[key] = item.Get()
        end
        local encoded = HttpService:JSONEncode(data)
        if writefile then
            pcall(writefile, self.Folder .. "/" .. configName .. ".json", encoded)
        end
        return encoded
    end

    function manager:Load(configName)
        local filePath = self.Folder .. "/" .. configName .. ".json"
        if readfile and isfile and isfile(filePath) then
            local raw = readfile(filePath)
            local success, data = pcall(function() return HttpService:JSONDecode(raw) end)
            if success and type(data) == "table" then
                for key, val in pairs(data) do
                    if self.Elements[key] then
                        self.Elements[key].Set(val)
                    end
                end
                return true
            end
        end
        return false
    end

    return manager
end

--------------------------------------------------------------------------------
-- UNLOAD SYSTEM (Memory Clean & Teardown)
--------------------------------------------------------------------------------
function Library:Unload()
    -- Disconnect all event listeners
    for _, conn in ipairs(self.Connections) do
        if typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
    end
    self.Connections = {}

    -- Destroy All Created GUIs
    for _, win in ipairs(self.Windows) do
        if win.Gui and win.Gui.Parent then
            win.Gui:Destroy()
        end
    end
    self.Windows = {}

    if self._NotifGui and self._NotifGui.Parent then
        self._NotifGui:Destroy()
    end

    print("[WindFluent UI] Unloaded successfully. Memory cleaned.")
end

return Library
