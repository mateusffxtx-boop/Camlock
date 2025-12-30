local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- // ESTADOS //
local isEnabled = false
local lockedTarget = nil

-- // INTERFACE MOBILE //
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DZHUB_DRAGGABLE"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 120, 0, 120)
mainFrame.Position = UDim2.new(0.7, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.5
mainFrame.Active = true -- Necessário para detetar input
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.Parent = mainFrame

local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(0.8, 0, 0.8, 0)
lockBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
lockBtn.Text = "LOCK"
lockBtn.TextColor3 = Color3.new(1, 1, 1)
lockBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
lockBtn.Font = Enum.Font.GothamBold
lockBtn.TextSize = 18
lockBtn.Parent = mainFrame

Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(1, 0)

-- // FUNÇÃO PARA TORNAR ARRASTÁVEL NO MOBILE //
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- // LÓGICA DE COMBATE (ALVO MAIS PRÓXIMO) //
local function getClosestPlayer()
    local closest = nil
    local dist = 100
    for _, other in pairs(Players:GetPlayers()) do
        if other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = other.Character.HumanoidRootPart
            local magnitude = (root.Position - targetRoot.Position).Magnitude
            if magnitude < dist then
                dist = magnitude
                closest = targetRoot
            end
        end
    end
    return closest
end

lockBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        lockedTarget = getClosestPlayer()
        if lockedTarget then
            lockBtn.Text = "LOCKED"
            lockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        else
            isEnabled = false
            lockBtn.Text = "ERRO"
            task.wait(1)
            lockBtn.Text = "LOCK"
        end
    else
        lockedTarget = nil
        lockBtn.Text = "LOCK"
        lockBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end)

RunService.RenderStepped:Connect(function()
    if isEnabled and lockedTarget and lockedTarget.Parent then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        local hum = lockedTarget.Parent:FindFirstChild("Humanoid")
        if root and hum and hum.Health > 0 then
            local lookPos = Vector3.new(lockedTarget.Position.X, root.Position.Y, lockedTarget.Position.Z)
            root.CFrame = CFrame.lookAt(root.Position, lookPos)
        else
            isEnabled = false
            lockedTarget = nil
            lockBtn.Text = "LOCK"
            lockBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end
    end
end)
