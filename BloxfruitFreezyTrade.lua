--[[
    Chinoks Trade Script for Blox Fruits
    
    Features:
    - Modern premium-styled UI with red gradient
    - Toggle functionality with status indicator
    - Smooth drag and drop with inertia
    - Rainbow credit text effect
    - Warning popup system
    - Enhanced UI effects (shadows, blur, glow)
    - Cross-executor compatibility
]]

-- Configuration
local Config = {
    Title = "Chinoks",
    Subtitle = "Trade Script",
    Version = "v1.3.7",
    Credits = "Chinoks Team",
    ToggleKey = Enum.KeyCode.RightControl,
    CloseKey = Enum.KeyCode.Delete,
    UIScale = 0.7, -- Size multiplier
}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ToggleActive = false
local Dragging = false
local DragInput
local DragStart
local StartPos
local DragInertia = Vector2.new(0, 0)
local LastMousePos = Vector2.new(0, 0)

-- Helper Functions
local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function CreateTween(instance, info, properties)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

-- Create UI Container (attempts CoreGui first, falls back to PlayerGui)
local GUI
local success = pcall(function()
    if syn and syn.protect_gui then
        GUI = Instance.new("ScreenGui")
        syn.protect_gui(GUI)
        GUI.Parent = CoreGui
    elseif gethui then
        GUI = Instance.new("ScreenGui")
        GUI.Parent = gethui()
    elseif hookfunction then
        GUI = Instance.new("ScreenGui")
        GUI.Parent = CoreGui
    else
        GUI = Instance.new("ScreenGui")
        GUI.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end)

if not success then
    GUI = Instance.new("ScreenGui")
    GUI.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

GUI.Name = "ChinoksTradeScript"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.IgnoreGuiInset = true

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320 * Config.UIScale, 0, 180 * Config.UIScale)
MainFrame.Position = UDim2.new(0.5, -160 * Config.UIScale, 0.5, -90 * Config.UIScale)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = GUI
MainFrame.ClipsDescendants = true

-- Apply rounded corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Gradient background
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 10, 10)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 20, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 10, 10))
})
Gradient.Rotation = 45
Gradient.Parent = MainFrame

-- Shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://7912134082"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(80, 80, 80, 80)
Shadow.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30 * Config.UIScale)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BackgroundTransparency = 0.4
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

-- Fix corner overlap
local TitleBarFix = Instance.new("Frame")
TitleBarFix.Name = "Fix"
TitleBarFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleBarFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBarFix.BackgroundTransparency = 0.4
TitleBarFix.BorderSizePixel = 0
TitleBarFix.Parent = TitleBar

-- Title Text
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = Config.Title .. " " .. Config.Subtitle
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16 * Config.UIScale
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Close Button (invisibly spans the entire title bar for easy clicking)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(1, 0, 1, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = ""
CloseButton.Parent = TitleBar

-- Toggle Button Container
local ToggleContainer = Instance.new("Frame")
ToggleContainer.Name = "ToggleContainer"
ToggleContainer.Size = UDim2.new(0, 120 * Config.UIScale, 0, 40 * Config.UIScale)
ToggleContainer.Position = UDim2.new(0.5, -60 * Config.UIScale, 0.5, -20 * Config.UIScale)
ToggleContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleContainer.BackgroundTransparency = 0.3
ToggleContainer.BorderSizePixel = 0
ToggleContainer.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleContainer

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = "Turn On"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16 * Config.UIScale
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.Parent = ToggleContainer

-- Status Indicator
local StatusIndicator = Instance.new("Frame")
StatusIndicator.Name = "StatusIndicator"
StatusIndicator.Size = UDim2.new(0, 12 * Config.UIScale, 0, 12 * Config.UIScale)
StatusIndicator.Position = UDim2.new(0, 10 * Config.UIScale, 0.5, 0)
StatusIndicator.AnchorPoint = Vector2.new(0, 0.5)
StatusIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
StatusIndicator.BorderSizePixel = 0
StatusIndicator.Parent = ToggleContainer

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusIndicator

-- Glow effect for status
local StatusGlow = Instance.new("ImageLabel")
StatusGlow.Name = "Glow"
StatusGlow.AnchorPoint = Vector2.new(0.5, 0.5)
StatusGlow.BackgroundTransparency = 1
StatusGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
StatusGlow.Size = UDim2.new(2, 0, 2, 0)
StatusGlow.Image = "rbxassetid://7131988326"
StatusGlow.ImageColor3 = Color3.fromRGB(100, 100, 100)
StatusGlow.ImageTransparency = 0.7
StatusGlow.Parent = StatusIndicator

-- Credits Label
local CreditsLabel = Instance.new("TextLabel")
CreditsLabel.Name = "CreditsLabel"
CreditsLabel.Size = UDim2.new(1, 0, 0, 20 * Config.UIScale)
CreditsLabel.Position = UDim2.new(0, 0, 1, -25 * Config.UIScale)
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.Text = "Made by " .. Config.Credits
CreditsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CreditsLabel.TextSize = 12 * Config.UIScale
CreditsLabel.Font = Enum.Font.Gotham
CreditsLabel.Parent = MainFrame

-- Version Label (hidden)
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "VersionLabel"
VersionLabel.Size = UDim2.new(0, 50 * Config.UIScale, 0, 15 * Config.UIScale)
VersionLabel.Position = UDim2.new(1, -55 * Config.UIScale, 1, -20 * Config.UIScale)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = Config.Version
VersionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
VersionLabel.TextSize = 11 * Config.UIScale
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextTransparency = 0.7
VersionLabel.Parent = MainFrame

-- Warning Popup
local WarningPopup = Instance.new("Frame")
WarningPopup.Name = "WarningPopup"
WarningPopup.Size = UDim2.new(0, 250 * Config.UIScale, 0, 130 * Config.UIScale)
WarningPopup.Position = UDim2.new(0.5, 0, 0.5, 0)
WarningPopup.AnchorPoint = Vector2.new(0.5, 0.5)
WarningPopup.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
WarningPopup.BorderSizePixel = 0
WarningPopup.Visible = false
WarningPopup.ZIndex = 10
WarningPopup.Parent = GUI

local WarningCorner = Instance.new("UICorner")
WarningCorner.CornerRadius = UDim.new(0, 8)
WarningCorner.Parent = WarningPopup

-- Warning Icon
local WarningIcon = Instance.new("ImageLabel")
WarningIcon.Name = "WarningIcon"
WarningIcon.Size = UDim2.new(0, 30 * Config.UIScale, 0, 30 * Config.UIScale)
WarningIcon.Position = UDim2.new(0.5, 0, 0, 20 * Config.UIScale)
WarningIcon.AnchorPoint = Vector2.new(0.5, 0)
WarningIcon.BackgroundTransparency = 1
WarningIcon.Image = "rbxassetid://7734053281"
WarningIcon.ImageColor3 = Color3.fromRGB(255, 200, 0)
WarningIcon.ZIndex = 11
WarningIcon.Parent = WarningPopup

-- Warning Title
local WarningTitle = Instance.new("TextLabel")
WarningTitle.Name = "WarningTitle"
WarningTitle.Size = UDim2.new(1, -20, 0, 20 * Config.UIScale)
WarningTitle.Position = UDim2.new(0, 10, 0, 55 * Config.UIScale)
WarningTitle.BackgroundTransparency = 1
WarningTitle.Text = "Warning"
WarningTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
WarningTitle.TextSize = 16 * Config.UIScale
WarningTitle.Font = Enum.Font.GothamBold
WarningTitle.ZIndex = 11
WarningTitle.Parent = WarningPopup

-- Warning Message
local WarningMessage = Instance.new("TextLabel")
WarningMessage.Name = "WarningMessage"
WarningMessage.Size = UDim2.new(1, -20, 0, 40 * Config.UIScale)
WarningMessage.Position = UDim2.new(0, 10, 0, 75 * Config.UIScale)
WarningMessage.BackgroundTransparency = 1
WarningMessage.Text = "This feature is now active. Use at your own risk."
WarningMessage.TextColor3 = Color3.fromRGB(230, 230, 230)
WarningMessage.TextSize = 14 * Config.UIScale
WarningMessage.TextWrapped = true
WarningMessage.Font = Enum.Font.Gotham
WarningMessage.ZIndex = 11
WarningMessage.Parent = WarningPopup

-- Warning Shadow
local WarningShadow = Instance.new("ImageLabel")
WarningShadow.Name = "Shadow"
WarningShadow.AnchorPoint = Vector2.new(0.5, 0.5)
WarningShadow.BackgroundTransparency = 1
WarningShadow.Position = UDim2.new(0.5, 0, 0.5, 4)
WarningShadow.Size = UDim2.new(1, 20, 1, 20)
WarningShadow.Image = "rbxassetid://7912134082"
WarningShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
WarningShadow.ImageTransparency = 0.6
WarningShadow.ScaleType = Enum.ScaleType.Slice
WarningShadow.SliceCenter = Rect.new(80, 80, 80, 80)
WarningShadow.ZIndex = 9
WarningShadow.Parent = WarningPopup

-- Warning backdrop
local Backdrop = Instance.new("Frame")
Backdrop.Name = "Backdrop"
Backdrop.Size = UDim2.new(1, 0, 1, 0)
Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Backdrop.BackgroundTransparency = 0.7
Backdrop.BorderSizePixel = 0
Backdrop.ZIndex = 8
Backdrop.Visible = false
Backdrop.Parent = GUI

-- Functionality

-- Rainbow Color Effect for Credits
local function UpdateRainbowEffect()
    local hue = tick() % 10 / 10
    local colorStart = Color3.fromHSV(hue, 1, 1)
    local colorEnd = Color3.fromHSV((hue + 0.1) % 1, 1, 1)
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorStart),
        ColorSequenceKeypoint.new(1, colorEnd)
    })
    gradient.Parent = CreditsLabel
    
    return gradient
end

local rainbowGradient = UpdateRainbowEffect()

-- Drag functionality
local function UpdateDrag(input)
    local delta = input.Position - DragStart
    local targetPosition = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    
    -- Smooth movement with inertia
    CreateTween(MainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingStyle.Out), {
        Position = targetPosition
    })
    
    -- Calculate inertia (velocity)
    DragInertia = (input.Position - LastMousePos) * 0.8
    LastMousePos = input.Position
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
        LastMousePos = input.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and Dragging then
        UpdateDrag(input)
    end
end)

-- Apply inertia after drag ends
RunService:BindToRenderStep("DragInertia", Enum.RenderPriority.Camera.Value, function()
    if not Dragging and (math.abs(DragInertia.X) > 0.1 or math.abs(DragInertia.Y) > 0.1) then
        local targetPosition = UDim2.new(
            MainFrame.Position.X.Scale, 
            MainFrame.Position.X.Offset + DragInertia.X,
            MainFrame.Position.Y.Scale,
            MainFrame.Position.Y.Offset + DragInertia.Y
        )
        
        -- Apply inertia with dampening
        MainFrame.Position = UDim2.new(
            MainFrame.Position.X.Scale,
            Lerp(MainFrame.Position.X.Offset, targetPosition.X.Offset, 0.2),
            MainFrame.Position.Y.Scale,
            Lerp(MainFrame.Position.Y.Offset, targetPosition.Y.Offset, 0.2)
        )
        
        -- Dampen inertia
        DragInertia = DragInertia * 0.92
        
        -- Stop inertia when it's very small
        if math.abs(DragInertia.X) < 0.1 and math.abs(DragInertia.Y) < 0.1 then
            DragInertia = Vector2.new(0, 0)
        end
    end
end)

-- Toggle button functionality
ToggleButton.MouseButton1Click:Connect(function()
    ToggleActive = not ToggleActive
    
    -- Update status indicator
    local targetColor = ToggleActive and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(100, 100, 100)
    local glowColor = ToggleActive and Color3.fromRGB(40, 180, 100) or Color3.fromRGB(100, 100, 100)
    local buttonText = ToggleActive and "Turn Off" or "Turn On"
    
    CreateTween(StatusIndicator, TweenInfo.new(0.3), {
        BackgroundColor3 = targetColor
    })
    
    CreateTween(StatusGlow, TweenInfo.new(0.3), {
        ImageColor3 = glowColor,
        ImageTransparency = ToggleActive and 0.5 or 0.7
    })
    
    ToggleButton.Text = buttonText
    
    -- Show warning when activated
    if ToggleActive then
        Backdrop.Visible = true
        WarningPopup.Visible = true
        WarningPopup.Position = UDim2.new(0.5, 0, 0.5, -50)
        WarningPopup.BackgroundTransparency = 1
        
        -- Animation
        CreateTween(WarningPopup, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingStyle.Out), {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 0
        })
        
        -- Auto-close warning after 3 seconds
        task.delay(3, function()
            CreateTween(WarningPopup, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingStyle.In), {
                Position = UDim2.new(0.5, 0, 0.5, 50),
                BackgroundTransparency = 1
            }).Completed:Connect(function()
                WarningPopup.Visible = false
                Backdrop.Visible = false
            end)
        end)
    end
    
    -- Add your script execution logic here when ToggleActive is true
    if ToggleActive then
        -- This is where you would put the trade script functionality
        print("Chinoks Trade Script Activated")
    else
        print("Chinoks Trade Script Deactivated")
    end
end)

-- Close button functionality
CloseButton.MouseButton1Click:Connect(function()
    -- Animate closing
    CreateTween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingStyle.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    }).Completed:Connect(function()
        GUI:Destroy()
    end)
end)

-- Key bindings
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Config.ToggleKey then
        -- Simulate toggle button click
        ToggleButton.MouseButton1Click:Fire()
    elseif input.KeyCode == Config.CloseKey then
        -- Simulate close button click
        CloseButton.MouseButton1Click:Fire()
    end
end)

-- Animate UI appearance
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundTransparency = 1

CreateTween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingStyle.Out), {
    Size = UDim2.new(0, 320 * Config.UIScale, 0, 180 * Config.UIScale),
    Position = UDim2.new(0.5, -160 * Config.UIScale, 0.5, -90 * Config.UIScale),
    BackgroundTransparency = 0
})

-- Update rainbow effect
local rainbowConnection = RunService.Heartbeat:Connect(function()
    if not GUI or not GUI.Parent then
        rainbowConnection:Disconnect()
        return
    end
    
    if rainbowGradient and rainbowGradient.Parent then
        rainbowGradient:Destroy()
        rainbowGradient = UpdateRainbowEffect()
    end
end)

-- Handle script cleanup on termination
local function cleanupScript()
    if rainbowConnection then
        rainbowConnection:Disconnect()
    end
    
    RunService:UnbindFromRenderStep("DragInertia")
    
    if GUI and GUI.Parent then
        GUI:Destroy()
    end
end

-- Call this when the script is terminated or when GUI is destroyed
GUI.AncestryChanged:Connect(function(_, parent)
    if not parent then
        cleanupScript()
    end
end)

-- Prevent memory leaks
task.spawn(function()
    while GUI and GUI.Parent do
        task.wait(1)
    end
    cleanupScript()
end)

print("Chinoks Trade Script GUI Loaded")
