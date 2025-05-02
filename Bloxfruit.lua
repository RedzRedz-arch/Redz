-- Create GUI Elements
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AstroHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 120)
Frame.Position = UDim2.new(0.5, -125, 0.5, -60)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "Astro Hub 2x Luck Script"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Size = UDim2.new(1, 0, 0, 40)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Parent = Frame

local Button = Instance.new("TextButton")
Button.Text = "Turn On"
Button.Size = UDim2.new(0.6, 0, 0, 35)
Button.Position = UDim2.new(0.2, 0, 0.5, 0)
Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 18
Button.Parent = Frame

local Credit = Instance.new("TextLabel")
Credit.Text = "Made by Chinok"
Credit.Font = Enum.Font.SourceSans
Credit.TextSize = 14
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 1, -20)
Credit.TextColor3 = Color3.fromRGB(0, 255, 0)
Credit.BackgroundTransparency = 1
Credit.Parent = Frame

-- Code to run when clicked
Button.MouseButton1Click:Connect(function()
    print("Your custom code starts here!")

    -- Your custom code goes here
    -- Example: grant player luck boost or run script logic

    -- Optionally hide UI
    ScreenGui:Destroy()
end)
