-- Performance Boost Script - Otimização Completa
-- Carrega automaticamente e otimiza o jogo

-- Prevenir execução múltipla
if _G.PerformanceBoostActive then 
	warn("Performance Boost já está ativo!")
	return 
end
_G.PerformanceBoostActive = true

print("🚀 Performance Boost - Iniciando...")

-- Services
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Salvar configurações originais
local savedSettings = {
	QualityLevel = nil,
	GlobalShadows = Lighting.GlobalShadows,
	Atmosphere = {},
	Clouds = {},
	WaterSettings = {}
}

-- ETAPA 1: Qualidade gráfica
local function step1_GraphicsQuality()
	print("⚡ [1/6] Otimizando qualidade gráfica...")
	
	pcall(function()
		local renderSettings = settings().Rendering
		savedSettings.QualityLevel = renderSettings.QualityLevel
		renderSettings.QualityLevel = Enum.QualityLevel.Level01
		renderSettings.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
	end)
	
	pcall(function()
		UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
	end)
	
	task.wait(2)
end

-- ETAPA 2: Texturas e materiais
local function step2_OptimizeTextures()
	print("⚡ [2/6] Otimizando texturas...")
	
	task.spawn(function()
		local descendants = Workspace:GetDescendants()
		local batchSize = 100
		
		for i = 1, #descendants, batchSize do
			for j = i, math.min(i + batchSize - 1, #descendants) do
				local obj = descendants[j]
				pcall(function()
					if obj:IsA("Decal") or obj:IsA("Texture") then
						obj.Transparency = 1
					elseif obj:IsA("SurfaceAppearance") then
						obj.TexturePack = ""
					elseif obj:IsA("MeshPart") then
						obj.Material = Enum.Material.SmoothPlastic
						obj.TextureID = ""
					elseif obj:IsA("Part") or obj:IsA("UnionOperation") then
						if obj.Material ~= Enum.Material.ForceField then
							obj.Material = Enum.Material.SmoothPlastic
						end
					end
				end)
			end
			task.wait(0.03)
		end
		print("  ✓ Texturas otimizadas")
	end)
	
	task.wait(2)
end

-- ETAPA 3: Efeitos visuais pesados
local function step3_DisableEffects()
	print("⚡ [3/6] Desabilitando efeitos...")
	
	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if bloom then 
		bloom.Enabled = false
		task.wait(0.5)
	end
	
	local blur = Lighting:FindFirstChildOfClass("BlurEffect")
	if blur then 
		blur.Enabled = false
		task.wait(0.5)
	end
	
	local sunRays = Lighting:FindFirstChildOfClass("SunRaysEffect")
	if sunRays then 
		sunRays.Enabled = false
		task.wait(0.5)
	end
	
	local depthOfField = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
	if depthOfField then 
		depthOfField.Enabled = false
		task.wait(0.5)
	end
	
	local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if colorCorrection then 
		colorCorrection.Enabled = false
		task.wait(0.5)
	end
	
	task.wait(1)
end

-- ETAPA 4: Atmosfera
local function step4_OptimizeAtmosphere()
	print("⚡ [4/6] Otimizando atmosfera...")
	
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		savedSettings.Atmosphere = {
			Density = atmosphere.Density,
			Offset = atmosphere.Offset,
			Glare = atmosphere.Glare,
			Haze = atmosphere.Haze
		}
		
		local steps = 10
		local targetDensity = math.min(atmosphere.Density * 0.2, 0.1)
		local densityStep = (atmosphere.Density - targetDensity) / steps
		
		for i = 1, steps do
			atmosphere.Density = atmosphere.Density - densityStep
			task.wait(0.1)
		end
		
		atmosphere.Offset = 0
		atmosphere.Glare = 0
		atmosphere.Haze = 0
	end
	
	local clouds = Lighting:FindFirstChildOfClass("Clouds")
	if clouds then
		savedSettings.Clouds.Enabled = clouds.Enabled
		clouds.Enabled = false
	end
	
	Lighting.ChildAdded:Connect(function(child)
		task.wait(0.1)
		if child:IsA("Atmosphere") then
			child.Density = 0.1
			child.Offset = 0
			child.Glare = 0
			child.Haze = 0
		elseif child:IsA("Clouds") then
			child.Enabled = false
		end
	end)
	
	task.wait(1)
end

-- ETAPA 5: Partículas
local function step5_OptimizeParticles()
	print("⚡ [5/6] Otimizando partículas...")
	
	task.spawn(function()
		local descendants = Workspace:GetDescendants()
		local batchSize = 50
		local total = #descendants
		
		for i = 1, total, batchSize do
			for j = i, math.min(i + batchSize - 1, total) do
				local obj = descendants[j]
				pcall(function()
					if obj:IsA("ParticleEmitter") then
						if obj.Enabled and obj.Rate > 0 then
							obj.Rate = math.max(obj.Rate * 0.2, 1)
						end
					elseif obj:IsA("Trail") then
						if obj.Enabled then
							obj.Lifetime = math.max(obj.Lifetime * 0.2, 0.1)
						end
					elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
						if obj.Enabled then
							obj.Enabled = false
						end
					end
				end)
			end
			task.wait(0.05)
		end
		print("  ✓ Partículas otimizadas")
	end)
	
	Workspace.DescendantAdded:Connect(function(obj)
		task.wait(0.1)
		pcall(function()
			if obj:IsA("ParticleEmitter") and obj.Enabled and obj.Rate > 0 then
				obj.Rate = math.max(obj.Rate * 0.2, 1)
			elseif obj:IsA("Trail") and obj.Enabled then
				obj.Lifetime = math.max(obj.Lifetime * 0.2, 0.1)
			elseif (obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles")) and obj.Enabled then
				obj.Enabled = false
			end
		end)
	end)
	
	task.wait(2)
end

-- ETAPA 6: Otimizações finais
local function step6_FinalOptimizations()
	print("⚡ [6/6] Otimizações finais...")
	
	Lighting.GlobalShadows = false
	task.wait(0.5)
	
	if Workspace.Terrain then
		savedSettings.WaterSettings = {
			Reflectance = Workspace.Terrain.WaterReflectance,
			WaveSize = Workspace.Terrain.WaterWaveSize,
			WaveSpeed = Workspace.Terrain.WaterWaveSpeed
		}
		
		for i = 1, 10 do
			Workspace.Terrain.WaterReflectance = Workspace.Terrain.WaterReflectance * 0.7
			Workspace.Terrain.WaterWaveSize = Workspace.Terrain.WaterWaveSize * 0.7
			Workspace.Terrain.WaterWaveSpeed = Workspace.Terrain.WaterWaveSpeed * 0.7
			task.wait(0.1)
		end
		
		Workspace.Terrain.WaterReflectance = 0
		Workspace.Terrain.WaterWaveSize = 0
		Workspace.Terrain.WaterWaveSpeed = 0
	end
	
	task.wait(0.5)
	
	task.spawn(function()
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= Players.LocalPlayer and player.Character then
				task.spawn(function()
					for _, descendant in pairs(player.Character:GetDescendants()) do
						pcall(function()
							if descendant:IsA("MeshPart") then
								descendant.RenderFidelity = Enum.RenderFidelity.Performance
							end
						end)
					end
				end)
			end
			task.wait(0.2)
		end
	end)
	
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			task.wait(1)
			task.spawn(function()
				for _, descendant in pairs(character:GetDescendants()) do
					pcall(function()
						if descendant:IsA("MeshPart") then
							descendant.RenderFidelity = Enum.RenderFidelity.Performance
						end
					end)
				end
			end)
		end)
	end)
	
	task.wait(1)
end

-- Executar otimização
local function startOptimization()
	local startTime = tick()
	
	step1_GraphicsQuality()
	step2_OptimizeTextures()
	step3_DisableEffects()
	step4_OptimizeAtmosphere()
	step5_OptimizeParticles()
	step6_FinalOptimizations()
	
	local elapsedTime = math.floor(tick() - startTime)
	
	print("✅ Performance Boost ativado!")
	print(string.format("⏱️ Tempo: %ds", elapsedTime))
	print("🎮 FPS melhorado!")
end

task.spawn(startOptimization)
