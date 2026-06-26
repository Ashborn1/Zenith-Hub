local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "My Tycoon Hub",
   Icon = 0,
   LoadingTitle = "Tycoon Script",
   LoadingSubtitle = "Auto Upgrade",
   ShowText = "Hub",
   Theme = "Default",
   ToggleUIKeybind = "Z",
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
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local localPlayer = Players.LocalPlayer

-- =====================
-- SERVICES & HELPERS
-- =====================
local function getCharacterParts()
   local character = localPlayer.Character
   if not character then return nil, nil, nil end
   local hrp = character:FindFirstChild("HumanoidRootPart")
   local humanoid = character:FindFirstChildOfClass("Humanoid")
   local foot = character:FindFirstChild("LeftFoot")
   return hrp, humanoid, foot
end

local function getMyTycoon()
   for i = 1, 10 do
      local tycoon = workspace:FindFirstChild("Tycoon" .. i)
      if tycoon then
         local owner = tycoon:FindFirstChild("Owner")
         if owner and owner.Value == localPlayer then
            return tycoon
         end
      end
   end
   return nil
end

local function notify(title, content, image)
   Rayfield:Notify({ Title = title, Content = content, Duration = 3, Image = image })
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
      if humanoid then humanoid.WalkSpeed = Value end
   end,
})

local currentJumpPower = 50
PlayerTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 500},
   Increment = 5,
   Suffix = " JP",
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
      currentJumpPower = Value
      local _, humanoid, _ = getCharacterParts()
      if humanoid then humanoid.JumpPower = Value end
   end,
})

localPlayer.CharacterAdded:Connect(function(character)
   local humanoid = character:WaitForChild("Humanoid")
   humanoid.WalkSpeed = currentWalkSpeed
   humanoid.JumpPower = currentJumpPower
end)

PlayerTab:CreateSection("Fly")

local flyEnabled = false
local flyConnection = nil
local bodyVelocity = nil
local bodyGyro = nil
local flySpeed = 50

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
      if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
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
         notify("Fly", "Fly enabled! WASD + Space/Shift to move.", "plane")
      else
         disableFly()
         notify("Fly", "Fly disabled.", "plane-off")
      end
   end,
})

PlayerTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 300},
   Increment = 5,
   Suffix = " FS",
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(Value)
      flySpeed = Value
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
               if part:IsA("BasePart") then part.CanCollide = false end
            end
         end)
         notify("NoClip", "NoClip enabled.", "ghost")
      else
         if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
         local character = localPlayer.Character
         if character then
            for _, part in pairs(character:GetDescendants()) do
               if part:IsA("BasePart") then part.CanCollide = true end
            end
         end
         notify("NoClip", "NoClip disabled.", "ghost")
      end
   end,
})

-- =====================
-- TAB: TYCOON (AUTO)
-- =====================
local TycoonTab = Window:CreateTab("Tycoon", "building")

TycoonTab:CreateSection("Auto Upgrades")

local autoBuyEnabled = false
local loopDelay = 2

local function buyAllUpgrades()
   local character = localPlayer.Character
   if not character then return end
   local hrp = character:FindFirstChild("HumanoidRootPart")
   local humanoid = character:FindFirstChildOfClass("Humanoid")
   local foot = character:FindFirstChild("LeftFoot")
   if not hrp or not foot then
      notify("Error", "Character parts not found!", "alert-circle")
      return
   end
   local myTycoon = getMyTycoon()
   if not myTycoon then
      notify("Error", "Could not find your tycoon!", "alert-circle")
      return
   end
   local originalCFrame = hrp.CFrame
   local savedAutoRotate = humanoid.AutoRotate
   humanoid.AutoRotate = false
   for _, item in pairs(myTycoon:GetDescendants()) do
      if item.Name == "Button" and item:IsA("BasePart") then
         local buttonPos = item.Position
         hrp.CFrame = CFrame.new(buttonPos.X, originalCFrame.Y, buttonPos.Z)
         task.wait(0.05)
         firetouchinterest(item, foot, 0)
         task.wait(0.1)
         firetouchinterest(item, foot, 1)
         task.wait(0.05)
      end
   end
   hrp.CFrame = originalCFrame
   humanoid.AutoRotate = savedAutoRotate
end

TycoonTab:CreateButton({
   Name = "Buy All Upgrades (Once)",
   Callback = function()
      buyAllUpgrades()
      notify("Done", "All upgrades purchased!", "check-circle")
   end,
})

TycoonTab:CreateToggle({
   Name = "Auto Buy Upgrades",
   CurrentValue = false,
   Flag = "AutoBuyToggle",
   Callback = function(Value)
      autoBuyEnabled = Value
      if autoBuyEnabled then
         notify("Auto Buy", "Auto buying enabled!", "zap")
         task.spawn(function()
            while autoBuyEnabled do
               buyAllUpgrades()
               task.wait(loopDelay)
            end
         end)
      else
         notify("Auto Buy", "Auto buying disabled.", "zap-off")
      end
   end,
})

TycoonTab:CreateSlider({
   Name = "Auto Buy Delay (seconds)",
   Range = {1, 10},
   Increment = 0.5,
   Suffix = "s",
   CurrentValue = 2,
   Flag = "AutoBuyDelay",
   Callback = function(Value)
      loopDelay = Value
   end,
})

TycoonTab:CreateSection("Rebirth")

local function doRebirth()
   local success, result = pcall(function()
      local myTycoon = getMyTycoon()
      if not myTycoon then
         notify("Error", "Could not find your tycoon!", "alert-circle")
         return
      end
      local remotes = myTycoon:FindFirstChild("Remotes")
      if not remotes then
         notify("Error", "No Remotes folder found!", "alert-circle")
         return
      end
      local rebirthRemote = remotes:FindFirstChild("Rebirth")
      if not rebirthRemote then
         notify("Error", "Rebirth remote not found!", "alert-circle")
         return
      end
      rebirthRemote:InvokeServer(nil)
   end)
   if not success then
      warn("Rebirth error: " .. tostring(result))
   end
end

TycoonTab:CreateButton({
   Name = "Rebirth (Once)",
   Callback = function()
      doRebirth()
      notify("Rebirth", "Rebirth triggered!", "refresh-cw")
   end,
})

local autoRebirthEnabled = false
local autoRebirthDelay = 5

TycoonTab:CreateToggle({
   Name = "Auto Rebirth",
   CurrentValue = false,
   Flag = "AutoRebirthToggle",
   Callback = function(Value)
      autoRebirthEnabled = Value
      if autoRebirthEnabled then
         notify("Auto Rebirth", "Auto rebirth enabled!", "refresh-cw")
         task.spawn(function()
            while autoRebirthEnabled do
               doRebirth()
               task.wait(autoRebirthDelay)
            end
         end)
      else
         notify("Auto Rebirth", "Auto rebirth disabled.", "refresh-cw")
      end
   end,
})

TycoonTab:CreateSlider({
   Name = "Auto Rebirth Delay (seconds)",
   Range = {1, 30},
   Increment = 1,
   Suffix = "s",
   CurrentValue = 5,
   Flag = "AutoRebirthDelay",
   Callback = function(Value)
      autoRebirthDelay = Value
   end,
})

-- =====================
-- TAB: MISC
-- =====================
local MiscTab = Window:CreateTab("Misc", "settings")

MiscTab:CreateSection("Server")

-- Auto Rejoin on Kick/Shutdown
local autoRejoinEnabled = false

MiscTab:CreateToggle({
   Name = "Auto Rejoin (Kick/Shutdown)",
   CurrentValue = false,
   Flag = "AutoRejoin",
   Callback = function(Value)
      autoRejoinEnabled = Value
      if autoRejoinEnabled then
         notify("Auto Rejoin", "Will rejoin if kicked or server shuts down.", "rotate-cw")
      else
         notify("Auto Rejoin", "Auto rejoin disabled.", "rotate-cw")
      end
   end,
})

-- Listen for kick/shutdown
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
   if state == Enum.TeleportState.Started then return end
end)

local gameClosing = false
game:BindToClose(function()
   gameClosing = true
end)

localPlayer.AncestryChanged:Connect(function()
   if autoRejoinEnabled and not gameClosing then
      task.wait(3)
      TeleportService:Teleport(game.PlaceId, localPlayer)
   end
end)

-- Server Hop
MiscTab:CreateButton({
   Name = "Server Hop",
   Callback = function()
      notify("Server Hop", "Hopping to a new server...", "shuffle")
      local success, servers = pcall(function()
         return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
      end)
      if not success then
         notify("Server Hop", "Failed to fetch servers.", "alert-circle")
         return
      end
      local HttpService = game:GetService("HttpService")
      local data = HttpService:JSONDecode(servers)
      local currentJobId = game.JobId
      for _, server in pairs(data.data) do
         if server.id ~= currentJobId and server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, localPlayer)
            return
         end
      end
      notify("Server Hop", "No available servers found.", "alert-circle")
   end,
})

MiscTab:CreateSection("Performance")

-- Anti Lag
local antiLagEnabled = false
local antiLagConnection = nil

MiscTab:CreateToggle({
   Name = "Anti Lag",
   CurrentValue = false,
   Flag = "AntiLag",
   Callback = function(Value)
      antiLagEnabled = Value
      if antiLagEnabled then
         -- Reduce particle/effect density and distant object updates
         for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
               v.Enabled = false
            end
         end
         -- Lower render quality
         settings().Rendering.QualityLevel = 1
         antiLagConnection = workspace.DescendantAdded:Connect(function(v)
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
               v.Enabled = false
            end
         end)
         notify("Anti Lag", "Anti lag enabled. Effects disabled.", "zap")
      else
         if antiLagConnection then antiLagConnection:Disconnect() antiLagConnection = nil end
         for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
               v.Enabled = true
            end
         end
         settings().Rendering.QualityLevel = 10
         notify("Anti Lag", "Anti lag disabled. Effects restored.", "zap-off")
      end
   end,
})

MiscTab:CreateSection("Info")

-- Show Version
MiscTab:CreateLabel("Hub Version: 1.0.0")

-- Show PlaceId
MiscTab:CreateLabel("Place ID: " .. tostring(game.PlaceId))

-- Copy Job ID button
MiscTab:CreateButton({
   Name = "Copy Server ID to Clipboard",
   Callback = function()
      setclipboard(game.JobId)
      notify("Copied", "Server Job ID copied to clipboard!", "clipboard")
   end,
})

-- =====================
-- TAB: CUSTOMIZATION
-- =====================
local CustomTab = Window:CreateTab("Customization", "palette")

CustomTab:CreateSection("UI Theme")

CustomTab:CreateDropdown({
   Name = "Hub Theme",
   Options = {"Default", "Ocean", "Midnight", "Amethyst", "Bloom", "Light"},
   CurrentOption = {"Default"},
   Flag = "HubTheme",
   MultipleOptions = false,
   Callback = function(Option)
      Rayfield:SetTheme(Option[1] or Option)
      notify("Theme", "Theme changed to " .. tostring(Option[1] or Option), "palette")
   end,
})

CustomTab:CreateSection("Notifications")

local notifySounds = true
CustomTab:CreateToggle({
   Name = "Notify on Auto Buy",
   CurrentValue = false,
   Flag = "BuyNotify",
   Callback = function(Value)
      notifySounds = Value
      notify("Notifications", Value and "Buy notifications enabled." or "Buy notifications disabled.", "bell")
   end,
})

-- =====================
-- INIT NOTIFY
-- =====================
Rayfield:Notify({
   Title = "Hub Loaded",
   Content = "Tycoon Hub v1.0.0 ready! Press Z to toggle.",
   Duration = 5,
   Image = "rocket",
})
