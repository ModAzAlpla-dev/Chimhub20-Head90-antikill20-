--======================================================================================--
--    CHIM HUB | GARDEN AUTO-FARM (PRO VERSION - ANTI SPAM)                             --
--======================================================================================--
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 150, 0, 100)
Frame.Position = UDim2.new(0.5, -75, 0.5, -50)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(0.8, 0, 0.6, 0)
Toggle.Position = UDim2.new(0.1, 0, 0.2, 0)
Toggle.Text = "AUTO: OFF"
Toggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

_G.Auto = false
Toggle.MouseButton1Click:Connect(function()
    _G.Auto = not _G.Auto
    Toggle.Text = _G.Auto and "AUTO: ON" or "AUTO: OFF"
    Toggle.BackgroundColor3 = _G.Auto and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(200, 0, 0)
    
    if _G.Auto then
        task.spawn(function()
            while _G.Auto do
                for _, v in pairs(workspace:GetDescendants()) do
                    -- CHỈ NHẶT CÂY (LỌC THEO TÊN), KHÔNG SPAM CÁI KHÁC
                    if v:IsA("ProximityPrompt") and (string.find(v.Parent.Name, "Plant") or string.find(v.Parent.Name, "Crop") or string.find(v.Parent.Name, "Harvest")) then
                        fireproximityprompt(v)
                    end
                end
                task.wait(0.5) -- Delay an toàn, không bị spam lỗi
            end
        end)
    end
end)









--======================================================================================--
--    CHIM HUB | ESCAPE RUNNING HEAD - FULL OPTION (FIX LỖI KẸT NOCLIP)                 --
--======================================================================================--
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local tweenService = game:GetService("TweenService")

-- Thông số gốc để khôi phục khi tắt tính năng
local origAmbient = lighting.Ambient
local origOutdoorAmbient = lighting.OutdoorAmbient
local origBrightness = lighting.Brightness
local origClockTime = lighting.ClockTime
local origFogEnd = lighting.FogEnd
local origFogStart = lighting.FogStart
local origShadows = lighting.GlobalShadows

local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "ChimGui"
screenGui.ResetOnSpawn = false 

-- [UI Setup]
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 160, 0, 220)
mainFrame.Position = UDim2.new(0.5, -80, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); mainFrame.Draggable = true; mainFrame.Active = true
mainFrame.ClipsDescendants = true 
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Tiêu đề trang
local pageTitle = Instance.new("TextLabel", mainFrame)
pageTitle.Size = UDim2.new(0, 100, 0, 25); pageTitle.Position = UDim2.new(0, 10, 0, 5)
pageTitle.Text = "PAGE 1/2"; pageTitle.TextColor3 = Color3.fromRGB(255, 255, 255); pageTitle.BackgroundTransparency = 1
pageTitle.Font = Enum.Font.GothamBold; pageTitle.TextSize = 12
pageTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Nút thu nhỏ menu và Logo
local minBtn = Instance.new("TextButton", mainFrame)
minBtn.Size = UDim2.new(0, 30, 0, 20); minBtn.Position = UDim2.new(1, -35, 0, 5); minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100); minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Font = Enum.Font.GothamBold; minBtn.TextSize = 14
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

local logoBtn = Instance.new("TextButton", screenGui)
logoBtn.Size = UDim2.new(0, 70, 0, 70); logoBtn.Position = UDim2.new(0, 20, 0, 20); logoBtn.Text = "ChimBeo"
logoBtn.TextColor3 = Color3.new(1, 1, 1); logoBtn.Font = Enum.Font.GothamBold; logoBtn.TextSize = 14
logoBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 120); logoBtn.Visible = false
Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(1, 0)
local uiStroke = Instance.new("UIStroke", logoBtn); uiStroke.Color = Color3.fromRGB(200, 100, 255); uiStroke.Thickness = 4

minBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false; logoBtn.Visible = true end)
logoBtn.MouseButton1Click:Connect(function() mainFrame.Visible = true; logoBtn.Visible = false end)

-- Hàm tạo nút tính năng
local function createBtn(name, pos, startOut) 
    local btn = Instance.new("TextButton", mainFrame); btn.Size = UDim2.new(0, 140, 0, 40)
    btn.Position = startOut and UDim2.new(1.5, 0, 0, pos) or UDim2.new(0, 10, 0, pos)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn 
end

-- Khởi tạo các nút tính năng
local antiBtn = createBtn("Anti-Kill", 35, false)
local espBtn = createBtn("ESP", 80, false)
local noclipBtn = createBtn("Noclip", 125, false)

local cpBtn = createBtn("ESP Checkpoint", 35, true); cpBtn.Visible = false
local fbBtn = createBtn("Fullbright", 80, true); fbBtn.Visible = false
local morningBtn = createBtn("Morning", 125, true); morningBtn.Visible = false

-- Hàm Animation trượt mượt mà
local function animateBtn(btn, show, direction)
    btn.Visible = true
    local targetPos
    if show then
        targetPos = UDim2.new(0, 10, 0, btn.Position.Y.Offset)
    else
        targetPos = direction == "left" and UDim2.new(-1.5, 0, 0, btn.Position.Y.Offset) or UDim2.new(1.5, 0, 0, btn.Position.Y.Offset)
    end
    
    local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = tweenService:Create(btn, tweenInfo, {Position = targetPos})
    tween:Play()
    
    if not show then
        tween.Completed:Connect(function()
            if btn.Position.X.Scale ~= 0 then btn.Visible = false end
        end)
    end
end

-- Logic Toggle chung
local function toggle(btn, state, name) 
    state = not state; btn.Text = name .. (state and ": ON" or ": OFF")
    btn.BackgroundColor3 = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50); return state 
end

-- [Nút chuyển trang]
local changePageBtn = Instance.new("TextButton", mainFrame)
changePageBtn.Size = UDim2.new(0, 140, 0, 30); changePageBtn.Position = UDim2.new(0, 10, 0, 175)
changePageBtn.Text = "NEXT PAGE ->"; changePageBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); changePageBtn.TextColor3 = Color3.new(1, 1, 1)
changePageBtn.Font = Enum.Font.GothamBold; changePageBtn.TextSize = 11
Instance.new("UICorner", changePageBtn).CornerRadius = UDim.new(0, 6)

local currentPage = 1
changePageBtn.MouseButton1Click:Connect(function()
    if currentPage == 1 then
        currentPage = 2; pageTitle.Text = "PAGE 2/2"; changePageBtn.Text = "<- BACK PAGE"
        animateBtn(antiBtn, false, "left"); animateBtn(espBtn, false, "left"); animateBtn(noclipBtn, false, "left")
        animateBtn(cpBtn, true); animateBtn(fbBtn, true); animateBtn(morningBtn, true)
    else
        currentPage = 1; pageTitle.Text = "PAGE 1/2"; changePageBtn.Text = "NEXT PAGE ->"
        animateBtn(cpBtn, false, "right"); animateBtn(fbBtn, false, "right"); animateBtn(morningBtn, false, "right")
        animateBtn(antiBtn, true); animateBtn(espBtn, true); animateBtn(noclipBtn, true)
    end
end)

-- Bấm nút tính năng
local active, espActive, noclipActive, cpActive, fbActive, morningActive = false, false, false, false, false, false
antiBtn.MouseButton1Click:Connect(function() active = toggle(antiBtn, active, "Anti-Kill") end)
espBtn.MouseButton1Click:Connect(function() espActive = toggle(espBtn, espActive, "ESP") end)
noclipBtn.MouseButton1Click:Connect(function() noclipActive = toggle(noclipBtn, noclipActive, "Noclip") end)
cpBtn.MouseButton1Click:Connect(function() cpActive = toggle(cpBtn, cpActive, "ESP Checkpoint") end)
fbBtn.MouseButton1Click:Connect(function() fbActive = toggle(fbBtn, fbActive, "Fullbright") end)

-- Xử lý hiệu ứng Morning
local sunRays = Instance.new("SunRaysEffect")
sunRays.Intensity = 0.25; sunRays.Spread = 1; sunRays.Enabled = false; sunRays.Parent = lighting

morningBtn.MouseButton1Click:Connect(function()
    morningActive = toggle(morningBtn, morningActive, "Morning")
    if morningActive then
        if fbActive then fbActive = toggle(fbBtn, false, "Fullbright") end
        lighting.ClockTime = 6.5; lighting.Brightness = 3.5
        lighting.Ambient = Color3.fromRGB(140, 110, 100); lighting.OutdoorAmbient = Color3.fromRGB(220, 180, 140)
        lighting.GlobalShadows = true; sunRays.Enabled = true
    else
        lighting.ClockTime = origClockTime; lighting.Brightness = origBrightness
        lighting.Ambient = origAmbient; lighting.OutdoorAmbient = origOutdoorAmbient
        lighting.GlobalShadows = origShadows; sunRays.Enabled = false
    end
end)

-- Vòng lặp chính quản lý Noclip, ESP và Fullbright cố định
runService.Stepped:Connect(function()
    if fbActive then
        if morningActive then morningActive = toggle(morningBtn, false, "Morning") end
        lighting.Ambient = Color3.fromRGB(255, 255, 255); lighting.Brightness = 10; lighting.GlobalShadows = false
    elseif not morningActive then
        lighting.Ambient = origAmbient; lighting.Brightness = origBrightness; lighting.GlobalShadows = origShadows
    end
    
    -- Xử lý Noclip hoàn hảo (Bật thì xuyên, Tắt thì trả lại va chạm chuẩn)
    local char = player.Character
    if char then 
        for _, p in pairs(char:GetDescendants()) do 
            if p:IsA("BasePart") then 
                if noclipActive then
                    p.CanCollide = false 
                else
                    -- Trả lại va chạm chuẩn cho các bộ phận chính khi OFF Noclip
                    if p.Name == "UpperTorso" or p.Name == "LowerTorso" or p.Name == "Head" or p.Name == "HumanoidRootPart" or p.Name:find("Leg") or p.Name:find("Arm") then
                        p.CanCollide = true
                    end
                end
            end 
        end 
    end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and (v.Name:lower():find("felipe") or v.Name:lower():find("head")) then
            for _, p in pairs(v:GetDescendants()) do if p:IsA("BasePart") then p.CanTouch = not active end end
            if espActive and not v:FindFirstChild("MonsterESP") then 
                local h = Instance.new("Highlight", v); h.Name = "MonsterESP"; h.FillColor = Color3.fromRGB(255, 0, 255) 
            end
        end
        if cpActive and v:IsA("BasePart") and (v.Name:lower():find("checkpoint") or v.Name:lower():find("spawn")) then
            if not v:FindFirstChild("CPEsp") then local h = Instance.new("Highlight", v); h.Name = "CPEsp"; h.FillColor = Color3.fromRGB(0, 255, 0) end
        end
    end
end)
