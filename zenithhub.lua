-- =====================
-- SECTION: AUTO UPGRADE STALL (Teleport Once + Rapid Fire)
-- =====================
TycoonTab:CreateSection("Auto Upgrade Stall")

local autoStalls = {}

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

-- Individual toggle - teleport once then rapid fire
for _, stallName in ipairs(purchaseNames) do
   autoStalls[stallName] = false
   
   TycoonTab:CreateToggle({
      Name = "Auto: " .. stallName,
      CurrentValue = false,
      Flag = "Auto" .. stallName:gsub(" ", ""),
      Callback = function(Value)
         autoStalls[stallName] = Value
         if Value then
            task.spawn(function()
               -- Get prompt and teleport once
               local prompt = getStallPrompt(stallName)
               if not prompt then 
                  autoStalls[stallName] = false
                  return 
               end
               
               local promptParent = prompt.Parent
               if not promptParent or not promptParent:IsA("BasePart") then 
                  autoStalls[stallName] = false
                  return 
               end
               
               local hrp = getCharacterParts()
               if not hrp then 
                  autoStalls[stallName] = false
                  return 
               end
               
               -- Teleport once
               hrp.CFrame = CFrame.new(promptParent.Position + Vector3.new(0, 3, 0))
               task.wait(0.2)
               
               -- Rapid fire loop - no delays, pure speed
               while autoStalls[stallName] do
                  fireproximityprompt(prompt)
               end
            end)
         end
      end,
   })
end
