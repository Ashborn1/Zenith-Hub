local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "My Tycoon Hub",
   Icon = 0,
   LoadingTitle = "Tycoon Script",
   LoadingSubtitle = "Auto Upgrade",
   ShowText = "Hub",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "TycoonHub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

-- =====================
-- HELPERS
-- =====================
local function getCharacterParts()
   local character = localPlayer.Character
   if not character then return nil, nil, nil end
   local hrp = character:FindFirstChild("HumanoidRootPart")
   local humanoid = character:FindFirstChildOfClass("Humanoid")
   local foot = character:FindFirstChild("LeftFoot")
   return hrp, humanoid, foot
end

-- =====================
-- TAB: PLAYER
-- =====================
local PlayerTab = Window:CreateTab("Player", "person-standing")

PlayerTab:CreateSection("Movement")

local currentWalkSpeed = 16
PlayerTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 250},
   Increment = 1,
   Suffix = " WS",
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(Value)
      currentWalkSpeed = Value
      local _, humanoid, _ = getCharacterParts()
      if humanoid then
         humanoid.WalkSpeed = Value
      end
   end,
})

localPlayer.CharacterAdded:Connect(function(character)
   local humanoid = character:WaitForChild("Humanoid")
   humanoid.WalkSpeed = currentWalkSpeed
end)

PlayerTab:CreateSection("Fly")

local flyEnabled = false
local flyConnection = nil
local bodyVelocity = nil
local bodyGyro = nil

local function enableFly()
   local hrp, humanoid, _ = getCharacterParts()
   if not hrp then return end

   humanoid.PlatformStand = true

   bodyVelocity = Instance.new("BodyVelocity")
   bodyVelocity.Velocity = Vector3.zero
   bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
   bodyVelocity.Parent = hrp

   bodyGyro = Instance.new("BodyGyro")
   bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
   bodyGyro.D = 50
   bodyGyro.Parent = hrp

   local camera = workspace.CurrentCamera
   local flySpeed = 50

   flyConnection = RunService.RenderStepped:Connect(function()
      local hrpNow, _, _ = getCharacterParts()
      if not hrpNow or not flyEnabled then return end

      local moveDir = Vector3.zero
      if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
      if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
      if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
      if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
      if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
      if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

      if moveDir.Magnitude > 0 then
         moveDir = moveDir.Unit
      end

      bodyVelocity.Velocity = moveDir * flySpeed
      bodyGyro.CFrame = camera.CFrame
   end)
end

local function disableFly()
   local _, humanoid, _ = getCharacterParts()
   if flyConnection then flyConnection:Disconnect() flyConnection = nil end
   if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
   if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
   if humanoid then humanoid.PlatformStand = false end
end

PlayerTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      flyEnabled = Value
      if flyEnabled then
         enableFly()
         Rayfield:Notify({ Title = "Fly", Content = "Fly enabled! WASD + Space/Shift to move.", Duration = 3, Image = "plane" })
      else
         disableFly()
         Rayfield:Notify({ Title = "Fly", Content = "Fly disabled.", Duration = 3, Image = "plane-off" })
      end
   end,
})

PlayerTab:CreateSection("NoClip")

local noclipEnabled = false
local noclipConnection = nil

PlayerTab:CreateToggle({
   Name = "NoClip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
      noclipEnabled = Value
      if noclipEnabled then
         noclipConnection = RunService.Stepped:Connect(function()
            local character = localPlayer.Character
            if not character then return end
            for _, part in pairs(character:GetDescendants()) do
               if part:IsA("BasePart") then
                  part.CanCollide = false
               end
            end
         end)
         Rayfield:Notify({ Title = "NoClip", Content = "NoClip enabled.", Duration = 3, Image = "ghost" })
      else
         if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
         local character = localPlayer.Character
         if character then
            for _, part in pairs(character:GetDescendants()) do
               if part:IsA("BasePart") then
                  part.CanCollide = true
               end
            end
         end
         Rayfield:Notify({ Title = "NoClip", Content = "NoClip disabled.", Duration = 3, Image = "ghost" })
      end
   end,
})



-- =====================
-- INIT NOTIFY
-- =====================
Rayfield:Notify({
   Title = "Hub Loaded",
   Content = "Tycoon Hub is ready! Press K to toggle.",
   Duration = 5,
   Image = "rocket",
})
