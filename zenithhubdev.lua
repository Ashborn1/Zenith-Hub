local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Zenith Hub",
   Icon = 0,
   LoadingTitle = "Sell Lemons Script",
   LoadingSubtitle = "Monarchs",
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
      if flyEnabled then enableFly() else disableFly() end
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
      else
         if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
         local character = localPlayer.Character
         if character then
            for _, part in pairs(character:GetDescendants()) do
               if part:IsA("BasePart") then part.CanCollide = true end
            end
         end
      end
   end,
})

-- =====================
-- TAB: TYCOON
-- =====================
local TycoonTab = Window:CreateTab("Tycoon", "building")

-- =====================
-- SECTION: AUTO UPGRADE STALL
-- =====================
TycoonTab:CreateSection("Auto Upgrade Stall")

local upgradeTimes = 1

local purchaseNames = {
   "Lemon Depot",
   "Lemon Labs",
   "Lemon Republic",
   "Lemon Robotics",
   "Lemon Stand",
   "Lemon Trading",
   "LemonDash",
   "LemonX",
}

local function getStallPrompt(stallName)
   local myTycoon = getMyTycoon()
   if not myTycoon then return nil end
   local purchases = myTycoon:FindFirstChild("Purchases")
   if not purchases then return nil end
   local stall = purchases:FindFirstChild(stallName)
   if not stall then return nil end
   local promptObj = stall:FindFirstChild(stallName)
   if not promptObj then return nil end
   local innerObj = promptObj:FindFirstChild(stallName)
   if not innerObj then return nil end
   return innerObj:FindFirstChild("Prompt")
end

local function teleportAndBuy(stallName)
   local prompt = getStallPrompt(stallName)
   if not prompt then return end
   local promptParent = prompt.Parent
   if not promptParent or not promptParent:IsA("BasePart") then return end
   
   local hrp = getCharacterParts()
   if not hrp then return end
   
   hrp.CFrame = CFrame.new(promptParent.Position + Vector3.new(0, 4, 0))
   task.wait(0.25)
   
   for i = 1, upgradeTimes do
      fireproximityprompt(prompt)
      task.wait(0.1)
   end
end

TycoonTab:CreateInput({
   Name = "Times to Fire",
   PlaceholderText = "1",
   RemoveTextAfterFocusLost = false,
   Flag = "UpgradeTimes",
   Callback = function(Value)
      local num = tonumber(Value)
      if num and num > 0 then upgradeTimes = math.floor(num) end
   end,
})

for _, stallName in ipairs(purchaseNames) do
   TycoonTab:CreateButton({
      Name = "Buy: " .. stallName,
      Callback = function()
         teleportAndBuy(stallName)
      end,
   })
end

TycoonTab:CreateButton({
   Name = "Buy All Stalls",
   Callback = function()
      for _, stallName in ipairs(purchaseNames) do
         teleportAndBuy(stallName)
         task.wait(0.5)
      end
   end,
})

-- =====================
-- SECTION: AUTO EXPANSION
-- =====================
TycoonTab:CreateSection("Auto Expansion")

local autoExpansionEnabled = false
local expansionLoopDelay = 1

local function buyAllExpansions()
   local character = localPlayer.Character
   if not character then return end
   local foot = character:FindFirstChild("LeftFoot")
   if not foot then return end
   local myTycoon = getMyTycoon()
   if not myTycoon then return end

   for _, item in pairs(myTycoon:GetDescendants()) do
      if item.Name == "Button" and item:IsA("BasePart") then
         firetouchinterest(item, foot, 0)
         task.wait(0.1)
         firetouchinterest(item, foot, 1)
         task.wait(0.1)
      end
   end
end

TycoonTab:CreateButton({
   Name = "Buy All Expansions",
   Callback = function()
      buyAllExpansions()
   end,
})

TycoonTab:CreateToggle({
   Name = "Auto Buy Expansions",
   CurrentValue = false,
   Flag = "AutoBuyExpansionToggle",
   Callback = function(Value)
      autoExpansionEnabled = Value
      if autoExpansionEnabled then
         task.spawn(function()
            while autoExpansionEnabled do
               buyAllExpansions()
               task.wait(expansionLoopDelay)
            end
         end)
      end
   end,
})

TycoonTab:CreateSlider({
   Name = "Expansion Delay",
   Range = {1, 10},
   Increment = 0.5,
   Suffix = "s",
   CurrentValue = 2,
   Flag = "AutoBuyExpansionDelay",
   Callback = function(Value)
      expansionLoopDelay = Value
   end,
})

-- =====================
-- SECTION: REBIRTH
-- =====================
TycoonTab:CreateSection("Rebirth")

local autoRebirthEnabled = false
local autoRebirthDelay = 5
local rebirthTimes = 1

local function doRebirth()
   local myTycoon = getMyTycoon()
   if not myTycoon then return end
   local remotes = myTycoon:FindFirstChild("Remotes")
   if not remotes then return end
   local rebirthRemote = remotes:FindFirstChild("Rebirth")
   if not rebirthRemote then return end
   
   for i = 1, rebirthTimes do
      if rebirthRemote:IsA("RemoteEvent") then
         rebirthRemote:FireServer()
      else
         rebirthRemote:InvokeServer()
      end
      task.wait(0.1)
   end
end

TycoonTab:CreateInput({
   Name = "Times to Rebirth",
   PlaceholderText = "1",
   RemoveTextAfterFocusLost = false,
   Flag = "RebirthTimes",
   Callback = function(Value)
      local num = tonumber(Value)
      if num and num > 0 then rebirthTimes = math.floor(num) end
   end,
})

TycoonTab:CreateButton({
   Name = "Rebirth",
   Callback = function()
      doRebirth()
   end,
})

TycoonTab:CreateToggle({
   Name = "Auto Rebirth",
   CurrentValue = false,
   Flag = "AutoRebirthToggle",
   Callback = function(Value)
      autoRebirthEnabled = Value
      if autoRebirthEnabled then
         task.spawn(function()
            while autoRebirthEnabled do
               doRebirth()
               task.wait(autoRebirthDelay)
            end
         end)
      end
   end,
})

TycoonTab:CreateSlider({
   Name = "Rebirth Delay",
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
-- TAB: DEVELOPMENT (Remote Buy)
-- =====================
local DevTab = Window:CreateTab("Development", "code")

DevTab:CreateSection("Remote Buyer")

local function findPurchaseRemote()
   local myTycoon = getMyTycoon()
   if not myTycoon then return nil end
   local remotes = myTycoon:FindFirstChild("Remotes")
   if not remotes then return nil end
   
   -- Common names
   local names = {"BuyItem", "Purchase", "BuyUpgrade", "Upgrade", "Buy", "PurchaseItem"}
   for _, name in ipairs(names) do
      local r = remotes:FindFirstChild(name)
      if r then return r end
   end
   
   -- Check for any buy-related
   for _, child in pairs(remotes:GetChildren()) do
      local lower = child.Name:lower()
      if lower:find("buy") or lower:find("purchase") or lower:find("upgrade") then
         return child
      end
   end
   return nil
end

local function remoteBuy(stallName)
   local remote = findPurchaseRemote()
   if not remote then return end
   
   local myTycoon = getMyTycoon()
   if not myTycoon then return end
   local purchases = myTycoon:FindFirstChild("Purchases")
   if not purchases then return end
   local stall = purchases:FindFirstChild(stallName)
   if not stall then return end
   
   -- Try different argument patterns
   local patterns = {
      stallName,
      stall.Name,
      stall,
      stall:FindFirstChild(stallName),
      stallName:gsub(" ", ""),
      stallName:lower()
   }
   
   for _, arg in ipairs(patterns) do
      local success = pcall(function()
         if remote:IsA("RemoteEvent") then
            remote:FireServer(arg)
         else
            remote:InvokeServer(arg)
         end
      end)
      if success then break end
   end
end

-- Remote buy buttons for each stall
for _, stallName in ipairs(purchaseNames) do
   DevTab:CreateButton({
      Name = "Remote: " .. stallName,
      Callback = function()
         for i = 1, upgradeTimes do
            remoteBuy(stallName)
            task.wait(0.1)
         end
      end,
   })
end

DevTab:CreateButton({
   Name = "Remote Buy All",
   Callback = function()
      for _, stallName in ipairs(purchaseNames) do
         for i = 1, upgradeTimes do
            remoteBuy(stallName)
            task.wait(0.1)
         end
      end
   end,
})

DevTab:CreateSection("Debug")

DevTab:CreateButton({
   Name = "Scan Remotes",
   Callback = function()
      local myTycoon = getMyTycoon()
      if not myTycoon then print("No tycoon") return end
      local remotes = myTycoon:FindFirstChild("Remotes")
      if not remotes then print("No remotes folder") return end
      
      print("=== REMOTES ===")
      for _, child in pairs(remotes:GetChildren()) do
         print(child.Name .. " | " .. child.ClassName)
      end
   end,
})

-- =====================
-- TAB: MISC
-- =====================
local MiscTab = Window:CreateTab("Misc", "settings")

MiscTab:CreateSection("Server")

local autoRejoinEnabled = false

MiscTab:CreateToggle({
   Name = "Auto Rejoin",
   CurrentValue = false,
   Flag = "AutoRejoin",
   Callback = function(Value)
      autoRejoinEnabled = Value
   end,
})

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

MiscTab:CreateButton({
   Name = "Server Hop",
   Callback = function()
      local success, servers = pcall(function()
         return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
      end)
      if not success then return end
      
      local HttpService = game:GetService("HttpService")
      local data = HttpService:JSONDecode(servers)
      local currentJobId = game.JobId
      
      for _, server in pairs(data.data) do
         if server.id ~= currentJobId and server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, localPlayer)
            return
         end
      end
   end,
})

MiscTab:CreateSection("Performance")

local antiLagEnabled = false
local antiLagConnection = nil

MiscTab:CreateToggle({
   Name = "Anti Lag",
   CurrentValue = false,
   Flag = "AntiLag",
   Callback = function(Value)
      antiLagEnabled = Value
      if antiLagEnabled then
         for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
               v.Enabled = false
            end
         end
         settings().Rendering.QualityLevel = 1
         antiLagConnection = workspace.DescendantAdded:Connect(function(v)
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
               v.Enabled = false
            end
         end)
      else
         if antiLagConnection then antiLagConnection:Disconnect() antiLagConnection = nil end
         for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
               v.Enabled = true
            end
         end
         settings().Rendering.QualityLevel = 10
      end
   end,
})

MiscTab:CreateSection("Info")

MiscTab:CreateLabel("Hub Version: 2.0.0")
MiscTab:CreateLabel("Place ID: " .. tostring(game.PlaceId))

MiscTab:CreateButton({
   Name = "Copy Server ID",
   Callback = function()
      setclipboard(game.JobId)
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
   end,
})

-- =====================
-- INIT
-- =====================
Rayfield:Notify({
   Title = "Hub Loaded",
   Content = "Zenith Hub v2.0.0 ready",
   Duration = 3,
   Image = "rocket",
})
