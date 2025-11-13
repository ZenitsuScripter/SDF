-- Performance Boost Script - Otimização Suave sem Micro Lags
-- Aplica mudanças gradualmente para evitar travamentos

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Prevenir execução múltipla
if _G.PerformanceBoostActive then 
	warn("Performance Boost já está ativo!")
	return 
end
_G.PerformanceBoostActive = true

print("🚀 Performance Boost - Iniciando otimização suave...")

-- Salvar configurações
local savedSettings = {
	QualityLevel = nil,
	GlobalShadows = Lighting.GlobalShadows,
	Atmosphere = {},
	Clouds = {},
	WaterSettings = {}
}

-- ETAPA 1: Reduzir qualidade gráfica
local function optimizeGraphicsQuality()
	print("⚡ [1/5] Otimizando qualidade gráfica...")
	
	pcall(function()
		local renderSettings = settings().Rendering
		savedSettings.QualityLevel = renderSettings.QualityLevel
		renderSettings.QualityLevel = Enum.QualityLevel.Level01
	end)
	
	task.wait(2)
end

-- ETAPA 2: Desabilitar efeitos visuais pesados GRADUALMENTE
local function disableHeavyEffects()
	print("⚡ [2/5] Desabilitando efeitos visuais pesados...")
	
	-- Desabilitar efeitos um por um com delay
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

-- ETAPA 3: Otimizar atmosfera e nuvens SUAVEMENTE
local function optimizeAtmosphere()
	print("⚡ [3/5] Otimizando atmosfera...")
	
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		-- Salvar valores originais
		savedSettings.Atmosphere = {
			Density = atmosphere.Density,
			Offset = atmosphere.Offset,
			Glare = atmosphere.Glare,
			Haze = atmosphere.Haze
		}
		
		-- Reduzir GRADUALMENTE (sem fazer desaparecer de uma vez)
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
	
	task.wait(1)
end

-- ETAPA 4: Otimizar partículas em background (SEM TRAVAR)
local function optimizeParticles()
	print("⚡ [4/5] Otimizando partículas...")
	
	task.spawn(function()
		local descendants = Workspace:GetDescendants()
		local batchSize = 50 -- Lotes menores para não travar
		local total = #descendants
		
		for i = 1, total, batchSize do
			for j = i, math.min(i + batchSize - 1, total) do
				local obj = descendants[j]
				pcall(function()
					-- Reduz 80% das partículas
					if obj:IsA("ParticleEmitter") then
						if obj.Enabled and obj.Rate > 0 then
							obj.Rate = math.max(obj.Rate * 0.2, 1)
						end
					elseif obj:IsA("Trail") then
						if obj.Enabled then
							obj.Lifetime = math.max(obj.Lifetime * 0.2, 0.1)
						end
					-- Desabilita efeitos legados pesados
					elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
						if obj.Enabled then
							obj.Enabled = false
						end
					end
				end)
			end
			
			-- Delay entre lotes para não travar
			task.wait(0.05)
		end
		
		print("  ✓ Partículas otimizadas")
	end)
	
	-- Otimizar novos objetos automaticamente
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

-- ETAPA 5: Otimizações finais SUAVES
local function finalOptimizations()
	print("⚡ [5/5] Aplicando otimizações finais...")
	
	-- Desabilitar sombras
	Lighting.GlobalShadows = false
	task.wait(0.5)
	
	-- Otimizar água gradualmente
	if Workspace.Terrain then
		savedSettings.WaterSettings = {
			Reflectance = Workspace.Terrain.WaterReflectance,
			WaveSize = Workspace.Terrain.WaterWaveSize,
			WaveSpeed = Workspace.Terrain.WaterWaveSpeed
		}
		
		-- Reduzir gradualmente para não dar lag
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
	
	-- Otimizar personagens em background
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
			task.wait(0.2) -- Delay entre players
		end
	end)
	
	-- Otimizar novos players
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

-- Função principal de otimização
local function startOptimization()
	local startTime = tick()
	
	-- Executar todas as etapas com delays maiores
	optimizeGraphicsQuality()
	disableHeavyEffects()
	optimizeAtmosphere()
	optimizeParticles()
	finalOptimizations()
	
	local elapsedTime = math.floor(tick() - startTime)
	
	print("✅ Performance Boost ativado com sucesso!")
	print(string.format("⏱️ Tempo de otimização: %ds", elapsedTime))
	print("🎮 Otimização completa! FPS deve estar melhor agora.")
end

-- Iniciar otimização automaticamente
task.spawn(startOptimization)
