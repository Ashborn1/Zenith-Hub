-- Load Rayfield
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

local function getTouchPart()
   local character = localPlayer.Character
   if not character then return nil end
   return character:FindFirstChild("LeftFoot") or character:FindFirstChild("Torso") or character.PrimaryPart
end

-- =====================
-- TAB: PLAYER (original)
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
-- TAB: REBIRTH
-- =====================
local RebirthTab = Window:CreateTab("Rebirth", "repeat")

local function getRebirthRemote()
   local success, controller = pcall(function()
      local module = localPlayer:WaitForChild("PlayerScripts"):WaitForChild("Controllers"):WaitForChild("RebirthController")
      return require(module)
   end)
   if not success or not controller then
      return nil
   end
   return controller.Rebirth
end

local rebirthRemote = getRebirthRemote()

if not rebirthRemote then
   RebirthTab:CreateParagraph({ Title = "Error", Content = "RebirthController not found." })
else
   local isRunning = false
   local loopCoroutine = nil
   local delayValue = 0.3

   local function fireRebirth()
      rebirthRemote:FireServer()
   end

   local function rebirthLoop()
      while isRunning do
         fireRebirth()
         task.wait(delayValue)
      end
   end

   local function startLoop()
      if isRunning then return end
      isRunning = true
      loopCoroutine = coroutine.create(rebirthLoop)
      coroutine.resume(loopCoroutine)
   end

   local function stopLoop()
      isRunning = false
      loopCoroutine = nil
   end

   RebirthTab:CreateSlider({
      Name = "Rebirth Delay",
      Range = {0.1, 2.0},
      Increment = 0.1,
      Suffix = "s",
      CurrentValue = delayValue,
      Flag = "RebirthDelay",
      Callback = function(Value)
         delayValue = Value
      end
   })

   RebirthTab:CreateToggle({
      Name = "Auto Rebirth",
      CurrentValue = false,
      Flag = "AutoRebirth",
      Callback = function(Value)
         if Value then
            startLoop()
            Rayfield:Notify({ Title = "Auto Rebirth", Content = "Started!", Duration = 3, Image = "rocket" })
         else
            stopLoop()
            Rayfield:Notify({ Title = "Auto Rebirth", Content = "Stopped.", Duration = 3, Image = "rocket" })
         end
      end
   })

   localPlayer.CharacterAdded:Connect(function()
      if isRunning then stopLoop() end
   end)
end

-- =====================
-- TAB: AUTO WIN (UPDATED with World 1 and World 2)
-- =====================
local AutoTab = Window:CreateTab("Auto Win", "medal")

-- Target paths
local function getWinPart(worldName)
   local areas = workspace:FindFirstChild("Areas")
   if not areas then return nil end
   local world = areas:FindFirstChild(worldName)
   if not world then return nil end
   local area = world:FindFirstChild("Area10")
   if not area then return nil end
   return area:FindFirstChild("Win")
end

local target1 = getWinPart("Spawn World")
local target2 = getWinPart("Future World")

-- Shared delay
local winDelay = 0.3

-- State for each
local winRunning1 = false
local winLoop1 = nil
local winRunning2 = false
local winLoop2 = nil

-- Helper to fire touch on a target
local function fireWinTouch(target)
   local touchPart = getTouchPart()
   if not touchPart or not target then return end
   firetouchinterest(target, touchPart, 0)
   task.wait(0.1)
   firetouchinterest(target, touchPart, 1)
end

-- Generic loop creator
local function createWinLoop(target, runningVar)
   return function()
      while runningVar() do
         fireWinTouch(target)
         task.wait(winDelay)
      end
   end
end

-- Slider for delay
AutoTab:CreateSlider({
   Name = "Win Click Delay",
   Range = {0.1, 2.0},
   Increment = 0.1,
   Suffix = "s",
   CurrentValue = winDelay,
   Flag = "WinDelay",
   Callback = function(Value)
      winDelay = Value
   end
})

-- World 1 toggle
if target1 then
   AutoTab:CreateToggle({
      Name = "Auto Win (World 1 - Spawn)",
      CurrentValue = false,
      Flag = "AutoWin1",
      Callback = function(Value)
         if Value then
            if winRunning1 then return end
            winRunning1 = true
            winLoop1 = coroutine.create(function()
               while winRunning1 do
                  fireWinTouch(target1)
                  task.wait(winDelay)
               end
            end)
            coroutine.resume(winLoop1)
            Rayfield:Notify({ Title = "Auto Win", Content = "World 1 started!", Duration = 3, Image = "medal" })
         else
            winRunning1 = false
            winLoop1 = nil
            Rayfield:Notify({ Title = "Auto Win", Content = "World 1 stopped.", Duration = 3, Image = "medal" })
         end
      end
   })
else
   AutoTab:CreateParagraph({ Title = "World 1", Content = "Win part not found for Spawn World." })
end

-- World 2 toggle
if target2 then
   AutoTab:CreateToggle({
      Name = "Auto Win (World 2 - Future)",
      CurrentValue = false,
      Flag = "AutoWin2",
      Callback = function(Value)
         if Value then
            if winRunning2 then return end
            winRunning2 = true
            winLoop2 = coroutine.create(function()
               while winRunning2 do
                  fireWinTouch(target2)
                  task.wait(winDelay)
               end
            end)
            coroutine.resume(winLoop2)
            Rayfield:Notify({ Title = "Auto Win", Content = "World 2 started!", Duration = 3, Image = "medal" })
         else
            winRunning2 = false
            winLoop2 = nil
            Rayfield:Notify({ Title = "Auto Win", Content = "World 2 stopped.", Duration = 3, Image = "medal" })
         end
      end
   })
else
   AutoTab:CreateParagraph({ Title = "World 2", Content = "Win part not found for Future World." })
end

-- Stop all win loops on character change
localPlayer.CharacterAdded:Connect(function()
   if winRunning1 then winRunning1 = false; winLoop1 = nil end
   if winRunning2 then winRunning2 = false; winLoop2 = nil end
end)

-- =====================
-- INIT NOTIFY
-- =====================
Rayfield:Notify({
   Title = "Hub Loaded",
   Content = "Tycoon Hub is ready! Press K to toggle.",
   Duration = 5,
   Image = "rocket",
})
