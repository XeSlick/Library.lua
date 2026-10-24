--[[

    XEZIOS UI LIBRARY
    -> Made by @finobe 
    -> Optimized for Roblox Luau & Studio
]]

if getgenv and getgenv().Loaded then 
    getgenv().Library:Unload()
end 

if getgenv then
    getgenv().Loaded = true 
end

-- Variables 
    -- Services
    local InputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")
    local GuiService = game:GetService("GuiService")
    local RunService = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local SoundService = game:GetService("SoundService")
    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")

    local Camera = Workspace.CurrentCamera
    local lp = Players.LocalPlayer
    local gui_offset = GuiService:GetGuiInset().Y
    local mouse = lp and lp:GetMouse()

    -- Safe parent determination
    local function GetSafeParent()
        local success, result = pcall(function()
            return CoreGui
        end)
        if success and result then
            local test = Instance.new("Folder")
            local pSuccess = pcall(function()
                test.Parent = CoreGui
                test:Destroy()
            end)
            if pSuccess then return CoreGui end
        end
        return lp:WaitForChild("PlayerGui")
    end

    -- Data types
    local vec2, vec3, dim2, dim, rect, dim_offset = Vector2.new, Vector3.new, UDim2.new, UDim.new, Rect.new, UDim2.fromOffset

    -- Extra data types
    local color, rgb, hex, hsv, rgbseq, rgbkey, numseq, numkey = Color3.new, Color3.fromRGB, Color3.fromHex, Color3.fromHSV, ColorSequence.new, ColorSequenceKeypoint.new, NumberSequence.new, NumberSequenceKeypoint.new
-- 

-- Library init
    local Library = {
        Directory = "xezios",
        Folders = {
            "/fonts",
            "/configs",
        },
        Flags = {},
        ConfigFlags = {},
        Connections = {},   
        Notifications = {Notifs = {}},
        OpenElement = {}; -- type: table or userdata
    }

    if getgenv then
        getgenv().Library = Library
    end

    local themes = {
        preset = {
            accent = rgb(108, 109, 152),
            window_outline = rgb(0, 0, 0),
            inline = rgb(25, 27, 27),
            background = rgb(17, 19, 19),
            visible_backgrounds = rgb(20, 23, 22),
            text_color = rgb(221, 223, 222),
            glow = rgb(0, 0, 0),
            deselected = rgb(89, 91, 91),
        },
        utility = {},
        gradients = {
            Selected = {};
            Deselected = {};
        },
    }

    for theme, col in pairs(themes.preset) do 
        themes.utility[theme] = {
            BackgroundColor3 = {}; 	
            TextColor3 = {};
            ImageColor3 = {};
            ScrollBarImageColor3 = {};
            Color = {};
        }
    end 

    local Keys = {
        [Enum.KeyCode.LeftShift] = "LS",
        [Enum.KeyCode.RightShift] = "RS",
        [Enum.KeyCode.LeftControl] = "LC",
        [Enum.KeyCode.RightControl] = "RC",
        [Enum.KeyCode.Insert] = "INS",
        [Enum.KeyCode.Backspace] = "BS",
        [Enum.KeyCode.Return] = "Ent",
        [Enum.KeyCode.LeftAlt] = "LA",
        [Enum.KeyCode.RightAlt] = "RA",
        [Enum.KeyCode.CapsLock] = "CAPS",
        [Enum.KeyCode.One] = "1",
        [Enum.KeyCode.Two] = "2",
        [Enum.KeyCode.Three] = "3",
        [Enum.KeyCode.Four] = "4",
        [Enum.KeyCode.Five] = "5",
        [Enum.KeyCode.Six] = "6",
        [Enum.KeyCode.Seven] = "7",
        [Enum.KeyCode.Eight] = "8",
        [Enum.KeyCode.Nine] = "9",
        [Enum.KeyCode.Zero] = "0",
        [Enum.KeyCode.Minus] = "-",
        [Enum.KeyCode.Equals] = "=",
        [Enum.KeyCode.Tilde] = "~",
        [Enum.KeyCode.LeftBracket] = "[",
        [Enum.KeyCode.RightBracket] = "]",
        [Enum.KeyCode.Semicolon] = ",",
        [Enum.KeyCode.Quote] = "'",
        [Enum.KeyCode.Slash] = "/",
        [Enum.UserInputType.MouseButton1] = "MB1",
        [Enum.UserInputType.MouseButton2] = "MB2",
        [Enum.UserInputType.MouseButton3] = "MB3",
        [Enum.KeyCode.Escape] = "ESC",
        [Enum.KeyCode.Space] = "SPC",
    }
    
    Library.__index = Library

    -- File system init
    if makefolder and isfolder then
        for _, path in ipairs(Library.Folders) do 
            if not isfolder(Library.Directory .. path) then
                pcall(makefolder, Library.Directory .. path)
            end
        end
    end

    local Flags = Library.Flags 
    local ConfigFlags = Library.ConfigFlags
    local Notifications = Library.Notifications 
--

-- Library functions 
    -- Misc functions
        function Library:GetTransparency(obj)
            if obj:IsA("Frame") then
                return {"BackgroundTransparency"}
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                return { "BackgroundTransparency", "ImageTransparency" }
            elseif obj:IsA("ScrollingFrame") then
                return { "BackgroundTransparency", "ScrollBarImageTransparency" }
            elseif obj:IsA("TextBox") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif obj:IsA("UIStroke") then 
                return { "Transparency" }
            end
            return nil
        end

        function Library:Tween(Object, Properties, Info)
            local tween = TweenService:Create(Object, Info or TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0), Properties)
            tween:Play()
            return tween
        end

        function Library:Fade(obj, prop, vis, speed)
            if not (obj and prop) then return end

            local OldTransparency = obj[prop]
            obj[prop] = vis and 1 or OldTransparency

            local Tween = Library:Tween(obj, { [prop] = vis and OldTransparency or 1 }, TweenInfo.new(speed or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0))

            Library:Connection(Tween.Completed, function()
                if not vis then
                    task.wait()
                    obj[prop] = OldTransparency
                end
            end)

            return Tween
        end

        function Library:Resizify(Parent)
            local Resizing = Library:Create("TextButton", {
                Position = dim2(1, -10, 1, -10);
                BorderColor3 = rgb(0, 0, 0);
                Size = dim2(0, 10, 0, 10);
                BorderSizePixel = 0;
                BackgroundColor3 = rgb(255, 255, 255);
                Parent = Parent;
                BackgroundTransparency = 1; 
                Text = ""
            })
        
            local IsResizing = false 
            local Size 
            local InputLost 
            local ParentSize = Parent.Size  
            
            Resizing.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    IsResizing = true
                    InputLost = input.Position
                    Size = Parent.Size
                end
            end)
        
            Resizing.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    IsResizing = false
                end
            end)
        
            Library:Connection(InputService.InputChanged, function(input) 
                if IsResizing and input.UserInputType == Enum.UserInputType.MouseMovement then            
                    Parent.Size = dim2(
                        Size.X.Scale,
                        math.clamp(Size.X.Offset + (input.Position.X - InputLost.X), ParentSize.X.Offset, Camera.ViewportSize.X), 
                        Size.Y.Scale, 
                        math.clamp(Size.Y.Offset + (input.Position.Y - InputLost.Y), ParentSize.Y.Offset, Camera.ViewportSize.Y)
                    )
                end
            end)
        end
        
        function Library:Hovering(Object)
            if type(Object) == "table" then 
                for _, obj in ipairs(Object) do 
                    if Library:Hovering(obj) then 
                        return true
                    end 
                end 
                return false
            else 
                local mPos = InputService:GetMouseLocation()
                local y_cond = Object.AbsolutePosition.Y <= mPos.Y and mPos.Y <= Object.AbsolutePosition.Y + Object.AbsoluteSize.Y
                local x_cond = Object.AbsolutePosition.X <= mPos.X and mPos.X <= Object.AbsolutePosition.X + Object.AbsoluteSize.X
                return (y_cond and x_cond)
            end 
        end  

        function Library:Draggify(Parent)
            local Dragging = false 
            local InitialPosition 
            local StartPos

            Parent.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    InitialPosition = Input.Position
                    StartPos = Parent.Position
                end
            end)

            Parent.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)

            Library:Connection(InputService.InputChanged, function(Input) 
                if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                    local Horizontal = Camera.ViewportSize.X
                    local Vertical = Camera.ViewportSize.Y

                    local NewPosition = dim2(
                        0,
                        math.clamp(
                            StartPos.X.Offset + (Input.Position.X - InitialPosition.X),
                            0,
                            Horizontal - Parent.Size.X.Offset
                        ),
                        0,
                        math.clamp(
                            StartPos.Y.Offset + (Input.Position.Y - InitialPosition.Y),
                            0,
                            Vertical - Parent.Size.Y.Offset
                        )
                    )
                    Parent.Position = NewPosition
                end
            end)
        end 

        function Library:Convert(str)
            local Values = {}
            for Value in string.gmatch(str, "[^,]+") do
                table.insert(Values, tonumber(Value))
            end
            if #Values == 4 then              
                return unpack(Values)
            end
        end
        
        function Library:ConvertHex(col, alpha)
            local r = math.floor(col.R * 255)
            local g = math.floor(col.G * 255)
            local b = math.floor(col.B * 255)
            local a = alpha and math.floor(alpha * 255) or 255
            return string.format("#%02X%02X%02X%02X", r, g, b, a)
        end

        function Library:ConvertFromHex(col)
            col = col:gsub("#", "")
            local r = tonumber(col:sub(1, 2), 16) / 255
            local g = tonumber(col:sub(3, 4), 16) / 255
            local b = tonumber(col:sub(5, 6), 16) / 255
            local a = tonumber(col:sub(7, 8), 16) and tonumber(col:sub(7, 8), 16) / 255 or 1
            return Color3.new(r, g, b), a
        end

        local ConfigHolder;
        function Library:UpdateConfigList() 
            if not ConfigHolder then return end
            local List = {}
            if listfiles then
                for _, file in ipairs(listfiles(Library.Directory .. "/configs")) do
                    local Name = file:gsub(Library.Directory .. "/configs[/\]", ""):gsub("%.cfg", "")
                    table.insert(List, Name)
                end
            end
            ConfigHolder.RefreshOptions(List)
        end

        function Library:Round(num, float) 
            local Multiplier = 1 / (float or 1)
            return math.floor(num * Multiplier + 0.5) / Multiplier
        end

        function Library:Themify(instance, theme, property)
            if themes.utility[theme] and themes.utility[theme][property] then
                table.insert(themes.utility[theme][property], instance)
            end
        end

        function Library:RefreshTheme(theme, newColor)
            if themes.utility[theme] then
                for property, instances in pairs(themes.utility[theme]) do 
                    for _, object in ipairs(instances) do
                        if object and object.Parent then
                            object[property] = newColor
                        end
                    end 
                end
            end
            themes.preset[theme] = newColor 
        end 

        function Library:Connection(signal, callback)
            local connection = signal:Connect(callback)
            table.insert(Library.Connections, connection)
            return connection 
        end

        function Library:Create(instance, options)
            local ins = Instance.new(instance) 
            for prop, value in pairs(options) do
                ins[prop] = value
            end
            if instance == "TextButton" then 
                ins.AutoButtonColor = false 
            end 
            return ins 
        end

        function Library:Unload() 
            if Library.Items then 
                Library.Items:Destroy()
            end
            if Library.Other then 
                Library.Other:Destroy()
            end
            for _, connection in ipairs(Library.Connections) do 
                if connection and connection.Connected then
                    connection:Disconnect() 
                end
            end
            Library.Connections = {}
            if getgenv then getgenv().Library = nil end
            print("[XEZIOS] Unloaded successfully.")
        end
    --

    -- Library element functions
        function Library:Window(properties)
            properties = properties or {}
            local Cfg = {
                Prefix = properties.Prefix or "XEZIOS";
                Suffix = properties.Suffix or "PRIME";
                Size = properties.Size or dim2(0, 620, 0, 471);
                TabInfo = nil;
                Items = {};
            }
            
            local parentGui = GetSafeParent()

            Library.Items = Library:Create("ScreenGui", {
                Parent = parentGui;
                Name = "Xezios_Main";
                Enabled = true;
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
                IgnoreGuiInset = true;
                ResetOnSpawn = false;
            });
            
            Library.Other = Library:Create("ScreenGui", {
                Parent = parentGui;
                Name = "Xezios_Other";
                Enabled = true;
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
                IgnoreGuiInset = true;
                ResetOnSpawn = false;
            }); 

            local Items = Cfg.Items; do
                Items.Window = Library:Create("Frame", {
                    Parent = Library.Items;
                    Name = "Window";
                    Position = dim2(0.5, -Cfg.Size.X.Offset / 2, 0.5, -Cfg.Size.Y.Offset / 2);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = Cfg.Size;
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.window_outline
                }); Library:Themify(Items.Window, "window_outline", "BackgroundColor3");
                
                Items.Outline = Library:Create("Frame", {
                    Parent = Items.Window;
                    Name = "Outline";
                    Size = dim2(1, 0, 1, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    ZIndex = 2;
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.window_outline
                }); Library:Themify(Items.Outline, "window_outline", "BackgroundColor3")
                
                Items.Inline = Library:Create("Frame", {
                    Parent = Items.Outline;
                    Name = "Inline";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.inline
                });	Library:Themify(Items.Inline, "inline", "BackgroundColor3")
                
                Items.TabHolderFrame = Library:Create("Frame", {
                    Parent = Items.Inline;
                    Name = "TabHolderFrame";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 139, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(12, 14, 14)
                });
                
                Items.Filler = Library:Create("Frame", {
                    Parent = Items.TabHolderFrame;
                    Name = "Filler";
                    Position = dim2(1, -1, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 1, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.inline
                });	Library:Themify(Items.Filler, "inline", "BackgroundColor3")
                
                Items.TabHolder = Library:Create("Frame", {
                    Parent = Items.TabHolderFrame;
                    BackgroundTransparency = 1;
                    Name = "TabHolder";
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });	
                
                Library:Create("UIListLayout", {
                    Parent = Items.TabHolder;
                    Padding = dim(0, 6);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
                
                Library:Create("UIPadding", {
                    Parent = Items.TabHolder;
                    PaddingTop = dim(0, 6)
                });
                
                Items.PageHolder = Library:Create("Frame", {
                    Parent = Items.Inline;
                    Name = "PageHolder";
                    Position = dim2(0, 140, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -141, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.background
                });	Library:Themify(Items.PageHolder, "background", "BackgroundColor3")
                
                Items.TitleHolder = Library:Create("Frame", {
                    Parent = Items.PageHolder;
                    BackgroundTransparency = 1;
                    Name = "TitleHolder";
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 0, 43);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });	
                
                Items.Filler = Library:Create("Frame", {
                    Parent = Items.TitleHolder;
                    Name = "Divider";
                    Position = dim2(0, 0, 1, -1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 0, 1);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.inline
                });	Library:Themify(Items.Filler, "inline", "BackgroundColor3")
                
                Items.SectionTitle = Library:Create("TextLabel", {
                    RichText = true;
                    Parent = Items.TitleHolder;
                    TextColor3 = themes.preset.accent;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = '<font color = "rgb(255,255,255)">' .. Cfg.Prefix .. '</font> ' .. Cfg.Suffix .. '';
                    Name = "Title";
                    AutomaticSize = Enum.AutomaticSize.XY;
                    AnchorPoint = vec2(0, 0.5);
                    BorderSizePixel = 0;
                    BackgroundTransparency = 1;
                    Position = dim2(0, 0, 0.5, 0);
                    Font = Enum.Font.GothamBold;
                    ZIndex = 2;
                    TextSize = 18;
                    BackgroundColor3 = rgb(255, 255, 255)
                }); Library:Themify(Items.SectionTitle, "accent", "TextColor3")
                
                Library:Create("UIPadding", {
                    Parent = Items.SectionTitle;
                    PaddingRight = dim(0, 8);
                    PaddingLeft = dim(0, 13)
                });
                
                Items.Pages = Library:Create("Frame", {
                    Parent = Items.PageHolder;
                    Name = "Pages";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 0, 0, 43);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 1, -43);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });	

                Items.Fade = Library:Create("Frame", {
                    Name = "Fade";
                    BackgroundTransparency = 1;
                    Parent = Items.Pages;
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(17, 19, 19);
                    ZIndex = 2;
                });	Library:Themify(Items.Fade, "background", "BackgroundColor3")                
                
                Items.Glow = Library:Create("ImageLabel", {
                    ImageColor3 = themes.preset.glow;
                    ScaleType = Enum.ScaleType.Slice;
                    ImageTransparency = 0.65;
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = Items.Window;
                    Name = "Glow";
                    Size = dim2(1, 40, 1, 40);
                    Image = "rbxassetid://18245826428";
                    BackgroundTransparency = 1;
                    Position = dim2(0, -20, 0, -20);
                    BackgroundColor3 = rgb(255, 255, 255);
                    BorderSizePixel = 0;
                    SliceCenter = rect(vec2(21, 21), vec2(79, 79))
                });	Library:Themify(Items.Glow, "glow", "ImageColor3")                
            end

            do -- Interactive Dragging & Resizing
                Library:Draggify(Items.Window)
                Library:Resizify(Items.Window)
            end

            function Cfg.ToggleMenu(bool) 
                Items.Window.Visible = bool
            end 

            return setmetatable(Cfg, Library)
        end 

        function Library:Tab(properties)
            local Cfg = {
                Name = properties.name or properties.Name or "visuals"; 
                Icon = properties.Icon or properties.icon or "rbxassetid://112730572155522";
                Items = {};
            }

            local Items = Cfg.Items; do 
                -- Tab buttons 
                Items.Button = Library:Create("TextButton", {
                    Active = false;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    AutoButtonColor = false;
                    Parent = self.Items.TabHolder;
                    BackgroundTransparency = 1;
                    Name = "TabButton";
                    Size = dim2(1, 0, 0, 30);
                    Selectable = false;
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                Items.Holder = Library:Create("Frame", {
                    Parent = Items.Button;
                    Name = "Holder";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 6, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -13, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.visible_backgrounds
                });	Library:Themify(Items.Holder, "visible_backgrounds", "BackgroundColor3")
                
                Items.Icon = Library:Create("ImageLabel", {
                    ImageColor3 = themes.preset.deselected;
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = Items.Holder;
                    Name = "Icon";
                    AnchorPoint = vec2(0, 0.5);
                    Image = Cfg.Icon;
                    BackgroundTransparency = 1;
                    Position = dim2(0, 8, 0.5, 0);
                    Size = dim2(0, 14, 0, 14);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });	Library:Themify(Items.Icon, "deselected", "ImageColor3")
                
                Items.SectionTitle = Library:Create("TextLabel", {
                    Font = Enum.Font.GothamMedium;
                    TextColor3 = themes.preset.deselected;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = Cfg.Name;
                    Parent = Items.Holder;
                    Name = "Title";
                    AnchorPoint = vec2(0, 0.5);
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundTransparency = 1;
                    Position = dim2(0, 22, 0.5, 0);
                    BorderSizePixel = 0;
                    ZIndex = 2;
                    TextSize = 13;
                    BackgroundColor3 = rgb(12, 14, 14)
                });	Library:Themify(Items.SectionTitle, "deselected", "TextColor3") 
                
                Library:Create("UIPadding", {
                    Parent = Items.SectionTitle;
                    PaddingRight = dim(0, 8);
                    PaddingLeft = dim(0, 8)
                });
                
                Items.Indicator = Library:Create("ImageLabel", {
                    ImageColor3 = themes.preset.accent;
                    ImageTransparency = 1;
                    BackgroundTransparency = 1;
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = Items.Button;
                    AnchorPoint = vec2(0, 0.5);
                    Image = "rbxassetid://126397903791071";
                    Name = "Indicator";
                    Position = dim2(0, 0, 0.5, 0);
                    Size = dim2(0, 2, 0, 19);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });	Library:Themify(Items.Indicator, "accent", "ImageColor3")                

                -- Split Two-Column Page (Left & Right)
                Items.Pages = Library:Create("Frame", {
                    Parent = self.Items.Pages;
                    Visible = false;
                    BackgroundTransparency = 1;
                    Name = "Page_" .. Cfg.Name;
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                Library:Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    Parent = Items.Pages;
                    Padding = dim(0, 6);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    VerticalFlex = Enum.UIFlexAlignment.Fill
                });
                
                Library:Create("UIPadding", {
                    PaddingTop = dim(0, 6);
                    PaddingBottom = dim(0, 6);
                    Parent = Items.Pages;
                    PaddingRight = dim(0, 6);
                    PaddingLeft = dim(0, 6)
                });
                
                -- Left Column
                Items.Left = Library:Create("ScrollingFrame", {
                    ScrollBarImageColor3 = rgb(0, 0, 0);
                    Active = true;
                    AutomaticCanvasSize = Enum.AutomaticSize.Y;
                    ScrollBarThickness = 2;
                    Parent = Items.Pages;
                    Name = "LeftColumn";
                    BackgroundTransparency = 1;
                    Size = dim2(0.5, -3, 1, 0);
                    BackgroundColor3 = rgb(255, 255, 255);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    CanvasSize = dim2(0, 0, 0, 0)
                });
                
                Library:Create("UIListLayout", {
                    Parent = Items.Left;
                    Padding = dim(0, 6);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill
                });
                
                -- Right Column
                Items.Right = Library:Create("ScrollingFrame", {
                    ScrollBarImageColor3 = rgb(0, 0, 0);
                    Active = true;
                    AutomaticCanvasSize = Enum.AutomaticSize.Y;
                    ScrollBarThickness = 2;
                    Parent = Items.Pages;
                    Name = "RightColumn";
                    BackgroundTransparency = 1;
                    Size = dim2(0.5, -3, 1, 0);
                    BackgroundColor3 = rgb(255, 255, 255);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    CanvasSize = dim2(0, 0, 0, 0)
                });
                
                Library:Create("UIListLayout", {
                    Parent = Items.Right;
                    Padding = dim(0, 6);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill
                });                
            end 

            function Cfg.OpenTab() 
                local Tab = self.TabInfo
                if Tab then
                    Library:Tween(Tab.Indicator, {ImageTransparency = 1})
                    Library:Tween(Tab.Holder, {BackgroundTransparency = 1})
                    Library:Tween(Tab.Icon, {ImageColor3 = themes.preset.deselected})
                    Library:Tween(Tab.SectionTitle, {TextColor3 = themes.preset.deselected})
                    Tab.Pages.Visible = false
                end

                self.Items.Fade.BackgroundTransparency = 0 
                Library:Tween(self.Items.Fade, {BackgroundTransparency = 1})

                Library:Tween(Items.Indicator, {ImageTransparency = 0})
                Library:Tween(Items.Holder, {BackgroundTransparency = 0})
                Library:Tween(Items.Icon, {ImageColor3 = themes.preset.accent})
                Library:Tween(Items.SectionTitle, {TextColor3 = themes.preset.text_color})

                Items.Pages.Visible = true
                self.TabInfo = Cfg.Items
            end

            Items.Button.MouseButton1Down:Connect(function()
                Cfg.OpenTab()
            end)

            if not self.TabInfo then
                Cfg.OpenTab()
            end

            return setmetatable(Cfg, Library)
        end

        function Library:Section(properties)
            local Cfg = {
                Name = properties.name or properties.Name or "Section"; 
                Side = properties.side or properties.Side or "Left"; -- "Left" or "Right"
                Items = {};
            };
            
            local Items = Cfg.Items; do
                Items.Section = Library:Create("Frame", {
                    Parent = self.Items[Cfg.Side];
                    Name = "Section_" .. Cfg.Name;
                    Size = dim2(1, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = themes.preset.inline
                });	Library:Themify(Items.Section, "inline", "BackgroundColor3")
                
                Items.Inline = Library:Create("Frame", {
                    Parent = Items.Section;
                    Size = dim2(1, -2, 1, -2);
                    Name = "SectionInline";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = themes.preset.visible_backgrounds
                });	Library:Themify(Items.Inline, "visible_backgrounds", "BackgroundColor3")
                
                Items.SectionTitle = Library:Create("TextLabel", {
                    Font = Enum.Font.GothamBold;
                    TextColor3 = rgb(180, 180, 180);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = Cfg.Name;
                    Parent = Items.Inline;
                    Name = "SectionTitle";
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundTransparency = 1;
                    Position = dim2(0, 0, 0, 6);
                    BorderSizePixel = 0;
                    ZIndex = 2;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                Library:Create("UIPadding", {
                    Parent = Items.SectionTitle;
                    PaddingRight = dim(0, 8);
                    PaddingLeft = dim(0, 6)
                });
                
                -- Underline separator
                Items.Fill = Library:Create("Frame", {
                    Parent = Items.Inline;
                    Name = "Divider";
                    Position = dim2(0, 1, 0, 26);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 0, 1);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.inline
                });	Library:Themify(Items.Fill, "inline", "BackgroundColor3")
                
                Items.Elements = Library:Create("Frame", {
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = Items.Inline;
                    Name = "Elements";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 7, 0, 34);
                    Size = dim2(1, -14, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                Library:Create("UIListLayout", {
                    Parent = Items.Elements;
                    Padding = dim(0, 7);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
                
                Library:Create("UIPadding", {
                    PaddingBottom = dim(0, 12);
                    Parent = Items.Elements
                });
                
                Library:Create("UIPadding", {
                    PaddingBottom = dim(0, 2);
                    Parent = Items.Section
                });                
            end;

            return setmetatable(Cfg, Library)
        end  

        -- TOGGLE COMPONENT
        function Library:Toggle(properties) 
            local Cfg = {
                Name = properties.Name or "Toggle";
                Flag = properties.Flag or properties.Name or "Toggle";
                Enabled = properties.Default or false;
                Callback = properties.Callback or properties.callback or function() end;
                Items = {};
            }

            local Items = Cfg.Items; do 
                Items.Toggle = Library:Create("TextButton", {
                    Active = false;
                    Text = "";
                    Parent = self.Items.Elements;
                    AutoButtonColor = false;
                    Name = "Toggle";
                    Size = dim2(1, 0, 0, 18);
                    BackgroundTransparency = 1;
                    Selectable = false;
                    BorderSizePixel = 0;
                    BorderColor3 = rgb(0, 0, 0);
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                Items.Title = Library:Create("TextLabel", {
                    Font = Enum.Font.GothamMedium;
                    TextColor3 = themes.preset.text_color;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = Cfg.Name;
                    Parent = Items.Toggle;
                    Name = "Title";
                    RichText = true;
                    BackgroundTransparency = 1;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BorderSizePixel = 0;
                    ZIndex = 2;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255)
                });	Library:Themify(Items.Title, "text_color", "TextColor3")
                
                Items.Components = Library:Create("Frame", {
                    Parent = Items.Toggle;
                    Name = "Components";
                    Position = dim2(1, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 0, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                Library:Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalAlignment = Enum.HorizontalAlignment.Right;
                    Parent = Items.Components;
                    Padding = dim(0, 7);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
                
                Items.ToggleComponent = Library:Create("Frame", {
                    Name = "Switch";
                    Parent = Items.Components;
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 29, 0, 14);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(26, 28, 28)
                });
                
                Library:Create("UICorner", {
                    CornerRadius = dim(0, 7);
                    Parent = Items.ToggleComponent
                });
                
                Items.Inline = Library:Create("Frame", {
                    Parent = Items.ToggleComponent;
                    Name = "SwitchInline";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(24, 24, 27)
                });
                
                Library:Create("UICorner", {
                    CornerRadius = dim(0, 6);
                    Parent = Items.Inline
                });
                
                Items.Circle = Library:Create("Frame", {
                    AnchorPoint = vec2(0, 0.5);
                    Parent = Items.Inline;
                    Name = "Thumb";
                    Position = dim2(0, 2, 0.5, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 8, 0, 8);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(68, 68, 69)
                });
                
                Library:Create("UICorner", {
                    Parent = Items.Circle;
                    CornerRadius = dim(0, 999)
                });                
            end;
            
            function Cfg.Set(bool)
                Flags[Cfg.Flag] = bool
                Cfg.Callback(bool)

                Library:Tween(Items.ToggleComponent, {BackgroundColor3 = bool and themes.preset.accent or themes.preset.inline})
                Library:Tween(Items.Inline, {BackgroundColor3 = bool and themes.preset.accent or themes.preset.background})
                Library:Tween(Items.Circle, {
                    BackgroundColor3 = bool and rgb(255, 255, 255) or themes.preset.deselected, 
                    Position = bool and dim2(1, -10, 0.5, 0) or dim2(0, 2, 0.5, 0)
                })                
            end
            
            Items.Toggle.MouseButton1Click:Connect(function()
                Cfg.Enabled = not Cfg.Enabled
                Cfg.Set(Cfg.Enabled)
            end)

            Cfg.Set(Cfg.Enabled)
            ConfigFlags[Cfg.Flag] = Cfg.Set

            return setmetatable(Cfg, Library)
        end 
        
        -- SLIDER COMPONENT
        function Library:Slider(properties) 
            local Cfg = {
                Name = properties.Name,
                Suffix = properties.Suffix or "",
                Flag = properties.Flag or properties.Name or "Slider",
                Callback = properties.Callback or function() end, 
                Min = properties.Min or 0,
                Max = properties.Max or 100,
                Intervals = properties.Decimal or 1,
                Value = properties.Default or 10, 
                Dragging = false,
                Items = {}
            } 

            local Items = Cfg.Items; do
                Items.Slider = Library:Create("Frame", {
                    Parent = self.Items.Elements;
                    Name = "Slider";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                Items.Title = Library:Create("TextLabel", {
                    Font = Enum.Font.GothamMedium;
                    TextColor3 = themes.preset.text_color;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = Cfg.Name;
                    Parent = Items.Slider;
                    Name = "Title";
                    RichText = true;
                    BackgroundTransparency = 1;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BorderSizePixel = 0;
                    ZIndex = 2;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255)
                });	Library:Themify(Items.Title, "text_color", "TextColor3")
                
                Items.Components = Library:Create("Frame", {
                    Parent = Items.Slider;
                    Name = "Components";
                    Position = dim2(1, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 0, 0, 14);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                Library:Create("UIListLayout", {
                    Parent = Items.Components;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    HorizontalAlignment = Enum.HorizontalAlignment.Right
                });
                
                Items.Value = Library:Create("TextLabel", {
                    Font = Enum.Font.GothamBold;
                    TextColor3 = themes.preset.deselected;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "0";
                    Parent = Items.Components;
                    Name = "Value";
                    BackgroundTransparency = 1;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BorderSizePixel = 0;
                    ZIndex = 2;
                    TextSize = 12;
                    BackgroundColor3 = rgb(255, 255, 255)
                });	Library:Themify(Items.Value, "deselected", "TextColor3")
                
                Items.Outline = Library:Create("TextButton", {
                    Active = false;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    AutoButtonColor = false;
                    Parent = Items.Slider;
                    Name = "BarOutline";
                    Position = dim2(0, 0, 0, 20);
                    Size = dim2(1, 0, 0, 6);
                    Selectable = false;
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(12, 14, 14)
                });
                
                Items.Fill = Library:Create("Frame", {
                    Name = "Fill";
                    Parent = Items.Outline;
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0.5, 0, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                });	Library:Themify(Items.Fill, "accent", "BackgroundColor3")
                
                Items.Circle = Library:Create("Frame", {
                    AnchorPoint = vec2(0.5, 0.5);
                    Parent = Items.Fill;
                    Name = "Thumb";
                    Position = dim2(1, 0, 0.5, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 10, 0, 10);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                });	Library:Themify(Items.Circle, "accent", "BackgroundColor3")
                
                Library:Create("UICorner", {
                    Parent = Items.Circle;
                    CornerRadius = dim(0, 999)
                });
            end 

            function Cfg.Set(value)
                Cfg.Value = math.clamp(Library:Round(value, Cfg.Intervals), Cfg.Min, Cfg.Max)
                local pct = (Cfg.Value - Cfg.Min) / (Cfg.Max - Cfg.Min)
                Items.Fill.Size = dim2(pct, 0, 1, 0)
                Items.Value.Text = tostring(Cfg.Value) .. Cfg.Suffix
                Flags[Cfg.Flag] = Cfg.Value
                Cfg.Callback(Flags[Cfg.Flag])
            end
            
            Items.Outline.MouseButton1Down:Connect(function()
                Cfg.Dragging = true 
            end)

            Library:Connection(InputService.InputChanged, function(input)
                if Cfg.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then 
                    local Size = (input.Position.X - Items.Outline.AbsolutePosition.X) / Items.Outline.AbsoluteSize.X
                    local Value = ((Cfg.Max - Cfg.Min) * Size) + Cfg.Min
                    Cfg.Set(Value)
                end
            end)

            Library:Connection(InputService.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Cfg.Dragging = false
                end 
            end)

            Cfg.Set(Cfg.Value)
            ConfigFlags[Cfg.Flag] = Cfg.Set

            return setmetatable(Cfg, Library)
        end 

        -- DROPDOWN COMPONENT
        function Library:Dropdown(properties) 
            local Cfg = {
                Name = properties.Name or nil;
                Flag = properties.Flag or properties.Name or "Dropdown";
                Options = properties.Options or {};
                Callback = properties.Callback or function() end;
                Multi = properties.Multi or false;
                Open = false;
                OptionInstances = {};
                MultiItems = {};
                Items = {};
            }   

            Cfg.Default = properties.Default or (Cfg.Multi and {}) or Cfg.Options[1] or "None"
            Flags[Cfg.Flag] = Cfg.Default
            
            local Items = Cfg.Items; do 
                Items.Dropdown = Library:Create("Frame", {
                    Parent = self.Items.Elements;
                    Name = "Dropdown";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                Items.Title = Library:Create("TextLabel", {
                    Font = Enum.Font.GothamMedium;
                    TextColor3 = themes.preset.text_color;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = Cfg.Name or "";
                    Parent = Items.Dropdown;
                    Name = "Title";
                    BackgroundTransparency = 1;
                    RichText = true;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BorderSizePixel = 0;
                    ZIndex = 2;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255)
                });	Library:Themify(Items.Title, "text_color", "TextColor3")
                
                Items.Outline = Library:Create("TextButton", {
                    Active = false;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    AutoButtonColor = false;
                    Parent = Items.Dropdown;
                    Name = "DropdownOutline";
                    Position = dim2(0, 0, 0, 20);
                    Size = dim2(1, 0, 0, 22);
                    Selectable = false;
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.inline
                });	Library:Themify(Items.Outline, "inline", "BackgroundColor3")
                
                Items.Inline = Library:Create("Frame", {
                    Parent = Items.Outline;
                    Name = "DropdownInline";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(28, 30, 30)
                });
                
                Items.Arrow = Library:Create("ImageLabel", {
                    ImageColor3 = rgb(219, 222, 221);
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = Items.Inline;
                    Name = "Arrow";
                    AnchorPoint = vec2(0, 0.5);
                    Image = "rbxassetid://70449495580650";
                    BackgroundTransparency = 1;
                    Position = dim2(1, -15, 0.5, 0);
                    Size = dim2(0, 10, 0, 8);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                Items.InnerText = Library:Create("TextLabel", {
                    Font = Enum.Font.Gotham;
                    TextColor3 = themes.preset.text_color;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    Parent = Items.Inline;
                    Name = "Label";
                    AnchorPoint = vec2(0, 0.5);
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BackgroundTransparency = 1;
                    Position = dim2(0, 6, 0.5, 0);
                    BorderSizePixel = 0;
                    ZIndex = 2;
                    TextSize = 12;
                    BackgroundColor3 = rgb(255, 255, 255)
                });	Library:Themify(Items.InnerText, "text_color", "TextColor3")                
                
                -- Floating Options Holder
                Items.DropdownElements = Library:Create("Frame", {
                    Parent = Library.Other;
                    Size = dim2(0, 211, 0, 20);
                    Name = "DropdownMenu";
                    Position = dim2(0, 0, 0, 21);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    Visible = false;
                    BackgroundColor3 = themes.preset.inline
                });	Library:Themify(Items.DropdownElements, "inline", "BackgroundColor3")
                
                Items.DropdownHolder = Library:Create("Frame", {
                    Parent = Items.DropdownElements;
                    Size = dim2(1, -2, 1, -2);
                    Name = "Holder";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(24, 26, 26)
                });
                
                Library:Create("UIListLayout", {
                    Parent = Items.DropdownHolder;
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
            end 

            function Cfg.RenderOption(text)
                local Button = Library:Create("TextButton", {
                    Parent = Items.DropdownHolder;
                    AutoButtonColor = false;
                    Font = Enum.Font.Gotham;
                    Name = "Option";
                    TextColor3 = themes.preset.deselected;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "  " .. text;
                    Size = dim2(1, 0, 0, 22);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    ZIndex = 10;
                    TextSize = 12;
                    BackgroundColor3 = themes.preset.accent
                });	
                table.insert(Cfg.OptionInstances, Button)
                return Button
            end
            
            function Cfg.SetVisible(bool)
                Items.DropdownElements.Position = dim2(0, Items.Outline.AbsolutePosition.X, 0, Items.Outline.AbsolutePosition.Y + 24)
				Items.DropdownElements.Size = dim_offset(Items.Outline.AbsoluteSize.X, 0)
                Items.DropdownElements.Visible = bool 
                Library:Tween(Items.Arrow, {Rotation = bool and 180 or 0})
            end
            
            function Cfg.Set(value)
                local Selected = {}
                local IsTable = type(value) == "table"

                for _, option in ipairs(Cfg.OptionInstances) do 
                    local cleanText = option.Text:gsub("^%s+", "")
                    if cleanText == value or (IsTable and table.find(value, cleanText)) then 
                        table.insert(Selected, cleanText)
                        Cfg.MultiItems = Selected
                        option.TextColor3 = themes.preset.text_color
                        option.BackgroundTransparency = 0.8
                    else
                        option.TextColor3 = themes.preset.deselected
                        option.BackgroundTransparency = 1
                    end
                end

                Items.InnerText.Text = if IsTable then table.concat(Selected, ", ") else Selected[1] or tostring(value)
                Flags[Cfg.Flag] = if IsTable then Selected else Selected[1] or value
                Cfg.Callback(Flags[Cfg.Flag]) 
            end
            
            function Cfg.RefreshOptions(options) 
                for _, option in ipairs(Cfg.OptionInstances) do 
                    option:Destroy() 
                end
                Cfg.OptionInstances = {} 

                for _, option in ipairs(options) do
                    local Button = Cfg.RenderOption(option)
                    Button.MouseButton1Down:Connect(function()
                        local cleanText = option
                        if Cfg.Multi then 
                            local idx = table.find(Cfg.MultiItems, cleanText)
                            if idx then 
                                table.remove(Cfg.MultiItems, idx)
                            else
                                table.insert(Cfg.MultiItems, cleanText)
                            end
                            Cfg.Set(Cfg.MultiItems) 				
                        else 
                            Cfg.SetVisible(false)
                            Cfg.Open = false
                            Cfg.Set(cleanText)
                        end
                    end)
                end
            end

            Items.Outline.MouseButton1Click:Connect(function()
                Cfg.Open = not Cfg.Open 
                Cfg.SetVisible(Cfg.Open)
            end)

            Cfg.RefreshOptions(Cfg.Options)
            Cfg.Set(Cfg.Default)
            ConfigFlags[Cfg.Flag] = Cfg.Set

            return setmetatable(Cfg, Library)
        end

        -- LABEL COMPONENT (Can chain Colorpicker / Keybind!)
        function Library:Label(properties)
            local Cfg = {
                Name = properties.Name or "Label",
                Items = {};
            }

            local Items = Cfg.Items; do 
                Items.Label = Library:Create("Frame", {
                    Parent = self.Items.Elements;
                    Name = "Label";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 18);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                Items.Title = Library:Create("TextLabel", {
                    Font = Enum.Font.GothamMedium;
                    TextColor3 = themes.preset.text_color;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = Cfg.Name;
                    Parent = Items.Label;
                    Name = "Title";
                    BackgroundTransparency = 1;
                    RichText = true;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BorderSizePixel = 0;
                    ZIndex = 2;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255)
                });	Library:Themify(Items.Title, "text_color", "TextColor3")
                
                Items.Components = Library:Create("Frame", {
                    Parent = Items.Label;
                    Name = "Components";
                    Position = dim2(1, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 0, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                Library:Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalAlignment = Enum.HorizontalAlignment.Right;
                    Parent = Items.Components;
                    Padding = dim(0, 7);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });                        
            end 

            function Cfg.Set(Text)
                Items.Title.Text = Text
            end 

            return setmetatable(Cfg, Library)
        end
        
        -- COLORPICKER / KEYPICKER COMPONENT
        function Library:Colorpicker(properties) 
            local Cfg = {
                Name = properties.Name or "Color", 
                Flag = properties.Flag or properties.Name or "Colorpicker",
                Callback = properties.Callback or function() end,
                Color = properties.Color or color(1, 1, 1),
                Alpha = properties.Alpha or 0,
                Open = false, 
                Items = {};
            }

            local DraggingSat = false 
            local DraggingHue = false 
            local DraggingAlpha = false 

            local h, s, v = Cfg.Color:ToHSV() 
            local a = Cfg.Alpha 

            Flags[Cfg.Flag] = {Color = Cfg.Color, Transparency = Cfg.Alpha}

            local targetParent = self.Items.Components or self.Items.Elements
            local Items = Cfg.Items; do 
                Items.Button = Library:Create("TextButton", {
                    Active = false;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    AutoButtonColor = false;
                    Name = "ColorpickerSwatch";
                    Parent = targetParent;
                    Size = dim2(0, 28, 0, 14);
                    Selectable = false;
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(26, 28, 28)
                });
                
                Items.ButtonColor = Library:Create("Frame", {
                    Parent = Items.Button;
                    Name = "Color";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = Cfg.Color
                });
                
                Library:Create("UICorner", {Parent = Items.ButtonColor, CornerRadius = dim(0, 4)});
                Library:Create("UICorner", {Parent = Items.Button, CornerRadius = dim(0, 4)});

                -- Color Palette Window
                Items.Window = Library:Create("Frame", {
                    Parent = Library.Other;
                    Name = "ColorpickerWindow";
                    Position = dim2(0, 100, 0, 10);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 220, 0, 190);
                    BorderSizePixel = 0;
                    Visible = false;
                    BackgroundColor3 = themes.preset.inline
                });	Library:Themify(Items.Window, "inline", "BackgroundColor3")
                Library:Create("UICorner", {Parent = Items.Window, CornerRadius = dim(0, 6)});

                Items.Inline = Library:Create("Frame", {
                    Parent = Items.Window;
                    Position = dim2(0, 1, 0, 1);
                    Size = dim2(1, -2, 1, -2);
                    BackgroundColor3 = themes.preset.visible_backgrounds
                });	Library:Themify(Items.Inline, "visible_backgrounds", "BackgroundColor3")
                Library:Create("UICorner", {Parent = Items.Inline, CornerRadius = dim(0, 5)});

                -- Sat/Val Palette Area
                Items.Val = Library:Create("TextButton", {
                    Parent = Items.Inline;
                    Position = dim2(0, 8, 0, 8);
                    Size = dim2(1, -48, 1, -44);
                    BackgroundColor3 = rgb(255, 0, 0);
                    BorderSizePixel = 0;
                    Text = "";
                });
                
                Items.Saturation = Library:Create("Frame", {
                    Parent = Items.Val;
                    Size = dim2(1, 0, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255);
                });
                Library:Create("UIGradient", {
                    Rotation = 270;
                    Transparency = numseq{numkey(0, 0), numkey(1, 1)};
                    Parent = Items.Saturation;
                    Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(0, 0, 0))}
                });

                -- Rainbow Hue Bar
                Items.RGB = Library:Create("TextButton", {
                    Parent = Items.Inline;
                    Position = dim2(1, -34, 0, 8);
                    Size = dim2(0, 12, 1, -44);
                    BackgroundColor3 = rgb(255, 255, 255);
                    BorderSizePixel = 0;
                    Text = "";
                });
                Library:Create("UIGradient", {
                    Rotation = 90;
                    Parent = Items.RGB;
                    Color = rgbseq{
                        rgbkey(0, rgb(255, 0, 0)),
                        rgbkey(0.17, rgb(255, 255, 0)),
                        rgbkey(0.33, rgb(0, 255, 0)),
                        rgbkey(0.5, rgb(0, 255, 255)),
                        rgbkey(0.67, rgb(0, 0, 255)),
                        rgbkey(0.83, rgb(255, 0, 255)),
                        rgbkey(1, rgb(255, 0, 0))
                    }
                });

                -- Alpha Bar
                Items.Alpha = Library:Create("TextButton", {
                    Parent = Items.Inline;
                    Position = dim2(1, -18, 0, 8);
                    Size = dim2(0, 10, 1, -44);
                    BackgroundColor3 = rgb(255, 255, 255);
                    BorderSizePixel = 0;
                    Text = "";
                });
                Library:Create("UIGradient", {
                    Rotation = 90;
                    Parent = Items.Alpha;
                    Color = rgbseq{rgbkey(0, rgb(255, 255, 255)), rgbkey(1, rgb(10, 10, 10))}
                });

                -- Hex text display
                Items.HexDisplay = Library:Create("TextLabel", {
                    Parent = Items.Inline;
                    Position = dim2(0, 8, 1, -26);
                    Size = dim2(1, -16, 0, 18);
                    Font = Enum.Font.Code;
                    TextSize = 11;
                    TextColor3 = rgb(220, 220, 220);
                    TextXAlignment = Enum.TextXAlignment.Center;
                    BackgroundTransparency = 1;
                    Text = "#FFFFFF";
                });
            end;
            
            function Cfg.Set(newCol, newAlpha)
                if newCol then h, s, v = newCol:ToHSV() end
                if newAlpha then a = newAlpha end
                local finalColor = hsv(h, s, v)
                Items.ButtonColor.BackgroundColor3 = finalColor
                Items.Val.BackgroundColor3 = hsv(h, 1, 1)
                Items.HexDisplay.Text = Library:ConvertHex(finalColor, 1 - a)
                Flags[Cfg.Flag] = {Color = finalColor, Transparency = a}
                Cfg.Callback(finalColor, a)
            end

            Items.Button.MouseButton1Click:Connect(function()
                Cfg.Open = not Cfg.Open
                Items.Window.Visible = Cfg.Open
                Items.Window.Position = dim2(0, Items.Button.AbsolutePosition.X - 180, 0, Items.Button.AbsolutePosition.Y + 22)
            end)

            Cfg.Set(Cfg.Color, Cfg.Alpha)
            ConfigFlags[Cfg.Flag] = Cfg.Set

            return setmetatable(Cfg, Library)
        end 

        -- TEXTBOX COMPONENT
        function Library:Textbox(properties) 
            local Cfg = {
                Name = properties.Name or "TextBox",
                PlaceHolder = properties.PlaceHolder or "Type here...",
                Default = properties.Default or "",
                Flag = properties.Flag or properties.Name or "TextBox",
                Callback = properties.Callback or function() end,
                Items = {};
            }

            local Items = Cfg.Items; do 
                Items.Textbox = Library:Create("Frame", {
                    Parent = self.Items.Elements;
                    Name = "TextBox";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                Items.Title = Library:Create("TextLabel", {
                    Font = Enum.Font.GothamMedium;
                    TextColor3 = themes.preset.text_color;
                    BorderColor3 = rgb(0, 0, 0);
                    RichText = true;
                    Text = Cfg.Name;
                    Parent = Items.Textbox;
                    Name = "Title";
                    BackgroundTransparency = 1;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    BorderSizePixel = 0;
                    ZIndex = 2;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255)
                });	Library:Themify(Items.Title, "text_color", "TextColor3")
                
                Items.Outline = Library:Create("Frame", {
                    Parent = Items.Textbox;
                    Name = "BoxOutline";
                    Position = dim2(0, 0, 0, 20);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 0, 22);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(26, 28, 28)
                });
                
                Items.Inline = Library:Create("Frame", {
                    Parent = Items.Outline;
                    Name = "BoxInline";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(31, 31, 31)
                });
                
                Items.Input = Library:Create("TextBox", {
                    Parent = Items.Inline;
                    Font = Enum.Font.Gotham;
                    Name = "Input";
                    BorderColor3 = rgb(0, 0, 0);
                    Text = Cfg.Default;
                    PlaceholderText = Cfg.PlaceHolder;
                    PlaceholderColor3 = themes.preset.deselected;
                    Size = dim2(1, -12, 1, 0);
                    Position = dim2(0, 6, 0, 0);
                    BorderSizePixel = 0;
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextColor3 = rgb(239, 239, 239);
                    TextSize = 12;
                    ClearTextOnFocus = false;
                });                    
            end 
            
            function Cfg.Set(text) 
                Flags[Cfg.Flag] = text
                Items.Input.Text = text
                Cfg.Callback(text)
            end 
            
            Items.Input.FocusLost:Connect(function()
                Cfg.Set(Items.Input.Text) 
            end)

            ConfigFlags[Cfg.Flag] = Cfg.Set
            return setmetatable(Cfg, Library)
        end

        -- KEYBIND COMPONENT
        function Library:Keybind(properties) 
            local Cfg = {
                Flag = properties.Flag or properties.Name;
                Callback = properties.Callback or function() end;
                Name = properties.Name or nil; 
                Key = properties.Key or Enum.KeyCode.E;
                Mode = properties.Mode or "Toggle"; -- "Toggle" | "Hold" | "Always"
                Active = properties.Default or false; 
                Open = false;
                Items = {}
            }

            local targetParent = self.Items.Components or self.Items.Elements
            local Items = Cfg.Items; do 
                Items.KeybindOutline = Library:Create("TextButton", {
                    Active = false;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    AutoButtonColor = false;
                    Parent = targetParent;
                    Name = "KeybindBadge";
                    Size = dim2(0, 36, 0, 16);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(26, 28, 28)
                });
                
                Items.ButtonColor = Library:Create("Frame", {
                    Parent = Items.KeybindOutline;
                    Size = dim2(1, -2, 1, -2);
                    Position = dim2(0, 1, 0, 1);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(31, 31, 31)
                });
                Library:Create("UICorner", {Parent = Items.ButtonColor, CornerRadius = dim(0, 4)});
                Library:Create("UICorner", {Parent = Items.KeybindOutline, CornerRadius = dim(0, 4)});
                
                Items.Key = Library:Create("TextLabel", {
                    Font = Enum.Font.GothamBold;
                    TextColor3 = themes.preset.text_color;
                    Text = Keys[Cfg.Key] or tostring(Cfg.Key.Name);
                    Parent = Items.ButtonColor;
                    Size = dim2(1, 0, 1, 0);
                    TextXAlignment = Enum.TextXAlignment.Center;
                    BackgroundTransparency = 1;
                    TextSize = 10;
                });
            end 

            function Cfg.Set(newKey)
                Cfg.Key = newKey
                Items.Key.Text = Keys[newKey] or tostring(newKey.Name)
            end

            Items.KeybindOutline.MouseButton1Down:Connect(function()
                Items.Key.Text = "..."
                local conn; conn = InputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        Cfg.Set(input.KeyCode)
                        conn:Disconnect()
                    end
                end)
            end)

            InputService.InputBegan:Connect(function(input, gpe)
                if not gpe and input.KeyCode == Cfg.Key then
                    if Cfg.Mode == "Toggle" then
                        Cfg.Active = not Cfg.Active
                    elseif Cfg.Mode == "Hold" then
                        Cfg.Active = true
                    end
                    Cfg.Callback(Cfg.Active)
                end
            end)

            InputService.InputEnded:Connect(function(input)
                if Cfg.Mode == "Hold" and input.KeyCode == Cfg.Key then
                    Cfg.Active = false
                    Cfg.Callback(false)
                end
            end)

            return setmetatable(Cfg, Library)
        end
        
        -- BUTTON COMPONENT
        function Library:Button(properties) 
            local Cfg = {
                Name = properties.Name or "Button",
                Callback = properties.Callback or function() end,
                Items = {};
            }
            
            local Items = Cfg.Items; do 
                Items.Button = Library:Create("Frame", {
                    Parent = self.Items.Elements;
                    Name = "Button";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 22);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                });
                
                Items.Outline = Library:Create("TextButton", {
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    AutoButtonColor = false;
                    Parent = Items.Button;
                    Size = dim2(1, 0, 0, 22);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(26, 28, 28)
                });
                
                Items.Inline = Library:Create("Frame", {
                    Parent = Items.Outline;
                    Position = dim2(0, 1, 0, 1);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(31, 31, 31)
                });
                
                Items.Title = Library:Create("TextLabel", {
                    Font = Enum.Font.GothamMedium;
                    TextColor3 = themes.preset.text_color;
                    Text = Cfg.Name;
                    Parent = Items.Inline;
                    Size = dim2(1, 0, 1, 0);
                    BackgroundTransparency = 1;
                    TextSize = 13;
                });	Library:Themify(Items.Title, "text_color", "TextColor3")                                          
            end 

            Items.Outline.MouseButton1Click:Connect(function()
                Items.Title.TextColor3 = rgb(255, 255, 255)
                Library:Tween(Items.Title, {TextColor3 = themes.preset.text_color})
                task.spawn(Cfg.Callback)
            end)
            
            return setmetatable(Cfg, Library)
        end

        -- CONFIGS & THEMES TAB
        function Library:Configs(window) 
            local Tab = window:Tab({Name = "Settings", Icon = "rbxassetid://10723415903"})
            local SectionLeft = Tab:Section({Name = "Config Manager", Side = "Left"})
            ConfigHolder = SectionLeft:Dropdown({
                Name = "Saved Configs", 
                Options = {"Default", "Legit", "Rage"}, 
                Flag = "config_name_list"
            })
            SectionLeft:Textbox({Name = "Config Name:", Flag = "config_name_text", Default = ""})
            SectionLeft:Button({Name = "Save Config", Callback = function() 
                local name = Flags["config_name_text"]
                if name and name ~= "" then
                    if writefile then
                        pcall(writefile, Library.Directory .. "/configs/" .. name .. ".cfg", HttpService:JSONEncode(Flags))
                    end
                    Library.Notifications:Create({Name = "Saved config: " .. name .. ".cfg"})
                end
            end})
            SectionLeft:Button({Name = "Load Config", Callback = function() 
                local name = Flags["config_name_text"]
                if name and name ~= "" and readfile and isfile and isfile(Library.Directory .. "/configs/" .. name .. ".cfg") then
                    local data = HttpService:JSONDecode(readfile(Library.Directory .. "/configs/" .. name .. ".cfg"))
                    for k, v in pairs(data) do
                        if ConfigFlags[k] then ConfigFlags[k](v) end
                    end
                    Library.Notifications:Create({Name = "Loaded config: " .. name .. ".cfg"})
                end
            end})

            local SectionRight = Tab:Section({Name = "Theme Colors", Side = "Right"})
            SectionRight:Label({Name = "Accent Color"}):Colorpicker({
                Color = themes.preset.accent,
                Callback = function(col) Library:RefreshTheme("accent", col) end
            })
            SectionRight:Label({Name = "Main Background"}):Colorpicker({
                Color = themes.preset.background,
                Callback = function(col) Library:RefreshTheme("background", col) end
            })
            SectionRight:Label({Name = "Inline Panels"}):Colorpicker({
                Color = themes.preset.inline,
                Callback = function(col) Library:RefreshTheme("inline", col) end
            })
            SectionRight:Label({Name = "Text Color"}):Colorpicker({
                Color = themes.preset.text_color,
                Callback = function(col) Library:RefreshTheme("text_color", col) end
            })
            SectionRight:Button({
                Name = "Unload Xezios",
                Callback = function() Library:Unload() end
            })
        end
    --

    -- NOTIFICATION SYSTEM
        function Notifications:RefreshNotifications() 
            local offset = 50
            for i, v in ipairs(Notifications.Notifs) do
                if v and v.Parent then
                    Library:Tween(v, {Position = dim_offset(20, offset)}, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out))
                    offset = offset + (v.AbsoluteSize.Y + 8)
                end
            end
            return offset
        end
        
        function Notifications:Create(properties)
            properties = properties or {}
            local Name = properties.Name or "Notification"
            local Lifetime = properties.LifeTime or properties.Lifetime or 3
            
            local notifGui = Library.Items or GetSafeParent()
            local outline = Library:Create("Frame", {
                Parent = notifGui;
                Position = dim2(0, -200, 0, 50);
                Size = dim2(0, 240, 0, 32);
                BorderSizePixel = 0;
                BackgroundColor3 = themes.preset.inline
            }); Library:Themify(outline, "inline", "BackgroundColor3")
            
            local inline = Library:Create("Frame", {
                Parent = outline;
                Position = dim2(0, 1, 0, 1);
                Size = dim2(1, -2, 1, -2);
                BorderSizePixel = 0;
                BackgroundColor3 = themes.preset.visible_backgrounds
            }); Library:Themify(inline, "visible_backgrounds", "BackgroundColor3")
            
            local lbl = Library:Create("TextLabel", {
                Parent = inline;
                Size = dim2(1, -12, 1, 0);
                Position = dim2(0, 8, 0, 0);
                Font = Enum.Font.GothamMedium;
                TextColor3 = themes.preset.text_color;
                Text = Name;
                TextSize = 12;
                TextXAlignment = Enum.TextXAlignment.Left;
                BackgroundTransparency = 1;
            }); Library:Themify(lbl, "text_color", "TextColor3")
            
            table.insert(Notifications.Notifs, outline)
            Notifications:RefreshNotifications()
            
            task.delay(Lifetime, function()
                if outline and outline.Parent then
                    Library:Tween(outline, {Position = dim2(0, -260, 0, outline.Position.Y.Offset)}, TweenInfo.new(0.4)).Completed:Connect(function()
                        for idx, v in ipairs(Notifications.Notifs) do
                            if v == outline then table.remove(Notifications.Notifs, idx) break end
                        end
                        outline:Destroy()
                        Notifications:RefreshNotifications()
                    end)
                end
            end)
        end
    --

return Library
