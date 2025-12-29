-- CamLock Mobile Edition para DZ HUB
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local locked = false
local target = nil

-- Criar Botão na Tela (Mobile Friendly)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CamLockGui"
screenGui.Parent = CoreGui -- Tenta colocar no CoreGui para não sumir ao morrer

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 100, 0, 50)
toggleBtn.Position = UDim2.new(0.5, -50, 0.1, 0) -- Topo central da tela
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
toggleBtn.Text = "Lock: OFF"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Parent = screenGui
toggleBtn.Draggable = true -- Você pode arrastar o botão para onde quiser

-- Função para achar o inimigo mais próximo da mira
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = camera:WorldToViewportPoint(otherPlayer.Character.HumanoidRootPart.Position)
            
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    closestPlayer = otherPlayer
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- Lógica do Botão
toggleBtn.MouseButton1Click:Connect(function()
    locked = not locked
    if locked then
        target = getClosestPlayer()
        toggleBtn.Text = "Lock: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
        target = nil
        toggleBtn.Text = "Lock: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- Atualização da Câmera (RenderStepped é melhor para Codex)
RunService.RenderStepped:Connect(function()
    if locked and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local lookAt = target.Character.HumanoidRootPart.Position
        camera.CFrame = CFrame.new(camera.CFrame.Position, lookAt)
    end
end)
