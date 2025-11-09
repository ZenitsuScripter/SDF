-- ========== SISTEMA DE AUTENTICAÇÃO AUTOMÁTICA ==========
local function verificarAutenticacao()
    local success, senhaGitHub = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/ZenitsuScripter/SDF/main/hhhhjjjjj")
    end)
    
    if not success then
        game.Players.LocalPlayer:Kick("❌ Erro de conexão com servidor de autenticação.\n\nTente novamente mais tarde.")
        return false
    end
    
    -- Remove TODOS espaços, quebras de linha, tabs e caracteres invisíveis
    senhaGitHub = senhaGitHub:gsub("%s+", ""):gsub("\n", ""):gsub("\r", ""):gsub("\t", ""):gsub(" ", "")
    
    -- Senha hardcoded no script (DEVE SER IGUAL ao arquivo no GitHub)
    local senhaLocal = "X9#mK2@pL8vN!qW5jR&yF7uT$hG3xB0cD6nS*zI4aE1oM~Y^wQ+V}K8rP|L2fJ5gH@T9uN#C3xW7bA&mS0vD!E6yR$I4pQ~Z1kF+M2nO|G8lH}j"
    
    -- Verifica se as senhas são idênticas
    if senhaGitHub ~= senhaLocal then
        game.Players.LocalPlayer:Kick("❌ ACESSO NEGADO\n\n🔒 Script desativado pelo desenvolvedor\n\n📌 Motivo: Licença inválida ou expirada\n\n💬 Discord: discord.gg/MG7EPpfWwu")
        return false
    end
    
    return true
end

-- Verifica autenticação ANTES de carregar qualquer coisa
if not verificarAutenticacao() then
    return -- Para a execução do script
end

-- ========== BOTÃO EXTERNO DE MINIMIZAR HUB ==========
task.spawn(function()
    task.wait(10)
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ZenitsuScripter/button/main/shButton.lua"))()
    end)
end)

-- ========== SUI HUB ==========
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Sui Hub v1.8",
    SubTitle = "by Suiryuu",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.K,
    SaveConfig = false
})

-- =============
-- ADICIONA ABAS
-- =============
local Tabs = {
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Raid = Window:AddTab({ Title = "Raid", Icon = "star" }),
    PlayerTeleport = Window:AddTab({ Title = "Teleport", Icon = "eye" }),
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "swords" }),
    Discord = Window:AddTab({ Title = "Discord", Icon = "server" })
}

-- ===========
-- ABA PLAYER - AUTO BREATH
-- ===========
Tabs.Player:AddToggle("AutoBreathToggle", {
    Title = "Auto Breath",
    Description = "Automatically breathes when the Breath bar drops below 35%",
    Default = false,
    Callback = function(state)
        _G.autoBreath = state
    end
})

-- Loop de Auto Breath
task.spawn(function()
    while true do
        task.wait(0.45)
        if not _G.autoBreath then continue end

        pcall(function()
            local lp = game.Players.LocalPlayer
            local rs = game:GetService("ReplicatedStorage")
            
            if not lp or not rs then return end
            
            local breath = lp:FindFirstChild("Breathing") and lp.Breathing.Value or 0

            if breath < 35 then
                rs.Remotes.Async:FireServer("Character", "Breath", true)
            elseif breath >= 95 then
                rs.Remotes.Async:FireServer("Character", "Breath", false)
            end
        end)
    end
end)

-- Reativa Auto Breath ao respawnar
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(2)
    if _G.autoBreath then
        pcall(function()
            local lp = game.Players.LocalPlayer
            local rs = game:GetService("ReplicatedStorage")
            if lp:FindFirstChild("Breathing") and lp.Breathing.Value < 35 then
                rs.Remotes.Async:FireServer("Character", "Breath", true)
            end
        end)
    end
end)

-- ===============
-- BOTÕES ABA RAID
-- ===============
Tabs.Raid:AddButton({
    Title = "Teleport Raid",
    Description = "Teleport to Raid",
    Callback = function()
        pcall(function()
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(7084.1, 1752.3, 1385.2)
            end
        end)
    end
})

Tabs.Raid:AddButton({
    Title = "TP NPC Raid",
    Description = "Teleport to NPC Raid",
    Callback = function()
        pcall(function()
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(-2379.6, 1179.4, -1425.4)
            end
        end)
    end
})

-- ====================
-- ABA TELEPORT PLAYERS
-- ====================
local selectedPlayer = nil
local selectedBreath = nil

local PlayersDropdown = Tabs.PlayerTeleport:AddDropdown("PlayersDropdown", {
    Title = "Teleport Player",
    Description = "Select a Player",
    Values = {},
    Multi = false,
    Default = "Select"
})

PlayersDropdown:OnChanged(function(value)
    selectedPlayer = value
end)

local function updatePlayerList()
    local players = game:GetService("Players"):GetPlayers()
    local names = {}
    for _, p in ipairs(players) do
        table.insert(names, p.Name)
    end
    PlayersDropdown:SetValues(names)
end

game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

Tabs.PlayerTeleport:AddButton({
    Title = "Teleporte to Player",
    Description = "Teleport to Selected Player",
    Callback = function()
        pcall(function()
            if not selectedPlayer then return end
            local target = game.Players:FindFirstChild(selectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            end
        end)
    end
})

-- ===========
-- TREINADORES
-- ===========
local BreathLocations = {
    ["Water"] = CFrame.new(-926.5, 849.2, -989.1),
    ["Rock"] = CFrame.new(-1707.1, 1045.5, -1371.2),
    ["Beast"] = CFrame.new(-3104.5, 783.6, -6599.5),
    ["Flames"] = CFrame.new(1492.0, 1240.0, -353.7),
    ["Love"] = CFrame.new(1188.3, 1082.1, -1113.8),
    ["Snake"] = CFrame.new(989.9, 1075.8, -1136.3),
    ["Sound"] = CFrame.new(-1258.8, 873.0, -6438.8),
    ["Flower"] = CFrame.new(-1315.6, 878.4, -6236.8),
    ["Insect"] = CFrame.new(-1642.8, 912.3, -6488.4),
    ["Mist"] = CFrame.new(3235.8, 784.7, -4046.5),
    ["Wind"] = CFrame.new(-3288.6, 712.6, -1255.1),
    ["Thunder"] = CFrame.new(-699.1, 700.0, 538.6),
    ["Sun"] = CFrame.new(389.2, 821.8, -416.5),
    ["Moon"] = CFrame.new(1833.4, 1121.7, -5949.5)
}

local RespDropdown = Tabs.PlayerTeleport:AddDropdown("RespDropdown", {
    Title = "Breaths",
    Description = "Select a Breath",
    Values = {"Water", "Rock", "Beast", "Flames", "Love", "Snake", "Sound", "Flower", "Insect", "Mist", "Wind", "Thunder", "Sun", "Moon"},
    Multi = false,
    Default = "Select"
})

RespDropdown:OnChanged(function(value)
    selectedBreath = value
end)

Tabs.PlayerTeleport:AddButton({
    Title = "Teleport to Breath",
    Description = "Teleport to Selected Breath",
    Callback = function()
        pcall(function()
            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            if selectedBreath and BreathLocations[selectedBreath] then
                hrp.CFrame = BreathLocations[selectedBreath]
            end
        end)
    end
})

-- ================
-- AUTO TP TRINKETS
-- ================
local TrinketPriority = {
    ["Perfect Crystal"] = 1,
    ["Green Jewel"] = 2,
    ["Red Jewel"] = 3,
    ["Gold Crown"] = 4,
    ["Ancient Coin"] = 5,
    ["Gold Jar"] = 6,
    ["Golden Ring"] = 7,
    ["Gold Goblet"] = 8,
    ["Silver Jar"] = 9,
    ["Silver Ring"] = 10,
    ["Silver Goblet"] = 11,
    ["Bronze Jar"] = 12,
    ["Copper Goblet"] = 13,
    ["Rusty Goblet"] = 14
}

local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local ativo = false
local checkpoint = nil
local char = player.Character or player.CharacterAdded:Wait()
local trinketsAtivos = {}
local monitored = false

local function getPosition(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        for _, p in pairs(obj:GetDescendants()) do
            if p:IsA("BasePart") then return p.Position end
        end
    end
    return nil
end

local function interact(item)
    if not item then return end
    for _, prompt in ipairs(item:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(prompt) end)
        end
    end
end

local function addTrinket(item)
    if not item or not item.Name then return end
    if TrinketPriority[item.Name] then
        for _, v in ipairs(trinketsAtivos) do
            if v == item then return end
        end
        table.insert(trinketsAtivos, item)
    end
end

local function removeTrinket(item)
    for i, v in ipairs(trinketsAtivos) do
        if v == item then
            table.remove(trinketsAtivos, i)
            break
        end
    end
end

local function processarTrinkets()
    while ativo do
        if not char or not char.Parent or not char:FindFirstChild("HumanoidRootPart") then
            task.wait(0.3)
            continue
        end

        if #trinketsAtivos > 0 then
            table.sort(trinketsAtivos, function(a, b)
                local pa = TrinketPriority[a and a.Name or ""] or 999
                local pb = TrinketPriority[b and b.Name or ""] or 999
                return pa < pb
            end)

            local alvo = trinketsAtivos[1]
            if alvo and alvo.Parent then
                local pos = getPosition(alvo)
                if pos and char and char:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    end)
                    task.wait(0.25)
                    interact(alvo)
                    removeTrinket(alvo)
                    task.wait(0.4)
                else
                    removeTrinket(alvo)
                end
            else
                removeTrinket(alvo)
            end
        else
            if checkpoint and char and char:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    char.HumanoidRootPart.CFrame = CFrame.new(checkpoint)
                end)
            end
            task.wait(0.3)
        end
        task.wait(0.1)
    end
end

local function monitor(container)
    if not container then return end
    pcall(function()
        for _, obj in pairs(container:GetChildren()) do
            addTrinket(obj)
        end
        container.ChildAdded:Connect(function(child)
            if ativo then addTrinket(child) end
        end)
        container.ChildRemoved:Connect(function(child)
            removeTrinket(child)
        end)
    end)
end

local function iniciarMonitoramento()
    if monitored then return end
    monitored = true
    monitor(workspace)
    monitor(replicatedStorage)
end

local function ativarAutoTP()
    char = player.Character or player.CharacterAdded:Wait()
    char:WaitForChild("HumanoidRootPart", 5)
    if not ativo then
        checkpoint = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position or checkpoint
        ativo = true
        iniciarMonitoramento()
        task.spawn(processarTrinkets)
    end
end

local function desativarAutoTP()
    ativo = false
    monitored = false
    trinketsAtivos = {}

    if checkpoint and char and char:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            char.HumanoidRootPart.CFrame = CFrame.new(checkpoint)
        end)
    end
end

player.CharacterAdded:Connect(function(newChar)
    char = newChar
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if hrp then
        if ativo then
            if checkpoint then
                pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(checkpoint) end)
            else
                checkpoint = hrp.Position
            end
        end
    end
end)

player.CharacterRemoving:Connect(function(oldChar)
    for i = #trinketsAtivos, 1, -1 do
        local v = trinketsAtivos[i]
        if not v or not v.Parent then
            table.remove(trinketsAtivos, i)
        end
    end
end)

-- ===========
-- ABA AUTO FARM
-- ===========
Tabs.AutoFarm:AddToggle("AutoTrinketToggle", {
    Title = "Auto Trinkets",
    Description = "Auto Collect All Trinkets",
    Default = false,
    Callback = function(state)
        if state then
            ativarAutoTP()
        else
            desativarAutoTP()
        end
    end
})

-- ==================
-- AUTO PICKUP (AURA) TOGGLE
-- ==================
Tabs.AutoFarm:AddToggle("AutoPickupAuraToggle", {
    Title = "Auto Pickup (Aura)",
    Description = "Collects drops automatically within range",
    Default = false,
    Callback = function(state)
        if state then
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/ZenitsuScripter/pickon/main/on.lua"))()
            end)
        else
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/ZenitsuScripter/hgygfvbhygf/main/off.lua"))()
            end)
        end
    end
})

-- ===========
-- ABA DISCORD
-- ===========
Tabs.Discord:AddParagraph({
    Title = "Official Sui Hub Server",
    Content = "Join our community to receive updates and support!"
})

Tabs.Discord:AddButton({
    Title = "Copy Discord Link",
    Description = "Copy the invite link to the clipboard",
    Callback = function()
        setclipboard("https://discord.gg/MG7EPpfWwu")
        Fluent:Notify({
            Title = "Link Copied!",
            Content = "The Discord invite has been copied to the clipboard",
            Duration = 5
        })
    end
})

Window:SelectTab(1)
