-- ================= ================= =================
--  CUSTOM UI LIBRARY (ANIMATED & COMPLETE)
-- ================= ================= =================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    Flags = {},
    Connections = {},
    Themes = {
        Background = Color3.fromRGB(18, 18, 22),
        Container = Color3.fromRGB(25, 25, 30),
        Section = Color3.fromRGB(32, 32, 38),
        Accent = Color3.fromRGB(155, 150, 219),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(130, 130, 130),
        Border = Color3.fromRGB(40, 40, 48)
    }
}
Library.__index = Library

-- ฟังก์ชัน Helper สำหรับเล่นอนิเมชั่น (Tween)
function Library:Tween(instance, properties, duration, style)
    local tweenInfo = TweenInfo.new(
        duration or 0.2, 
        style or Enum.EasingStyle.Quint, 
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- ระบบ Drag (ลากเคลื่อนย้ายหน้าต่าง UI)
function Library:MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Library:Tween(gui, {
                Position = UDim2.new(
                    startPos.X.Scale, 
                    startPos.X.Offset + delta.X, 
                    startPos.Y.Scale, 
                    startPos.Y.Offset + delta.Y
                )
            }, 0.05, Enum.EasingStyle.Linear)
        end
    end)
end

-- 1. สร้างหน้าต่างหลัก (Window)
function Library:CreateWindow(options)
    options = options or {}
    local windowName = options.Name or "UI Library"

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomUILibrary"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 580, 0, 380)
    Main.Position = UDim2.new(0.5, -290, 0.5, -190)
    Main.BackgroundColor3 = Library.Themes.Background
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Library.Themes.Border
    Stroke.Thickness = 1
    Stroke.Parent = Main

    -- Header Bar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Text = windowName
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.TextColor3 = Library.Themes.Text
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = TopBar

    -- Sidebar Container (สำหรับใส่ปุ่ม Tab)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, -50)
    Sidebar.Position = UDim2.new(0, 10, 0, 45)
    Sidebar.BackgroundColor3 = Library.Themes.Container
    Sidebar.Parent = Main

    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = Sidebar

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 8)
    TabPadding.PaddingLeft = UDim.new(0, 8)
    TabPadding.PaddingRight = UDim.new(0, 8)
    TabPadding.Parent = Sidebar

    -- Main Content Area
    local ContentFolder = Instance.new("Frame")
    ContentFolder.Size = UDim2.new(1, -180, 1, -55)
    ContentFolder.Position = UDim2.new(0, 170, 0, 45)
    ContentFolder.BackgroundTransparency = 1
    ContentFolder.Parent = Main

    Library:MakeDraggable(Main)

    local WindowObj = {
        ScreenGui = ScreenGui,
        Main = Main,
        Sidebar = Sidebar,
        ContentFolder = ContentFolder,
        Tabs = {},
        CurrentTab = nil
    }

    -- 2. สร้าง Tab
    function WindowObj:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Library.Themes.Section
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Library.Themes.SubText
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 14
        TabBtn.Parent = Sidebar

        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = Library.Themes.Accent
        TabPage.Parent = ContentFolder

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = TabPage

        local TabObj = { Page = TabPage }

        function TabObj:Activate()
            for _, t in pairs(WindowObj.Tabs) do
                t.Page.Visible = false
                Library:Tween(t.Btn, {BackgroundTransparency = 1, TextColor3 = Library.Themes.SubText}, 0.2)
            end
            TabPage.Visible = true
            Library:Tween(TabBtn, {BackgroundTransparency = 0, TextColor3 = Library.Themes.Accent}, 0.2)
            WindowObj.CurrentTab = TabObj
        end

        TabBtn.MouseButton1Click:Connect(function()
            TabObj:Activate()
        end)

        table.insert(WindowObj.Tabs, { Btn = TabBtn, Page = TabPage })

        if #WindowObj.Tabs == 1 then
            TabObj:Activate()
        end

        -- 3. สร้าง Section สำหรับเก็บ Components
        function TabObj:CreateSection(sectionName)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, -10, 0, 40)
            SectionFrame.BackgroundColor3 = Library.Themes.Container
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.Parent = TabPage

            Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 8)

            local SecTitle = Instance.new("TextLabel")
            SecTitle.Text = sectionName
            SecTitle.Size = UDim2.new(1, -20, 0, 25)
            SecTitle.Position = UDim2.new(0, 10, 0, 5)
            SecTitle.TextColor3 = Library.Themes.Accent
            SecTitle.TextSize = 14
            SecTitle.Font = Enum.Font.GothamBold
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left
            SecTitle.BackgroundTransparency = 1
            SecTitle.Parent = SectionFrame

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, -20, 0, 0)
            Container.Position = UDim2.new(0, 10, 0, 30)
            Container.AutomaticSize = Enum.AutomaticSize.Y
            Container.BackgroundTransparency = 1
            Container.Parent = SectionFrame

            local SecLayout = Instance.new("UIListLayout")
            SecLayout.Padding = UDim.new(0, 8)
            SecLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SecLayout.Parent = Container

            local SecPadding = Instance.new("UIPadding")
            SecPadding.PaddingBottom = UDim.new(0, 10)
            SecPadding.Parent = Container

            local SectionObj = {}

            -- Component: Toggle (สวิตช์เปิด/ปิด พร้อมอนิเมชั่น)
            function SectionObj:CreateToggle(opts)
                opts = opts or {}
                local name = opts.Name or "Toggle"
                local default = opts.Default or false
                local callback = opts.Callback or function() end

                local enabled = default

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = Container

                local TglText = Instance.new("TextLabel")
                TglText.Text = name
                TglText.Size = UDim2.new(0.7, 0, 1, 0)
                TglText.TextColor3 = Library.Themes.Text
                TglText.Font = Enum.Font.Gotham
                TglText.TextSize = 13
                TglText.TextXAlignment = Enum.TextXAlignment.Left
                TglText.BackgroundTransparency = 1
                TglText.Parent = ToggleFrame

                local Switch = Instance.new("TextButton")
                Switch.Text = ""
                Switch.Size = UDim2.new(0, 38, 0, 20)
                Switch.Position = UDim2.new(1, -38, 0.5, -10)
                Switch.BackgroundColor3 = enabled and Library.Themes.Accent or Library.Themes.Section
                Switch.AutoButtonColor = false
                Switch.Parent = ToggleFrame

                Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

                local Circle = Instance.new("Frame")
                Circle.Size = UDim2.new(0, 14, 0, 14)
                Circle.Position = enabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Circle.Parent = Switch

                Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

                local function SetState(state)
                    enabled = state
                    local targetColor = enabled and Library.Themes.Accent or Library.Themes.Section
                    local targetPos = enabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)

                    Library:Tween(Switch, {BackgroundColor3 = targetColor}, 0.2)
                    Library:Tween(Circle, {Position = targetPos}, 0.2)
                    callback(enabled)
                end

                Switch.MouseButton1Click:Connect(function()
                    SetState(not enabled)
                end)

                return { Set = SetState }
            end

            -- Component: Slider (แถบปรับระดับ)
            function SectionObj:CreateSlider(opts)
                opts = opts or {}
                local name = opts.Name or "Slider"
                local min = opts.Min or 0
                local max = opts.Max or 100
                local default = opts.Default or min
                local callback = opts.Callback or function() end

                local value = math.clamp(default, min, max)
                local dragging = false

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 40)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = Container

                local Title = Instance.new("TextLabel")
                Title.Text = name
                Title.Size = UDim2.new(0.5, 0, 0, 18)
                Title.TextColor3 = Library.Themes.Text
                Title.Font = Enum.Font.Gotham
                Title.TextSize = 13
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.BackgroundTransparency = 1
                Title.Parent = SliderFrame

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Text = tostring(value)
                ValLabel.Size = UDim2.new(0.5, 0, 0, 18)
                ValLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ValLabel.TextColor3 = Library.Themes.SubText
                ValLabel.Font = Enum.Font.Gotham
                ValLabel.TextSize = 13
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.BackgroundTransparency = 1
                ValLabel.Parent = SliderFrame

                local Track = Instance.new("TextButton")
                Track.Text = ""
                Track.Size = UDim2.new(1, 0, 0, 6)
                Track.Position = UDim2.new(0, 0, 0, 26)
                Track.BackgroundColor3 = Library.Themes.Section
                Track.AutoButtonColor = false
                Track.Parent = SliderFrame

                Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Library.Themes.Accent
                Fill.Parent = Track

                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

                local function Update(input)
                    local percent = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (max - min) * percent)
                    ValLabel.Text = tostring(value)
                    Library:Tween(Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.05, Enum.EasingStyle.Linear)
                    callback(value)
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        Update(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(input)
                    end
                end)
            end

            -- Component: Dropdown (เมนูตัวเลือกแบบยืด/ขยายอนิเมชั่น)
            function SectionObj:CreateDropdown(opts)
                opts = opts or {}
                local name = opts.Name or "Dropdown"
                local items = opts.Items or {}
                local callback = opts.Callback or function() end

                local isOpen = false
                local selected = items[1] or "None"

                local DropFrame = Instance.new("Frame")
                DropFrame.Size = UDim2.new(1, 0, 0, 32)
                DropFrame.BackgroundColor3 = Library.Themes.Section
                DropFrame.ClipsDescendants = true
                DropFrame.Parent = Container

                Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)

                local DropBtn = Instance.new("TextButton")
                DropBtn.Text = name .. " : " .. selected
                DropBtn.Size = UDim2.new(1, -10, 0, 32)
                DropBtn.Position = UDim2.new(0, 10, 0, 0)
                DropBtn.TextColor3 = Library.Themes.Text
                DropBtn.Font = Enum.Font.Gotham
                DropBtn.TextSize = 13
                DropBtn.TextXAlignment = Enum.TextXAlignment.Left
                DropBtn.BackgroundTransparency = 1
                DropBtn.Parent = DropFrame

                local ListHolder = Instance.new("Frame")
                ListHolder.Size = UDim2.new(1, 0, 0, 0)
                ListHolder.Position = UDim2.new(0, 0, 0, 32)
                ListHolder.BackgroundTransparency = 1
                ListHolder.Parent = DropFrame

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Parent = ListHolder

                local expandedHeight = 32 + (#items * 28)

                for _, itemText in ipairs(items) do
                    local ItemBtn = Instance.new("TextButton")
                    ItemBtn.Text = itemText
                    ItemBtn.Size = UDim2.new(1, 0, 0, 28)
                    ItemBtn.TextColor3 = Library.Themes.SubText
                    ItemBtn.Font = Enum.Font.Gotham
                    ItemBtn.TextSize = 12
                    ItemBtn.BackgroundTransparency = 1
                    ItemBtn.Parent = ListHolder

                    ItemBtn.MouseButton1Click:Connect(function()
                        selected = itemText
                        DropBtn.Text = name .. " : " .. selected
                        isOpen = false
                        Library:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 32)}, 0.25)
                        callback(selected)
                    end)
                end

                DropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    local targetSize = isOpen and UDim2.new(1, 0, 0, expandedHeight) or UDim2.new(1, 0, 0, 32)
                    Library:Tween(DropFrame, {Size = targetSize}, 0.25)
                end)
            end

            return SectionObj
        end

        return TabObj
    end

    return WindowObj
end

return Library
