--[[
    MILENIUM UI LIBRARY v3.0 (with Cinematic Loading Screen)
    -> Made by @finobe 
    -> Integrated with Smooth Animated Loading Screen
    -> Multi-Tabs, Sub-Tabs, Colorpicker, Keybinds, Sliders & Notifications
    -> Compatible with Roblox Luau & Modern Executors
]]

-- Variables 
    local uis = game:GetService("UserInputService") 
    local players = game:GetService("Players") 
    local ws = game:GetService("Workspace")
    local rs = game:GetService("ReplicatedStorage")
    local http_service = game:GetService("HttpService")
    local gui_service = game:GetService("GuiService")
    local lighting = game:GetService("Lighting")
    local run = game:GetService("RunService")
    local stats = game:GetService("Stats")
    local coregui = game:GetService("CoreGui")
    local debris = game:GetService("Debris")
    local tween_service = game:GetService("TweenService")
    local sound_service = game:GetService("SoundService")

    local vec2 = Vector2.new
    local vec3 = Vector3.new
    local dim2 = UDim2.new
    local dim = UDim.new 
    local rect = Rect.new
    local cfr = CFrame.new
    local empty_cfr = cfr()
    local dim_offset = UDim2.fromOffset

    local color = Color3.new
    local rgb = Color3.fromRGB
    local hex = Color3.fromHex
    local hsv = Color3.fromHSV
    local rgbseq = ColorSequence.new
    local rgbkey = ColorSequenceKeypoint.new
    local numseq = NumberSequence.new
    local numkey = NumberSequenceKeypoint.new

    local camera = ws.CurrentCamera
    local lp = players.LocalPlayer 
    local mouse = lp and lp:GetMouse() 
    local gui_offset = gui_service:GetGuiInset().Y

    local max = math.max 
    local floor = math.floor 
    local min = math.min 
    local abs = math.abs 
    local clamp = math.clamp 

    local insert = table.insert 
    local find = table.find 
    local remove = table.remove
    local concat = table.concat

    local function get_safe_parent()
        local success, result = pcall(function()
            return coregui
        end)
        if success and result then
            local test = Instance.new("Folder")
            local pSuccess = pcall(function()
                test.Parent = coregui
                test:Destroy()
            end)
            if pSuccess then return coregui end
        end
        return (lp and lp:WaitForChild("PlayerGui")) or coregui
    end
-- 

-- Library init
    local library = {
        directory = "milenium",
        folders = {
            "/fonts",
            "/configs",
        },
        flags = {},
        config_flags = {},
        connections = {},   
        notifications = {notifs = {}},
        current_open = nil;
        cache = Instance.new("Folder");
    }
    library.__index = library

    if getgenv then
        getgenv().library = library
        getgenv().Library = library
    end

    local themes = {
    preset = {
        accent              = Color3.fromRGB(133, 0, 0),
        window_outline      = Color3.fromRGB(0, 0, 0),
        inline              = Color3.fromRGB(25, 25, 29),
        background          = Color3.fromRGB(14, 14, 16),
        visible_backgrounds = Color3.fromRGB(22, 22, 24),
        text_color          = Color3.fromRGB(255, 255, 255),
        glow                = Color3.fromRGB(0, 0, 0),
        deselected          = Color3.fromRGB(72, 72, 73), -- Milenium signature lavender purple
        }, 

        utility = {
            accent = {
                BackgroundColor3 = {}, 	
                TextColor3 = {}, 
                ImageColor3 = {}, 
                ScrollBarImageColor3 = {} 
            },
        }
    }

    local keys = {
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
        [Enum.KeyCode.Escape] = "ESC",
        [Enum.KeyCode.Space] = "SPC",
    }

    pcall(function()
        if makefolder then
            for _, path in next, library.folders do 
                makefolder(library.directory .. path)
            end
        end
    end)

    local flags = library.flags 
    local config_flags = library.config_flags
    local notifications = library.notifications 

    local fonts = {
        small = Font.fromEnum(Enum.Font.GothamMedium),
        font = Font.fromEnum(Enum.Font.GothamBold)
    }
--

-- Library functions 
    -- Misc functions
        function library:tween(obj, properties, easing_style, time) 
            local tween = tween_service:Create(obj, TweenInfo.new(time or 0.25, easing_style or Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0, false, 0), properties)
            tween:Play()
            return tween
        end

        function library:resizify(frame) 
            local Frame = Instance.new("TextButton")
            Frame.Position = dim2(1, -12, 1, -12)
            Frame.BorderColor3 = rgb(0, 0, 0)
            Frame.Size = dim2(0, 12, 0, 12)
            Frame.BorderSizePixel = 0
            Frame.BackgroundColor3 = rgb(255, 255, 255)
            Frame.Parent = frame
            Frame.BackgroundTransparency = 1 
            Frame.Text = ""

            local resizing = false 
            local start_size 
            local start 
            local og_size = frame.Size  

            Frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    resizing = true
                    start = input.Position
                    start_size = frame.Size
                end
            end)

            Frame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    resizing = false
                end
            end)

            library:connection(uis.InputChanged, function(input) 
                if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local viewport_x = camera and camera.ViewportSize.X or 1920
                    local viewport_y = camera and camera.ViewportSize.Y or 1080

                    local current_size = dim2(
                        start_size.X.Scale,
                        math.clamp(start_size.X.Offset + (input.Position.X - start.X), og_size.X.Offset, viewport_x),
                        start_size.Y.Scale,
                        math.clamp(start_size.Y.Offset + (input.Position.Y - start.Y), og_size.Y.Offset, viewport_y)
                    )

                    library:tween(frame, {Size = current_size}, Enum.EasingStyle.Linear, 0.05)
                end
            end)
        end 

        function library:next_flag()
            local size = 0
            for _ in pairs(library.flags) do size = size + 1 end
            return string.format("flag_%s", size + 1)
        end 

        function library:draggify(frame)
            local dragging = false 
            local start_pos = frame.Position
            local start 

            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    start = input.Position
                    start_pos = frame.Position
                end
            end)

            frame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            library:connection(uis.InputChanged, function(input) 
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local viewport_x = camera and camera.ViewportSize.X or 1920
                    local viewport_y = camera and camera.ViewportSize.Y or 1080

                    local current_position = dim2(
                        0,
                        clamp(start_pos.X.Offset + (input.Position.X - start.X), 0, viewport_x - frame.Size.X.Offset),
                        0,
                        clamp(start_pos.Y.Offset + (input.Position.Y - start.Y), 0, viewport_y - frame.Size.Y.Offset)
                    )

                    library:tween(frame, {Position = current_position}, Enum.EasingStyle.Linear, 0.05)
                    library:close_element()
                end
            end)
        end 

        function library:convert(str)
            local values = {}
            for value in string.gmatch(str, "[^,]+") do
                insert(values, tonumber(value))
            end
            if #values == 4 then return unpack(values) end
            return nil
        end
        
        function library:round(number, float) 
            local multiplier = 1 / (float or 1)
            return floor(number * multiplier + 0.5) / multiplier
        end 

        function library:apply_theme(instance, theme, property) 
            if themes.utility[theme] and themes.utility[theme][property] then
                insert(themes.utility[theme][property], instance)
            end
        end

        function library:update_theme(theme, newColor)
            if themes.utility[theme] then
                for prop, instances in pairs(themes.utility[theme]) do 
                    for _, object in ipairs(instances) do 
                        if object and object.Parent then 
                            object[prop] = newColor 
                        end 
                    end 
                end
            end
            themes.preset[theme] = newColor 
        end 

        function library:connection(signal, callback)
            local connection = signal:Connect(callback)
            insert(library.connections, connection)
            return connection 
        end

        function library:close_element(new_path) 
            local open_element = library.current_open
            if open_element and new_path ~= open_element then
                if open_element.set_visible then open_element.set_visible(false) end
                open_element.open = false
            end 
            if new_path ~= open_element then 
                library.current_open = new_path or nil
            end
        end 

        function library:create(instance, options)
            local ins = Instance.new(instance) 
            for prop, value in pairs(options) do 
                ins[prop] = value
            end
            return ins 
        end

        function library:unload_menu() 
            if library["items"] then 
                library["items"]:Destroy()
            end
            if library["other"] then 
                library["other"]:Destroy()
            end 
            for _, connection in ipairs(library.connections) do 
                if connection and connection.Connected then
                    connection:Disconnect() 
                end
            end
            library.connections = {}
            print("[MILENIUM] Unloaded successfully.")
        end 

        ------------------------------------------------------------------------
        -- 🌟 ANIMATED LOADING SCREEN COMPONENT
        ------------------------------------------------------------------------
        function library:loader(options)
            options = options or {}
            local Title = options.title or options.Title or "MILENIUM"
            local Suffix = options.suffix or options.Suffix or "TECH"
            local Subtitle = options.subtitle or options.Subtitle or "CS:GO PRIVATE BUILD"
            local Duration = options.duration or options.Duration or 2.8
            local Steps = options.steps or options.Steps or {
                "Bypassing anticheat heuristics...",
                "Hooking virtual method tables...",
                "Allocating memory addresses...",
                "Decrypting config profiles...",
                "Initializing visual renderers...",
                "Ready!"
            }
            local Callback = options.callback or options.Callback or function() end

            local parentGui = get_safe_parent()

            local loaderGui = library:create("ScreenGui", {
                Parent = parentGui,
                Name = "Milenium_Loader",
                Enabled = true,
                ZIndexBehavior = Enum.ZIndexBehavior.Global,
                IgnoreGuiInset = true,
                DisplayOrder = 999999,
            })

            -- Fullscreen Backdrop Dimmer
            local backdrop = library:create("Frame", {
                Parent = loaderGui,
                Size = dim2(1, 0, 1, 0),
                BackgroundColor3 = rgb(8, 8, 10),
                BackgroundTransparency = 0.25,
                BorderSizePixel = 0,
                ZIndex = 100,
            })

            -- Floating Centered Card
            local card = library:create("Frame", {
                Parent = backdrop,
                AnchorPoint = vec2(0.5, 0.5),
                Position = dim2(0.5, 0, 0.5, 30),
                Size = dim2(0, 370, 0, 220),
                BackgroundColor3 = rgb(14, 14, 17),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 101,
            })

            library:create("UICorner", {
                Parent = card,
                CornerRadius = dim(0, 12),
            })

            local cardStroke = library:create("UIStroke", {
                Parent = card,
                Color = rgb(155, 150, 219),
                Transparency = 0.5,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Thickness = 1.2,
            })

            -- Ambient Glow Drop Shadow
            local cardShadow = library:create("ImageLabel", {
                Parent = card,
                AnchorPoint = vec2(0.5, 0.5),
                Position = dim2(0.5, 0, 0.5, 0),
                Size = dim2(1, 80, 1, 80),
                Image = "rbxassetid://112971167999062",
                ImageColor3 = rgb(155, 150, 219),
                ImageTransparency = 0.85,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = rect(vec2(112, 112), vec2(147, 147)),
                ZIndex = 99,
            })

            -- Pulsing Logo Holder
            local iconFrame = library:create("Frame", {
                Parent = card,
                AnchorPoint = vec2(0.5, 0),
                Position = dim2(0.5, 0, 0, 20),
                Size = dim2(0, 46, 0, 46),
                BackgroundColor3 = rgb(23, 23, 29),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 102,
            })
            library:create("UICorner", {
                Parent = iconFrame,
                CornerRadius = dim(0, 12),
            })
            local iconStroke = library:create("UIStroke", {
                Parent = iconFrame,
                Color = themes.preset.accent,
                Transparency = 0.5,
                Thickness = 1,
            })
            local iconImg = library:create("ImageLabel", {
                Parent = iconFrame,
                AnchorPoint = vec2(0.5, 0.5),
                Position = dim2(0.5, 0, 0.5, 0),
                Size = dim2(0, 24, 0, 24),
                Image = "rbxassetid://10709791437",
                ImageColor3 = themes.preset.accent,
                ImageTransparency = 1,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 103,
            })

            -- Header Title & Subtitle
            local titleLbl = library:create("TextLabel", {
                Parent = card,
                AnchorPoint = vec2(0.5, 0),
                Position = dim2(0.5, 0, 0, 74),
                Size = dim2(1, -20, 0, 24),
                FontFace = fonts.font,
                Text = string.format('<u>%s</u> <font color="rgb(255, 255, 255)">%s</font>', Title, Suffix),
                RichText = true,
                TextColor3 = themes.preset.accent,
                TextTransparency = 1,
                TextSize = 20,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 102,
            })

            local subLbl = library:create("TextLabel", {
                Parent = card,
                AnchorPoint = vec2(0.5, 0),
                Position = dim2(0.5, 0, 0, 100),
                Size = dim2(1, -20, 0, 16),
                FontFace = fonts.small,
                Text = Subtitle,
                TextColor3 = rgb(110, 110, 125),
                TextTransparency = 1,
                TextSize = 12,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 102,
            })

            -- Progress Bar Track
            local progressTrack = library:create("Frame", {
                Parent = card,
                AnchorPoint = vec2(0.5, 0),
                Position = dim2(0.5, 0, 0, 136),
                Size = dim2(1, -48, 0, 6),
                BackgroundColor3 = rgb(25, 25, 32),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 102,
            })
            library:create("UICorner", {
                Parent = progressTrack,
                CornerRadius = dim(0, 999),
            })

            local progressFill = library:create("Frame", {
                Parent = progressTrack,
                Size = dim2(0, 0, 1, 0),
                BackgroundColor3 = themes.preset.accent,
                BorderSizePixel = 0,
                ZIndex = 103,
            })
            library:create("UICorner", {
                Parent = progressFill,
                CornerRadius = dim(0, 999),
            })

            -- Status Step & Percent
            local stepLbl = library:create("TextLabel", {
                Parent = card,
                AnchorPoint = vec2(0, 0),
                Position = dim2(0, 24, 0, 152),
                Size = dim2(0.72, 0, 0, 18),
                FontFace = fonts.small,
                Text = Steps[1] or "Initializing...",
                TextColor3 = rgb(145, 145, 155),
                TextTransparency = 1,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 102,
            })

            local percentLbl = library:create("TextLabel", {
                Parent = card,
                AnchorPoint = vec2(1, 0),
                Position = dim2(1, -24, 0, 152),
                Size = dim2(0.25, 0, 0, 18),
                FontFace = fonts.font,
                Text = "0%",
                TextColor3 = themes.preset.accent,
                TextTransparency = 1,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 102,
            })

            -- 🎬 Step 1: Smooth Entrance Animation
            library:tween(card, {Position = dim2(0.5, 0, 0.5, 0), BackgroundTransparency = 0}, Enum.EasingStyle.Back, 0.6)
            library:tween(iconFrame, {BackgroundTransparency = 0}, Enum.EasingStyle.Quad, 0.5)
            library:tween(iconImg, {ImageTransparency = 0}, Enum.EasingStyle.Quad, 0.5)
            library:tween(titleLbl, {TextTransparency = 0}, Enum.EasingStyle.Quad, 0.5)
            library:tween(subLbl, {TextTransparency = 0}, Enum.EasingStyle.Quad, 0.5)
            library:tween(progressTrack, {BackgroundTransparency = 0}, Enum.EasingStyle.Quad, 0.5)
            library:tween(stepLbl, {TextTransparency = 0}, Enum.EasingStyle.Quad, 0.5)
            library:tween(percentLbl, {TextTransparency = 0}, Enum.EasingStyle.Quad, 0.5)

            -- Pulsing logo loop
            local pulseActive = true
            task.spawn(function()
                while pulseActive and iconFrame and iconFrame.Parent do
                    library:tween(iconStroke, {Transparency = 0.1}, Enum.EasingStyle.Sine, 0.45)
                    task.wait(0.45)
                    if not pulseActive then break end
                    library:tween(iconStroke, {Transparency = 0.7}, Enum.EasingStyle.Sine, 0.45)
                    task.wait(0.45)
                end
            end)

            -- 🎬 Step 2: Step-by-step progress animation
            task.spawn(function()
                task.wait(0.4)
                local stepCount = #Steps
                local stepDuration = Duration / stepCount

                for i, stepText in ipairs(Steps) do
                    local progressRatio = i / stepCount
                    stepLbl.Text = stepText
                    library:tween(progressFill, {Size = dim2(progressRatio, 0, 1, 0)}, Enum.EasingStyle.Quad, stepDuration * 0.9)
                    
                    -- Smooth percentage counter
                    local startPct = floor(((i - 1) / stepCount) * 100)
                    local endPct = floor(progressRatio * 100)
                    local subSteps = 6
                    for s = 1, subSteps do
                        local current = floor(startPct + (endPct - startPct) * (s / subSteps))
                        percentLbl.Text = tostring(current) .. "%"
                        task.wait(stepDuration / subSteps)
                    end
                end

                -- Final celebration flash
                pulseActive = false
                stepLbl.Text = "READY!"
                stepLbl.TextColor3 = rgb(255, 255, 255)
                percentLbl.Text = "100%"
                cardStroke.Color = rgb(255, 255, 255)
                cardStroke.Transparency = 0.1
                task.wait(0.2)
                cardStroke.Color = themes.preset.accent

                task.wait(0.35)

                -- 🎬 Step 3: Exit Animation (dissolves & reveals main window)
                library:tween(card, {
                    Position = dim2(0.5, 0, 0.5, -20),
                    Size = dim2(0, 390, 0, 230),
                    BackgroundTransparency = 1
                }, Enum.EasingStyle.Quad, 0.45)
                library:tween(cardShadow, {ImageTransparency = 1}, Enum.EasingStyle.Quad, 0.4)
                library:tween(backdrop, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.45)

                for _, desc in ipairs(card:GetDescendants()) do
                    if desc:IsA("TextLabel") then
                        library:tween(desc, {TextTransparency = 1}, Enum.EasingStyle.Quad, 0.35)
                    elseif desc:IsA("ImageLabel") then
                        library:tween(desc, {ImageTransparency = 1}, Enum.EasingStyle.Quad, 0.35)
                    elseif desc:IsA("Frame") then
                        library:tween(desc, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.35)
                    elseif desc:IsA("UIStroke") then
                        library:tween(desc, {Transparency = 1}, Enum.EasingStyle.Quad, 0.35)
                    end
                end

                task.wait(0.45)
                loaderGui:Destroy()

                -- Trigger finished callback
                Callback()
            end)

            return loaderGui
        end
    --
    
    -- Library element functions
        function library:window(properties)
            properties = properties or {}
            local useLoading = properties.loading ~= false -- Enabled by default!

            local cfg = { 
                suffix = properties.suffix or properties.Suffix or "tech";
                name = properties.name or properties.Name or "milenium";
                game_name = properties.gameInfo or properties.game_info or properties.GameInfo or "Milenium for Counter-Strike: Global Offensive";
                size = properties.size or properties.Size or dim2(0, 700, 0, 565);
                selected_tab = nil;
                items = {};
                tween = nil;
            }

            local parentGui = get_safe_parent()
            
            library["items"] = library:create("ScreenGui", {
                Parent = parentGui;
                Name = "Milenium_Main";
                Enabled = true;
                ZIndexBehavior = Enum.ZIndexBehavior.Global;
                IgnoreGuiInset = true;
            });
            
            library["other"] = library:create("ScreenGui", {
                Parent = parentGui;
                Name = "Milenium_Other";
                Enabled = true;
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
                IgnoreGuiInset = true;
            }); 

            local items = cfg.items; do
                items["main"] = library:create("Frame", {
                    Parent = library["items"];
                    Size = cfg.size;
                    Name = "MainFrame";
                    AnchorPoint = vec2(0.5, 0.5);
                    Position = dim2(0.5, 0, 0.5, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(14, 14, 16);
                    Visible = not useLoading; -- Initially hidden if loading screen is active
                });
                
                library:create("UICorner", {
                    Parent = items["main"];
                    CornerRadius = dim(0, 10)
                });
                
                library:create("UIStroke", {
                    Color = rgb(23, 23, 29);
                    Parent = items["main"];
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                });
                
                items["side_frame"] = library:create("Frame", {
                    Parent = items["main"];
                    BackgroundTransparency = 1;
                    Name = "SideFrame";
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 196, 1, -25);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(14, 14, 16)
                });
                
                library:create("Frame", {
                    AnchorPoint = vec2(1, 0);
                    Parent = items["side_frame"];
                    Position = dim2(1, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 1, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(21, 21, 23)
                });
                
                items["button_holder"] = library:create("Frame", {
                    Parent = items["side_frame"];
                    Name = "ButtonHolder";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 0, 0, 60);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 1, -60);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                }); cfg.button_holder = items["button_holder"];
                
                library:create("UIListLayout", {
                    Parent = items["button_holder"];
                    Padding = dim(0, 5);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
                
                library:create("UIPadding", {
                    PaddingTop = dim(0, 16);
                    PaddingBottom = dim(0, 36);
                    Parent = items["button_holder"];
                    PaddingRight = dim(0, 11);
                    PaddingLeft = dim(0, 10)
                });

                items["title"] = library:create("TextLabel", {
                    FontFace = fonts.font;
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = items["side_frame"];
                    Name = "Title";
                    Text = string.format('<u>%s</u><font color="rgb(255, 255, 255)">%s</font>', cfg.name, cfg.suffix);
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 70);
                    TextColor3 = themes.preset.accent;
                    BorderSizePixel = 0;
                    RichText = true;
                    TextSize = 28;
                    BackgroundColor3 = rgb(255, 255, 255)
                }); library:apply_theme(items["title"], "accent", "TextColor3");
                
                items["multi_holder"] = library:create("Frame", {
                    Parent = items["main"];
                    Name = "MultiHolder";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 196, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -196, 0, 56);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                }); cfg.multi_holder = items["multi_holder"];
                
                library:create("Frame", {
                    AnchorPoint = vec2(0, 1);
                    Parent = items["multi_holder"];
                    Position = dim2(0, 0, 1, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 0, 1);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(21, 21, 23)
                });
                
                items["shadow"] = library:create("ImageLabel", {
                    ImageColor3 = rgb(0, 0, 0);
                    ScaleType = Enum.ScaleType.Slice;
                    Parent = items["main"];
                    BorderColor3 = rgb(0, 0, 0);
                    Name = "Shadow";
                    BackgroundColor3 = rgb(255, 255, 255);
                    Size = dim2(1, 75, 1, 75);
                    AnchorPoint = vec2(0.5, 0.5);
                    Image = "rbxassetid://112971167999062";
                    BackgroundTransparency = 1;
                    Position = dim2(0.5, 0, 0.5, 0);
                    SliceScale = 0.75;
                    ZIndex = -100;
                    BorderSizePixel = 0;
                    SliceCenter = rect(vec2(112, 112), vec2(147, 147))
                });
                
                items["global_fade"] = library:create("Frame", {
                    Parent = items["main"];
                    Name = "GlobalFade";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 196, 0, 56);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -196, 1, -81);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(14, 14, 16);
                    ZIndex = 2;
                });                

                library:create("UICorner", {
                    Parent = items["shadow"];
                    CornerRadius = dim(0, 5)
                });
                
                items["info"] = library:create("Frame", {
                    AnchorPoint = vec2(0, 1);
                    Parent = items["main"];
                    Name = "InfoBar";
                    Position = dim2(0, 0, 1, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 0, 25);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(23, 23, 25)
                });
                
                library:create("UICorner", {
                    Parent = items["info"];
                    CornerRadius = dim(0, 10)
                });
                
                items["game"] = library:create("TextLabel", {
                    FontFace = fonts.font;
                    Parent = items["info"];
                    TextColor3 = rgb(72, 72, 73);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = cfg.game_name;
                    Name = "Game";
                    Size = dim2(1, 0, 0, 0);
                    AnchorPoint = vec2(0, 0.5);
                    Position = dim2(0, 10, 0.5, -1);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255)
                }); 
                
                items["other_info"] = library:create("TextLabel", {
                    Parent = items["info"];
                    RichText = true;
                    Name = "OtherInfo";
                    TextColor3 = themes.preset.accent;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = '<font color="rgb(72, 72, 73)">30 days active, </font>' .. cfg.name .. cfg.suffix;
                    Size = dim2(1, 0, 0, 0);
                    Position = dim2(0, -10, 0.5, -1);
                    AnchorPoint = vec2(0, 0.5);
                    BorderSizePixel = 0;
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Right;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    FontFace = fonts.font;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255)
                }); library:apply_theme(items["other_info"], "accent", "TextColor3");        
            end 

            do -- Interactive Dragging & Resizing
                library:draggify(items["main"])
                library:resizify(items["main"])
            end 

            function cfg.toggle_menu(bool) 
                if bool == nil then
                    items["main"].Visible = not items["main"].Visible
                else
                    items["main"].Visible = bool
                end
            end 

            -- Play loading sequence if enabled
            if useLoading then
                library:loader({
                    title = cfg.name:upper(),
                    suffix = cfg.suffix:upper(),
                    subtitle = cfg.game_name,
                    duration = properties.loading_duration or 2.6,
                    steps = properties.loading_steps,
                    callback = function()
                        -- Reveal Main Window with Entrance Scale Animation
                        items["main"].Visible = true
                        items["main"].Size = dim2(0, cfg.size.X.Offset * 0.9, 0, cfg.size.Y.Offset * 0.9)
                        library:tween(items["main"], {Size = cfg.size}, Enum.EasingStyle.Back, 0.5)

                        notifications:create_notification({
                            name = cfg.name .. cfg.suffix,
                            info = "Successfully injected and initialized!",
                            lifetime = 3.5
                        })
                    end
                })
            end

            -- Direct method attachments on cfg for convenience
            cfg.tab = function(self, ...) return library.tab(self, ...) end
            cfg.Tab = cfg.tab
            cfg.CreateTab = cfg.tab
            cfg.seperator = function(self, ...) return library.seperator(self, ...) end
            cfg.Seperator = cfg.seperator
            cfg.init_config = function(self, ...) return library.init_config(self, ...) end

            return setmetatable(cfg, library)
        end 

        function library:tab(properties)
            local cfg = {
                name = properties.name or properties.Name or "visuals"; 
                icon = properties.icon or properties.Icon or "http://www.roblox.com/asset/?id=6034767608";
                tabs = properties.tabs or properties.Tabs or {"Main", "Misc.", "Settings"};
                pages = {};
                current_multi = nil; 
                items = {};
            } 

            local items = cfg.items; do 
                items["tab_holder"] = library:create("Frame", {
                    Parent = library.cache;
                    Name = "TabHolder_" .. cfg.name;
                    Visible = false;
                    BackgroundTransparency = 1;
                    Position = dim2(0, 196, 0, 56);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -216, 1, -101);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                -- Tab button in sidebar
                items["button"] = library:create("TextButton", {
                    FontFace = fonts.font;
                    TextColor3 = rgb(255, 255, 255);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    Parent = self.items["button_holder"];
                    AutoButtonColor = false;
                    BackgroundTransparency = 1;
                    Name = "TabBtn_" .. cfg.name;
                    Size = dim2(1, 0, 0, 35);
                    BorderSizePixel = 0;
                    TextSize = 15;
                    BackgroundColor3 = rgb(29, 29, 29)
                });
                
                items["icon"] = library:create("ImageLabel", {
                    ImageColor3 = rgb(72, 72, 73);
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = items["button"];
                    AnchorPoint = vec2(0, 0.5);
                    Image = cfg.icon;
                    BackgroundTransparency = 1;
                    Position = dim2(0, 10, 0.5, 0);
                    Name = "Icon";
                    Size = dim2(0, 20, 0, 20);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                }); library:apply_theme(items["icon"], "accent", "ImageColor3");
                
                items["name"] = library:create("TextLabel", {
                    FontFace = fonts.font;
                    TextColor3 = rgb(72, 72, 73);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = cfg.name;
                    Parent = items["button"];
                    Name = "Label";
                    Size = dim2(0, 0, 1, 0);
                    Position = dim2(0, 38, 0, 0);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.X;
                    TextSize = 15;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create("UICorner", {
                    Parent = items["button"];
                    CornerRadius = dim(0, 7)
                });
                
                -- Multi-Section Bar at the top of the tab
                items["multi_section_button_holder"] = library:create("Frame", {
                    Parent = library.cache;
                    BackgroundTransparency = 1;
                    Name = "MultiHolder_" .. cfg.name;
                    Visible = false;
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create("UIListLayout", {
                    Parent = items["multi_section_button_holder"];
                    Padding = dim(0, 7);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    FillDirection = Enum.FillDirection.Horizontal
                });
                
                library:create("UIPadding", {
                    PaddingTop = dim(0, 8);
                    PaddingBottom = dim(0, 7);
                    Parent = items["multi_section_button_holder"];
                    PaddingRight = dim(0, 7);
                    PaddingLeft = dim(0, 7)
                });                        

                for _, section in ipairs(cfg.tabs) do
                    local data = {items = {}} 

                    local multi_items = data.items; do 
                        multi_items["button"] = library:create("TextButton", {
                            FontFace = fonts.font;
                            TextColor3 = rgb(255, 255, 255);
                            BorderColor3 = rgb(0, 0, 0);
                            AutoButtonColor = false;
                            Text = "";
                            Parent = items["multi_section_button_holder"];
                            Name = "SubBtn_" .. section;
                            Size = dim2(0, 0, 0, 39);
                            BackgroundTransparency = 1;
                            ClipsDescendants = true;
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.X;
                            TextSize = 15;
                            BackgroundColor3 = rgb(25, 25, 29)
                        });
                        
                        multi_items["name"] = library:create("TextLabel", {
                            FontFace = fonts.font;
                            TextColor3 = rgb(62, 62, 63);
                            BorderColor3 = rgb(0, 0, 0);
                            Text = section;
                            Parent = multi_items["button"];
                            Name = "Label";
                            Size = dim2(0, 0, 1, 0);
                            BackgroundTransparency = 1;
                            TextXAlignment = Enum.TextXAlignment.Left;
                            BorderSizePixel = 0;
                            AutomaticSize = Enum.AutomaticSize.XY;
                            TextSize = 15;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });
                        
                        library:create("UIPadding", {
                            Parent = multi_items["name"];
                            PaddingRight = dim(0, 6);
                            PaddingLeft = dim(0, 6)
                        });
                        
                        multi_items["accent"] = library:create("Frame", {
                            BorderColor3 = rgb(0, 0, 0);
                            AnchorPoint = vec2(0, 1);
                            Parent = multi_items["button"];
                            BackgroundTransparency = 1;
                            Position = dim2(0, 10, 1, 4);
                            Name = "Underline";
                            Size = dim2(1, -20, 0, 5);
                            BorderSizePixel = 0;
                            BackgroundColor3 = themes.preset.accent
                        }); library:apply_theme(multi_items["accent"], "accent", "BackgroundColor3");
                        
                        library:create("UICorner", {
                            Parent = multi_items["accent"];
                            CornerRadius = dim(0, 999)
                        });
                        
                        library:create("UICorner", {
                            Parent = multi_items["button"];
                            CornerRadius = dim(0, 7)
                        }); 

                        -- SubTab Content Frame
                        multi_items["tab"] = library:create("Frame", {
                            Parent = library.cache;
                            BackgroundTransparency = 1;
                            Name = "SubPage_" .. section;
                            BorderColor3 = rgb(0, 0, 0);
                            Size = dim2(1, -20, 1, -20);
                            BorderSizePixel = 0;
                            Visible = false;
                            BackgroundColor3 = rgb(255, 255, 255)
                        });
                        
                        library:create("UIListLayout", {
                            FillDirection = Enum.FillDirection.Vertical;
                            HorizontalFlex = Enum.UIFlexAlignment.Fill;
                            Parent = multi_items["tab"];
                            Padding = dim(0, 7);
                            SortOrder = Enum.SortOrder.LayoutOrder;
                            VerticalFlex = Enum.UIFlexAlignment.Fill
                        });
                    end

                    data.text = multi_items["name"]
                    data.accent = multi_items["accent"]
                    data.button = multi_items["button"]
                    data.page = multi_items["tab"]
                    data.parent = setmetatable(data, library):sub_tab({}).items["tab_parent"]

                    function data.open_page()
                        local page = cfg.current_multi 
                        
                        if page and page.text ~= data.text then 
                            self.items["global_fade"].BackgroundTransparency = 0
                            library:tween(self.items["global_fade"], {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.35)
                            page.page.Size = dim2(1, -20, 1, -20)
                        end

                        if page then
                            library:tween(page.text, {TextColor3 = rgb(62, 62, 63)})
                            library:tween(page.accent, {BackgroundTransparency = 1})
                            library:tween(page.button, {BackgroundTransparency = 1})

                            page.page.Visible = false
                            page.page.Parent = library.cache
                        end 
                        
                        library:tween(data.text, {TextColor3 = rgb(255, 255, 255)})
                        library:tween(data.accent, {BackgroundTransparency = 0})
                        library:tween(data.button, {BackgroundTransparency = 0})
                        library:tween(data.page, {Size = dim2(1, 0, 1, 0)}, Enum.EasingStyle.Quad, 0.35)

                        data.page.Visible = true
                        data.page.Parent = items["tab_holder"]

                        cfg.current_multi = data
                        library:close_element()
                    end

                    multi_items["button"].MouseButton1Down:Connect(function()
                        data.open_page() 
                    end)

                    cfg.pages[#cfg.pages + 1] = setmetatable(data, library)
                end 

                if #cfg.pages > 0 then
                    cfg.pages[1].open_page()
                end
            end 

            function cfg.open_tab() 
                local selected_tab = self.selected_tab
                
                if selected_tab then 
                    if selected_tab[4] ~= items["tab_holder"] then 
                        self.items["global_fade"].BackgroundTransparency = 0
                        library:tween(self.items["global_fade"], {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, 0.35)
                        selected_tab[4].Size = dim2(1, -216, 1, -101)
                    end

                    library:tween(selected_tab[1], {BackgroundTransparency = 1})
                    library:tween(selected_tab[2], {ImageColor3 = rgb(72, 72, 73)})
                    library:tween(selected_tab[3], {TextColor3 = rgb(72, 72, 73)})

                    selected_tab[4].Visible = false
                    selected_tab[4].Parent = library.cache
                    selected_tab[5].Visible = false
                    selected_tab[5].Parent = library.cache
                end

                library:tween(items["button"], {BackgroundTransparency = 0})
                library:tween(items["icon"], {ImageColor3 = themes.preset.accent})
                library:tween(items["name"], {TextColor3 = rgb(255, 255, 255)})
                library:tween(items["tab_holder"], {Size = dim2(1, -196, 1, -81)}, Enum.EasingStyle.Quad, 0.35)
                
                items["tab_holder"].Visible = true 
                items["tab_holder"].Parent = self.items["main"]
                items["multi_section_button_holder"].Visible = true 
                items["multi_section_button_holder"].Parent = self.items["multi_holder"]

                self.selected_tab = {
                    items["button"],
                    items["icon"],
                    items["name"],
                    items["tab_holder"],
                    items["multi_section_button_holder"]
                }

                library:close_element()
            end

            items["button"].MouseButton1Down:Connect(function()
                cfg.open_tab()
            end)
            
            if not self.selected_tab then 
                cfg.open_tab() 
            end

            return unpack(cfg.pages)
        end

        function library:seperator(properties)
            local cfg = {items = {}, name = properties.Name or properties.name or "General"}
            local items = cfg.items do 
                items["name"] = library:create("TextLabel", {
                    FontFace = fonts.font;
                    TextColor3 = rgb(72, 72, 73);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = cfg.name;
                    Parent = self.items["button_holder"];
                    Name = "Seperator";
                    Size = dim2(1, 0, 0, 0);
                    Position = dim2(0, 40, 0, 0);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0; 
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 14;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create("UIPadding", {
                    Parent = items["name"];
                    PaddingRight = dim(0, 5);
                    PaddingLeft = dim(0, 5)
                });                
            end    

            return setmetatable(cfg, library)
        end 

        function library:column(properties) 
            local cfg = {items = {}, size = properties.size or 1}
            local items = cfg.items; do     
                items["column"] = library:create("Frame", {
                    Parent = self["parent"] or self.items["tab_parent"];
                    BackgroundTransparency = 1;
                    Name = "Column";
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 0, cfg.size, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create("UIPadding", {
                    PaddingBottom = dim(0, 10);
                    Parent = items["column"]
                });
                
                library:create("UIListLayout", {
                    Parent = items["column"];
                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    Padding = dim(0, 10);
                    FillDirection = Enum.FillDirection.Vertical;
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
            end 

            -- Direct aliases
            cfg.section = function(self, ...) return library.section(self, ...) end
            cfg.Section = cfg.section
            cfg.CreateSection = cfg.section

            return setmetatable(cfg, library)
        end 

        function library:sub_tab(properties) 
            local cfg = {items = {}, order = properties.order or 0; size = properties.size or 1}
            local items = cfg.items; do 
                items["tab_parent"] = library:create("Frame", {
                    Parent = self.items["tab"];
                    BackgroundTransparency = 1;
                    Name = "TabParent";
                    Size = dim2(0, 0, cfg.size, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    Visible = true;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    VerticalFlex = Enum.UIFlexAlignment.Fill;
                    Parent = items["tab_parent"];
                    Padding = dim(0, 7);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                });
            end

            cfg.column = function(self, ...) return library.column(self, ...) end
            cfg.Column = cfg.column

            return setmetatable(cfg, library)
        end 

        function library:section(properties)
            local cfg = {
                name = properties.name or properties.Name or "Section"; 
                side = properties.side or properties.Side or "left";
                default = properties.default or properties.Default or false;
                size = properties.size or properties.Size or self.size or 0.5; 
                icon = properties.icon or properties.Icon or "http://www.roblox.com/asset/?id=6022668898";
                fading_toggle = properties.fading or properties.Fading or false;
                items = {};
            };
            
            local items = cfg.items; do 
                items["outline"] = library:create("Frame", {
                    Name = "SectionOutline";
                    Parent = self.items["column"];
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 0, cfg.size, -3);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(25, 25, 29)
                });

                library:create("UICorner", {
                    Parent = items["outline"];
                    CornerRadius = dim(0, 7)
                });
                
                items["inline"] = library:create("Frame", {
                    Parent = items["outline"];
                    Name = "SectionInline";
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(22, 22, 24)
                });
                
                library:create("UICorner", {
                    Parent = items["inline"];
                    CornerRadius = dim(0, 7)
                });
                
                items["scrolling"] = library:create("ScrollingFrame", {
                    ScrollBarImageColor3 = rgb(44, 44, 46);
                    Active = true;
                    AutomaticCanvasSize = Enum.AutomaticSize.Y;
                    ScrollBarThickness = 2;
                    Parent = items["inline"];
                    Name = "Scroll";
                    Size = dim2(1, 0, 1, -40);
                    BackgroundTransparency = 1;
                    Position = dim2(0, 0, 0, 35);
                    BackgroundColor3 = rgb(255, 255, 255);
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    CanvasSize = dim2(0, 0, 0, 0)
                });
                
                items["elements"] = library:create("Frame", {
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = items["scrolling"];
                    Name = "Elements";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 10, 0, 10);
                    Size = dim2(1, -20, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create("UIListLayout", {
                    Parent = items["elements"];
                    Padding = dim(0, 10);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
                
                library:create("UIPadding", {
                    PaddingBottom = dim(0, 15);
                    Parent = items["elements"]
                });
                
                items["button"] = library:create("TextButton", {
                    FontFace = fonts.font;
                    TextColor3 = rgb(255, 255, 255);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    AutoButtonColor = false;
                    Parent = items["outline"];
                    Name = "Header";
                    Position = dim2(0, 1, 0, 1);
                    Size = dim2(1, -2, 0, 35);
                    BorderSizePixel = 0;
                    TextSize = 15;
                    BackgroundColor3 = rgb(19, 19, 21)
                });
                
                library:create("UICorner", {
                    Parent = items["button"];
                    CornerRadius = dim(0, 7)
                });
                
                items["Icon"] = library:create("ImageLabel", {
                    ImageColor3 = themes.preset.accent;
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = items["button"];
                    AnchorPoint = vec2(0, 0.5);
                    Image = cfg.icon;
                    BackgroundTransparency = 1;
                    Position = dim2(0, 10, 0.5, 0);
                    Name = "Icon";
                    Size = dim2(0, 20, 0, 20);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                }); library:apply_theme(items["Icon"], "accent", "ImageColor3");
                
                items["section_title"] = library:create("TextLabel", {
                    FontFace = fonts.font;
                    TextColor3 = rgb(255, 255, 255);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = cfg.name;
                    Parent = items["button"];
                    Name = "Title";
                    Size = dim2(0, 0, 1, 0);
                    Position = dim2(0, 38, 0, -1);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.X;
                    TextSize = 15;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create("Frame", {
                    AnchorPoint = vec2(0, 1);
                    Parent = items["button"];
                    Position = dim2(0, 0, 1, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 0, 1);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(36, 36, 37)
                });
                
                if cfg.fading_toggle then 
                    items["toggle"] = library:create("TextButton", {
                        FontFace = fonts.small;
                        TextColor3 = rgb(0, 0, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        AutoButtonColor = false;
                        Text = "";
                        AnchorPoint = vec2(1, 0.5);
                        Parent = items["button"];
                        Name = "Toggle";
                        Position = dim2(1, -9, 0.5, 0);
                        Size = dim2(0, 34, 0, 17);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(58, 58, 62)
                    });  library:apply_theme(items["toggle"], "accent", "BackgroundColor3");
                    
                    library:create("UICorner", {
                        Parent = items["toggle"];
                        CornerRadius = dim(0, 999)
                    });
                    
                    items["toggle_circle"] = library:create("Frame", {
                        Parent = items["toggle"];
                        Name = "Circle";
                        Position = dim2(0, 2, 0, 2);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 13, 0, 13);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(86, 86, 88)
                    });
                    
                    library:create("UICorner", {
                        Parent = items["toggle_circle"];
                        CornerRadius = dim(0, 999)
                    });
                    
                    items["fade"] = library:create("Frame", {
                        Parent = items["outline"];
                        BackgroundTransparency = 0.8;
                        Name = "FadeMask";
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, 0, 1, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });
                    
                    library:create("UICorner", {
                        Parent = items["fade"];
                        CornerRadius = dim(0, 7)
                    });
                end 
            end;

            if cfg.fading_toggle then
                items["button"].MouseButton1Click:Connect(function()
                    cfg.default = not cfg.default 
                    cfg.toggle_section(cfg.default) 
                end)

                function cfg.toggle_section(bool)
                    library:tween(items["toggle"], {BackgroundColor3 = bool and themes.preset.accent or rgb(58, 58, 62)}, Enum.EasingStyle.Quad)
                    library:tween(items["toggle_circle"], {BackgroundColor3 = bool and rgb(255, 255, 255) or rgb(86, 86, 88), Position = bool and dim2(1, -15, 0, 2) or dim2(0, 2, 0, 2)}, Enum.EasingStyle.Quad)
                    library:tween(items["fade"], {BackgroundTransparency = bool and 1 or 0.8}, Enum.EasingStyle.Quad)
                end 
            end 

            -- Direct aliases on cfg object
            cfg.toggle = function(self, ...) return library.toggle(self, ...) end
            cfg.Toggle = cfg.toggle
            cfg.CreateToggle = cfg.toggle

            cfg.slider = function(self, ...) return library.slider(self, ...) end
            cfg.Slider = cfg.slider
            cfg.CreateSlider = cfg.slider

            cfg.dropdown = function(self, ...) return library.dropdown(self, ...) end
            cfg.Dropdown = cfg.dropdown
            cfg.CreateDropdown = cfg.dropdown

            cfg.colorpicker = function(self, ...) return library.colorpicker(self, ...) end
            cfg.Colorpicker = cfg.colorpicker
            cfg.CreateColorpicker = cfg.colorpicker

            cfg.keybind = function(self, ...) return library.keybind(self, ...) end
            cfg.Keybind = cfg.keybind
            cfg.CreateKeybind = cfg.keybind

            cfg.textbox = function(self, ...) return library.textbox(self, ...) end
            cfg.Textbox = cfg.textbox
            cfg.CreateTextbox = cfg.textbox

            cfg.button = function(self, ...) return library.button(self, ...) end
            cfg.Button = cfg.button
            cfg.CreateButton = cfg.button

            cfg.label = function(self, ...) return library.label(self, ...) end
            cfg.Label = cfg.label

            return setmetatable(cfg, library)
        end  

        function library:toggle(options) 
            local cfg = {
                enabled = options.enabled or nil,
                name = options.name or "Toggle",
                info = options.info or nil,
                flag = options.flag or library:next_flag(),
                type = options.type and string.lower(options.type) or "toggle",
                default = options.default or false,
                callback = options.callback or function() end,
                items = {};
                seperator = options.seperator or false;
            }

            flags[cfg.flag] = cfg.default

            local items = cfg.items; do
                items["toggle"] = library:create("TextButton", {
                    FontFace = fonts.small;
                    TextColor3 = rgb(0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    Parent = self.items["elements"];
                    Name = "Toggle";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                items["name"] = library:create("TextLabel", {
                    FontFace = fonts.small;
                    TextColor3 = rgb(245, 245, 245);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = cfg.name;
                    Parent = items["toggle"];
                    Name = "Label";
                    Size = dim2(1, 0, 0, 0);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 14;
                    BackgroundColor3 = rgb(255, 255, 255)
                });

                if cfg.info then 
                    items["info"] = library:create("TextLabel", {
                        FontFace = fonts.small;
                        TextColor3 = rgb(130, 130, 130);
                        BorderColor3 = rgb(0, 0, 0);
                        TextWrapped = true;
                        Text = cfg.info;
                        Parent = items["toggle"];
                        Name = "Info";
                        Position = dim2(0, 5, 0, 17);
                        Size = dim2(1, -10, 0, 0);
                        BackgroundTransparency = 1;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.XY;
                        TextSize = 12;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                end 
                
                items["right_components"] = library:create("Frame", {
                    Parent = items["toggle"];
                    Name = "RightComponents";
                    Position = dim2(1, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 0, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalAlignment = Enum.HorizontalAlignment.Right;
                    Parent = items["right_components"];
                    Padding = dim(0, 9);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
                
                if cfg.type == "checkbox" then 
                    items["toggle_button"] = library:create("TextButton", {
                        FontFace = fonts.small;
                        TextColor3 = rgb(0, 0, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "";
                        LayoutOrder = 2;
                        AutoButtonColor = false;
                        AnchorPoint = vec2(1, 0);
                        Parent = items["right_components"];
                        Name = "Checkbox";
                        Position = dim2(1, 0, 0, 0);
                        Size = dim2(0, 16, 0, 16);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(67, 67, 68)
                    }); library:apply_theme(items["toggle_button"], "accent", "BackgroundColor3");
                    
                    library:create("UICorner", {
                        Parent = items["toggle_button"];
                        CornerRadius = dim(0, 4)
                    });
                    
                    items["outline"] = library:create("Frame", {
                        Parent = items["toggle_button"];
                        Size = dim2(1, -2, 1, -2);
                        Name = "BoxOutline";
                        BorderColor3 = rgb(0, 0, 0);
                        Position = dim2(0, 1, 0, 1);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(22, 22, 24)
                    });
                    
                    items["tick"] = library:create("ImageLabel", {
                        ImageTransparency = 1;
                        BorderColor3 = rgb(0, 0, 0);
                        Image = "rbxassetid://111862698467575";
                        BackgroundTransparency = 1;
                        Position = dim2(0, -1, 0, 0);
                        Parent = items["outline"];
                        Size = dim2(1, 2, 1, 2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255);
                        ZIndex = 1;
                    });

                    library:create("UICorner", {
                        Parent = items["outline"];
                        CornerRadius = dim(0, 4)
                    });
                else 
                    items["toggle_button"] = library:create("TextButton", {
                        FontFace = fonts.font;
                        TextColor3 = rgb(0, 0, 0);
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "";
                        LayoutOrder = 2;
                        AnchorPoint = vec2(1, 0.5);
                        Parent = items["right_components"];
                        Name = "Switch";
                        Position = dim2(1, -9, 0.5, 0);
                        Size = dim2(0, 36, 0, 18);
                        BorderSizePixel = 0;
                        BackgroundColor3 = themes.preset.accent
                    }); library:apply_theme(items["toggle_button"], "accent", "BackgroundColor3");
                    
                    library:create("UICorner", {
                        Parent = items["toggle_button"];
                        CornerRadius = dim(0, 999)
                    });
                    
                    items["inline"] = library:create("Frame", {
                        Parent = items["toggle_button"];
                        Size = dim2(1, -2, 1, -2);
                        Name = "SwitchInline";
                        BorderColor3 = rgb(0, 0, 0);
                        Position = dim2(0, 1, 0, 1);
                        BorderSizePixel = 0;
                        BackgroundColor3 = themes.preset.accent
                    }); library:apply_theme(items["inline"], "accent", "BackgroundColor3");
                    
                    library:create("UICorner", {
                        Parent = items["inline"];
                        CornerRadius = dim(0, 999)
                    });
                    
                    items["circle"] = library:create("Frame", {
                        Parent = items["inline"];
                        Name = "Circle";
                        Position = dim2(1, -14, 0, 2);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 12, 0, 12);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });
                    
                    library:create("UICorner", {
                        Parent = items["circle"];
                        CornerRadius = dim(0, 999)
                    });                        
                end 
            end;
            
            function cfg.set(bool)
                if cfg.type == "checkbox" then 
                    library:tween(items["tick"], {Rotation = bool and 0 or 45, ImageTransparency = bool and 0 or 1})
                    library:tween(items["toggle_button"], {BackgroundColor3 = bool and themes.preset.accent or rgb(67, 67, 68)})
                    library:tween(items["outline"], {BackgroundColor3 = bool and themes.preset.accent or rgb(22, 22, 24)})
                else
                    library:tween(items["toggle_button"], {BackgroundColor3 = bool and themes.preset.accent or rgb(58, 58, 62)}, Enum.EasingStyle.Quad)
                    library:tween(items["inline"], {BackgroundColor3 = bool and themes.preset.accent or rgb(50, 50, 50)}, Enum.EasingStyle.Quad)
                    library:tween(items["circle"], {BackgroundColor3 = bool and rgb(255, 255, 255) or rgb(86, 86, 88), Position = bool and dim2(1, -14, 0, 2) or dim2(0, 2, 0, 2)}, Enum.EasingStyle.Quad)
                end

                flags[cfg.flag] = bool
                cfg.callback(bool)
            end 
            
            items["toggle"].MouseButton1Click:Connect(function()
                cfg.enabled = not cfg.enabled 
                cfg.set(cfg.enabled)
            end)

            items["toggle_button"].MouseButton1Click:Connect(function()
                cfg.enabled = not cfg.enabled 
                cfg.set(cfg.enabled)
            end)
            
            cfg.set(cfg.default)
            config_flags[cfg.flag] = cfg.set

            return setmetatable(cfg, library)
        end 
        
        function library:slider(options) 
            local cfg = {
                name = options.name or "Slider",
                suffix = options.suffix or "",
                flag = options.flag or library:next_flag(),
                callback = options.callback or function() end, 
                info = options.info or nil; 
                min = options.min or options.minimum or 0,
                max = options.max or options.maximum or 100,
                intervals = options.interval or options.decimal or 1,
                default = options.default or 10,
                value = options.default or 10, 
                dragging = false,
                items = {}
            } 

            flags[cfg.flag] = cfg.default

            local items = cfg.items; do
                items["slider_object"] = library:create("TextButton", {
                    FontFace = fonts.small;
                    TextColor3 = rgb(0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    Parent = self.items["elements"];
                    Name = "Slider";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                items["name"] = library:create("TextLabel", {
                    FontFace = fonts.small;
                    TextColor3 = rgb(245, 245, 245);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = cfg.name;
                    Parent = items["slider_object"];
                    Name = "Title";
                    Size = dim2(1, 0, 0, 0);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 14;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                items["right_components"] = library:create("Frame", {
                    Parent = items["slider_object"];
                    Name = "SliderTrackHolder";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 4, 0, 23);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, 0, 0, 12);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                items["slider"] = library:create("TextButton", {
                    FontFace = fonts.small;
                    TextColor3 = rgb(0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    AutoButtonColor = false;
                    AnchorPoint = vec2(1, 0);
                    Parent = items["right_components"];
                    Name = "Track";
                    Position = dim2(1, 0, 0, 0);
                    Size = dim2(1, -4, 0, 4);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(33, 33, 35)
                });
                
                library:create("UICorner", {
                    Parent = items["slider"];
                    CornerRadius = dim(0, 999)
                });
                
                items["fill"] = library:create("Frame", {
                    Name = "Fill";
                    Parent = items["slider"];
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0.5, 0, 0, 4);
                    BorderSizePixel = 0;
                    BackgroundColor3 = themes.preset.accent
                }); library:apply_theme(items["fill"], "accent", "BackgroundColor3");
                
                library:create("UICorner", {
                    Parent = items["fill"];
                    CornerRadius = dim(0, 999)
                });
                
                items["circle"] = library:create("Frame", {
                    AnchorPoint = vec2(0.5, 0.5);
                    Parent = items["fill"];
                    Name = "Knob";
                    Position = dim2(1, 0, 0.5, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 12, 0, 12);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(244, 244, 244)
                });
                
                library:create("UICorner", {
                    Parent = items["circle"];
                    CornerRadius = dim(0, 999)
                });
                
                items["value"] = library:create("TextLabel", {
                    FontFace = fonts.small;
                    TextColor3 = rgb(72, 72, 73);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "50%";
                    Parent = items["slider_object"];
                    Name = "ValLabel";
                    Size = dim2(1, 0, 0, 0);
                    Position = dim2(0, 6, 0, 0);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Right;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 14;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
            end 

            function cfg.set(value)
                cfg.value = clamp(library:round(value, cfg.intervals), cfg.min, cfg.max)
                local ratio = (cfg.value - cfg.min) / (cfg.max - cfg.min)

                library:tween(items["fill"], {Size = dim2(ratio, cfg.value == cfg.min and 0 or -4, 0, 4)}, Enum.EasingStyle.Linear, 0.05)
                items["value"].Text = tostring(cfg.value) .. cfg.suffix

                flags[cfg.flag] = cfg.value
                cfg.callback(flags[cfg.flag])
            end

            items["slider"].MouseButton1Down:Connect(function()
                cfg.dragging = true 
                library:tween(items["value"], {TextColor3 = rgb(255, 255, 255)}, Enum.EasingStyle.Quad, 0.2)
            end)

            library:connection(uis.InputChanged, function(input)
                if cfg.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then 
                    local size_x = (input.Position.X - items["slider"].AbsolutePosition.X) / items["slider"].AbsoluteSize.X
                    local value = ((cfg.max - cfg.min) * size_x) + cfg.min
                    cfg.set(value)
                end
            end)

            library:connection(uis.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    cfg.dragging = false
                    library:tween(items["value"], {TextColor3 = rgb(72, 72, 73)}, Enum.EasingStyle.Quad, 0.2) 
                end 
            end)

            cfg.set(cfg.default)
            config_flags[cfg.flag] = cfg.set

            return setmetatable(cfg, library)
        end 

        function library:dropdown(options) 
            local cfg = {
                name = options.name or "Dropdown";
                flag = options.flag or library:next_flag();
                options = options.items or options.options or {"Option 1", "Option 2"};
                callback = options.callback or function() end;
                multi = options.multi or false;
                width = options.width or 130;
                open = false;
                option_instances = {};
                multi_items = {};
                items = {};
                y_size = 0;
            }   

            cfg.default = options.default or (cfg.multi and {cfg.options[1]}) or cfg.options[1] or "None"
            flags[cfg.flag] = cfg.default

            local items = cfg.items; do 
                items["dropdown_object"] = library:create("TextButton", {
                    FontFace = fonts.small;
                    TextColor3 = rgb(0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    Parent = self.items["elements"];
                    Name = "Dropdown";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                items["name"] = library:create("TextLabel", {
                    FontFace = fonts.small;
                    TextColor3 = rgb(245, 245, 245);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = cfg.name;
                    Parent = items["dropdown_object"];
                    Name = "Title";
                    Size = dim2(1, 0, 0, 0);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 14;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                items["right_components"] = library:create("Frame", {
                    Parent = items["dropdown_object"];
                    Name = "RightComponents";
                    Position = dim2(1, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 0, 1, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                items["dropdown"] = library:create("TextButton", {
                    FontFace = fonts.small;
                    TextColor3 = rgb(0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "";
                    AutoButtonColor = false;
                    AnchorPoint = vec2(1, 0);
                    Parent = items["right_components"];
                    Name = "Box";
                    Position = dim2(1, 0, 0, 0);
                    Size = dim2(0, cfg.width, 0, 18);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(33, 33, 35)
                });
                
                library:create("UICorner", {
                    Parent = items["dropdown"];
                    CornerRadius = dim(0, 4)
                });
                
                items["sub_text"] = library:create("TextLabel", {
                    FontFace = fonts.small;
                    TextColor3 = rgb(86, 86, 87);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "None";
                    Parent = items["dropdown"];
                    Name = "SelectedText";
                    Size = dim2(1, -16, 0, 0);
                    BorderSizePixel = 0;
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextTruncate = Enum.TextTruncate.AtEnd;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                library:create("UIPadding", {
                    Parent = items["sub_text"];
                    PaddingLeft = dim(0, 6);
                    PaddingTop = dim(0, 2)
                });
                
                items["indicator"] = library:create("ImageLabel", {
                    ImageColor3 = rgb(86, 86, 87);
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = items["dropdown"];
                    AnchorPoint = vec2(1, 0.5);
                    Image = "rbxassetid://101025591575185";
                    BackgroundTransparency = 1;
                    Position = dim2(1, -5, 0.5, 0);
                    Name = "Arrow";
                    Size = dim2(0, 12, 0, 12);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });

                -- Popout Menu
                items["dropdown_holder"] = library:create("Frame", {
                    BorderColor3 = rgb(0, 0, 0);
                    Parent = library["items"];
                    Name = "DropdownPopout";
                    Visible = false;
                    BackgroundTransparency = 1;
                    Size = dim2(0, cfg.width, 0, 0);
                    BorderSizePixel = 0;
                    ZIndex = 20;
                });
                
                items["outline"] = library:create("Frame", {
                    Parent = items["dropdown_holder"];
                    Size = dim2(1, 0, 1, 0);
                    ClipsDescendants = true;
                    BorderColor3 = rgb(0, 0, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(33, 33, 35);
                    ZIndex = 20;
                });
                
                library:create("UIPadding", {
                    PaddingBottom = dim(0, 6);
                    PaddingTop = dim(0, 4);
                    PaddingLeft = dim(0, 4);
                    Parent = items["outline"]
                });
                
                library:create("UIListLayout", {
                    Parent = items["outline"];
                    Padding = dim(0, 4);
                    SortOrder = Enum.SortOrder.LayoutOrder
                });
                
                library:create("UICorner", {
                    Parent = items["outline"];
                    CornerRadius = dim(0, 4)
                });
            end 

            function cfg.render_option(text)
                local button = library:create("TextButton", {
                    FontFace = fonts.small;
                    TextColor3 = rgb(72, 72, 73);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = text;
                    Parent = items["outline"];
                    Name = "Option_" .. text;
                    Size = dim2(1, -8, 0, 18);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    TextSize = 13;
                    BackgroundColor3 = rgb(255, 255, 255);
                    ZIndex = 21;
                });
                
                library:create("UIPadding", {
                    Parent = button;
                    PaddingLeft = dim(0, 6)
                });
                
                return button
            end
            
            function cfg.set_visible(bool)
                local targetHeight = bool and cfg.y_size or 0
                items["dropdown_holder"].Visible = bool or (targetHeight > 0)
                library:tween(items["dropdown_holder"], {Size = dim_offset(cfg.width, targetHeight)})
                items["dropdown_holder"].Position = dim2(0, items["dropdown"].AbsolutePosition.X, 0, items["dropdown"].AbsolutePosition.Y + 22)
            end
            
            function cfg.set(value)
                local selected = {}
                local isTable = type(value) == "table"

                for _, option in ipairs(cfg.option_instances) do 
                    if option.Text == value or (isTable and find(value, option.Text)) then 
                        insert(selected, option.Text)
                        option.TextColor3 = themes.preset.accent
                    else
                        option.TextColor3 = rgb(72, 72, 73)
                    end
                end

                items["sub_text"].Text = isTable and concat(selected, ", ") or selected[1] or ""
                flags[cfg.flag] = isTable and selected or selected[1]
                cfg.callback(flags[cfg.flag]) 
            end
            
            function cfg.refresh_options(list) 
                cfg.y_size = 0
                for _, option in ipairs(cfg.option_instances) do 
                    option:Destroy() 
                end
                cfg.option_instances = {} 

                for _, option in ipairs(list) do 
                    local button = cfg.render_option(option)
                    cfg.y_size = cfg.y_size + 22
                    insert(cfg.option_instances, button)
                    
                    button.MouseButton1Down:Connect(function()
                        if cfg.multi then 
                            local selected_index = find(cfg.multi_items, button.Text)
                            if selected_index then 
                                remove(cfg.multi_items, selected_index)
                            else
                                insert(cfg.multi_items, button.Text)
                            end
                            cfg.set(cfg.multi_items) 				
                        else 
                            cfg.set_visible(false)
                            cfg.open = false 
                            cfg.set(button.Text)
                        end
                    end)
                end
            end

            items["dropdown"].MouseButton1Click:Connect(function()
                cfg.open = not cfg.open 
                cfg.set_visible(cfg.open)
            end)

            cfg.refresh_options(cfg.options)
            cfg.set(cfg.default)
            config_flags[cfg.flag] = cfg.set

            return setmetatable(cfg, library)
        end

        function library:button(options) 
            local cfg = {
                name = options.name or "Button",
                callback = options.callback or function() end,
                items = {};
            }
            
            local items = cfg.items; do 
                items["button"] = library:create("TextButton", {
                    FontFace = fonts.font;
                    TextColor3 = rgb(245, 245, 245);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = cfg.name;
                    AutoButtonColor = false;
                    Parent = self.items["elements"];
                    Name = "Button";
                    Size = dim2(1, 0, 0, 30);
                    BorderSizePixel = 0;
                    TextSize = 14;
                    BackgroundColor3 = rgb(33, 33, 35)
                });
                
                library:create("UICorner", {
                    Parent = items["button"];
                    CornerRadius = dim(0, 4)
                });
            end 

            items["button"].MouseButton1Click:Connect(function()
                cfg.callback()
                items["button"].TextColor3 = themes.preset.accent 
                library:tween(items["button"], {TextColor3 = rgb(245, 245, 245)})
            end)
            
            return setmetatable(cfg, library)
        end 

        function library:textbox(options) 
            local cfg = {
                name = options.name or "TextBox",
                placeholder = options.placeholder or options.placeholdertext or "type here...",
                default = options.default or "",
                flag = options.flag or library:next_flag(),
                callback = options.callback or function() end,
                items = {};
            }

            flags[cfg.flag] = cfg.default

            local items = cfg.items; do 
                items["textbox"] = library:create("Frame", {
                    Parent = self.items["elements"];
                    Name = "TextBoxHolder";
                    BackgroundTransparency = 1;
                    Size = dim2(1, 0, 0, 48);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                items["name"] = library:create("TextLabel", {
                    FontFace = fonts.font;
                    TextColor3 = rgb(245, 245, 245);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = cfg.name;
                    Parent = items["textbox"];
                    Name = "Title";
                    Size = dim2(1, 0, 0, 16);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    TextSize = 14;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
                
                items["input"] = library:create("TextBox", {
                    FontFace = fonts.font;
                    Text = cfg.default;
                    PlaceholderText = cfg.placeholder;
                    Parent = items["textbox"];
                    Name = "Input";
                    TextTruncate = Enum.TextTruncate.AtEnd;
                    BorderSizePixel = 0;
                    PlaceholderColor3 = rgb(90, 90, 95);
                    ClearTextOnFocus = false;
                    TextSize = 13;
                    TextColor3 = rgb(220, 220, 225);
                    Position = dim2(0, 0, 0, 20);
                    Size = dim2(1, 0, 0, 26);
                    BackgroundColor3 = rgb(33, 33, 35)
                }); 

                library:create("UICorner", {
                    Parent = items["input"];
                    CornerRadius = dim(0, 4)
                });                
                
                library:create("UIPadding", {
                    Parent = items["input"];
                    PaddingLeft = dim(0, 8);
                    PaddingRight = dim(0, 8)
                });
            end 
            
            function cfg.set(text) 
                flags[cfg.flag] = text
                items["input"].Text = text
                cfg.callback(text)
            end 
            
            items["input"]:GetPropertyChangedSignal("Text"):Connect(function()
                cfg.set(items["input"].Text) 
            end)

            return setmetatable(cfg, library)
        end

        function library:label(options)
            local cfg = {
                name = options.name or "Label",
                items = {};
            }

            local items = cfg.items; do 
                items["label"] = library:create("TextLabel", {
                    FontFace = fonts.small;
                    TextColor3 = rgb(200, 200, 205);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = cfg.name;
                    Parent = self.items["elements"];
                    Name = "Label";
                    Size = dim2(1, 0, 0, 20);
                    BackgroundTransparency = 1;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    BorderSizePixel = 0;
                    TextSize = 14;
                    BackgroundColor3 = rgb(255, 255, 255)
                });
            end 

            return setmetatable(cfg, library)
        end 

        function library:colorpicker(options) 
            local cfg = {
                name = options.name or "Color", 
                flag = options.flag or library:next_flag(),
                color = options.color or rgb(155, 150, 219),
                callback = options.callback or function() end,
                items = {};
            }

            flags[cfg.flag] = cfg.color

            local items = cfg.items; do 
                items["holder"] = library:create("Frame", {
                    Parent = self.items["elements"],
                    Size = dim2(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                })
                
                items["name"] = library:create("TextLabel", {
                    Parent = items["holder"],
                    Text = cfg.name,
                    TextColor3 = rgb(240, 240, 245),
                    FontFace = fonts.small,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = dim2(1, -30, 1, 0),
                    BackgroundTransparency = 1,
                })

                items["preview"] = library:create("TextButton", {
                    Parent = items["holder"],
                    AnchorPoint = vec2(1, 0.5),
                    Position = dim2(1, 0, 0.5, 0),
                    Size = dim2(0, 22, 0, 16),
                    BackgroundColor3 = cfg.color,
                    BorderSizePixel = 0,
                    Text = "",
                })

                library:create("UICorner", {
                    Parent = items["preview"],
                    CornerRadius = dim(0, 4)
                })
            end

            function cfg.set(newCol)
                cfg.color = newCol
                items["preview"].BackgroundColor3 = newCol
                flags[cfg.flag] = newCol
                cfg.callback(newCol)
            end

            return setmetatable(cfg, library)
        end
    --

    -- Notification system
        function notifications:create_notification(options)
            local cfg = {
                name = options.name or "Notification";
                info = options.info or "";
                lifetime = options.lifetime or 3;
                items = {};
            }

            local parentGui = library["items"] or get_safe_parent()

            local notif = library:create("Frame", {
                Parent = parentGui;
                Size = dim2(0, 240, 0, 56);
                Name = "NotifItem";
                BorderColor3 = rgb(0, 0, 0);
                BorderSizePixel = 0;
                AnchorPoint = vec2(0, 0);
                Position = dim2(0, -260, 0, 50);
                BackgroundColor3 = rgb(14, 14, 16)
            });
            
            library:create("UIStroke", {
                Color = rgb(23, 23, 29);
                Parent = notif;
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            });
            
            library:create("UICorner", {
                Parent = notif;
                CornerRadius = dim(0, 6)
            });

            local title = library:create("TextLabel", {
                FontFace = fonts.font;
                TextColor3 = rgb(255, 255, 255);
                Text = cfg.name;
                Parent = notif;
                Position = dim2(0, 10, 0, 8);
                Size = dim2(1, -20, 0, 16);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                TextSize = 13;
            });
            
            local info = library:create("TextLabel", {
                FontFace = fonts.small;
                TextColor3 = rgb(145, 145, 145);
                Text = cfg.info;
                Parent = notif;
                Position = dim2(0, 10, 0, 26);
                Size = dim2(1, -20, 0, 16);
                BackgroundTransparency = 1;
                TextXAlignment = Enum.TextXAlignment.Left;
                BorderSizePixel = 0;
                TextSize = 12;
            });

            local bar = library:create("Frame", {
                Parent = notif;
                AnchorPoint = vec2(0, 1);
                Position = dim2(0, 8, 1, -5);
                Size = dim2(1, -16, 0, 3);
                BorderSizePixel = 0;
                BackgroundColor3 = themes.preset.accent
            });
            library:create("UICorner", {
                Parent = bar;
                CornerRadius = dim(0, 999)
            });

            -- Slide in
            library:tween(notif, {Position = dim2(0, 20, 0, 50)}, Enum.EasingStyle.Back, 0.45)
            library:tween(bar, {Size = dim2(0, 0, 0, 3)}, Enum.EasingStyle.Linear, cfg.lifetime)

            task.delay(cfg.lifetime, function()
                if notif and notif.Parent then
                    library:tween(notif, {Position = dim2(0, -280, 0, 50)}, Enum.EasingStyle.Quad, 0.4).Completed:Connect(function()
                        notif:Destroy()
                    end)
                end
            end)
        end
    --

    -- Forward & Backward aliases for 100% Rayfield/WindUI/Xezios/Milenium compatibility
    library.Window = library.window
    library.CreateWindow = library.window
    library.Tab = library.tab
    library.CreateTab = library.tab
    library.Section = library.section
    library.CreateSection = library.section
    library.Toggle = library.toggle
    library.CreateToggle = library.toggle
    library.Slider = library.slider
    library.CreateSlider = library.slider
    library.Dropdown = library.dropdown
    library.CreateDropdown = library.dropdown
    library.Button = library.button
    library.CreateButton = library.button
    library.Textbox = library.textbox
    library.CreateTextbox = library.textbox
    library.Loader = library.loader
    library.ShowLoader = library.loader
    library.Notify = function(self, opts)
        if type(opts) == "string" then opts = {name = opts} end
        notifications:create_notification(opts)
    end
    library.SendNotification = library.Notify
    library.Notification = library.Notify

return library
