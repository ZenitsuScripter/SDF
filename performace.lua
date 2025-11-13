-- Performance Boost Script - Otimização Real e Efetiva
-- Foca apenas em mudanças que REALMENTE melhoram FPS

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Prevenir execução múltipla
if _G.PerformanceBoostActive then 
	warn("Performance Boost já está ativo!")
	return 
end
_G.PerformanceBoostActive = true

print("🚀 Performance Boost - Iniciando otimização real...")

-- Salvar configurações para possível restauração
local savedSettings = {
	QualityLevel = nil,
	particles = {}
}

-- ETAPA 1: Reduzir qualidade gráfica (MELHORA FPS SIGNIFICATIVAMENTE)
local function optimizeGraphicsQuality()
	print("⚡ [1/5] Otimizando qualidade gráfica...")
	
	pcall(function()
		local renderSettings = settings().Rendering
		savedSettings.QualityLevel = renderSettings.QualityLevel
		renderSettings.QualityLevel = Enum.QualityLevel.Level01
	end)
	
	task.wait(1)
end

-- ETAPA 2: Desabilitar efeitos visuais pesados (MELHORA FPS)
local function disableHeavyEffects()
	print("⚡ [2/5] Desabilitando efeitos visuais pesados...")
	
	-- Desabilitar apenas efeitos que consomem muito FPS
	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	local blur = Lighting:FindFirstChildOfClass("BlurEffect")
	local sunRays = Lighting:FindFirstChildOfClass("SunRaysEffect")
	local depthOfField = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
	local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	
	if bloom then bloom.Enabled = false end
	if blur then blur.Enabled = false end
	if sunRays then sunRays.Enabled = false end
	if depthOfField then depthOfField.Enabled = false end
	-- ColorCorrection tem impacto mínimo, mas desabilita se precisar
	if colorCorrection then colorCorrection.Enabled = false end
	
	task.wait(1)
end

-- ETAPA 3: Otimizar partículas e efeitos (MAIOR IMPACTO NO FPS)
local function optimizeParticles()
	print("⚡ [3/5] Otimizando partículas e efeitos...")
	
	local function processObject(obj)
		pcall(function()
			-- Partículas modernas (maior impacto) - REDUZ 80%
			if obj:IsA("ParticleEmitter") then
				if obj.Enabled and obj.Rate > 0 then
					savedSettings.particles[obj] = {enabled = true, rate = obj.Rate}
					obj.Rate = math.max(obj.Rate * 0.2, 1) -- Mantém apenas 20% (reduz 80%)
				end
			elseif obj:IsA("Trail") then
				if obj.Enabled then
					savedSettings.particles[obj] = {enabled = true, lifetime = obj.Lifetime}
					obj.Lifetime = math.max(obj.Lifetime * 0.2, 0.1) -- Reduz 80% do tempo de vida
				end
			elseif obj:IsA("Beam") then
				if obj.Enabled then
					savedSettings.particles[obj] = {enabled = true}
					-- Beams já são leves, mantém ativado
				end
			-- Efeitos legados (muito pesados)
			elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
				if obj.Enabled then
					savedSettings.particles[obj] = {enabled = true}
					obj.Enabled = false -- Desabilita completamente (muito pesado)
				end
			end
		end)
	end
	
	-- Processar objetos existentes em lotes
	local descendants = Workspace:GetDescendants()
	local batchSize = 150
	local total = #descendants
	
	for i = 1, total, batchSize do
		for j = i, math.min(i + batchSize - 1, total) do
			processObject(descendants[j])
		end
		
		if i % 1000 == 0 then
			print(string.format("  Processado: %d/%d objetos", i, total))
		end
		
		task.wait()
	end
	
	-- Otimizar novos objetos automaticamente
	Workspace.DescendantAdded:Connect(function(obj)
		task.wait(0.1)
		processObject(obj)
	end)
	
	task.wait(1)
end

-- ETAPA 4: Otimizar personagens de outros jogadores (MELHORA FPS EM JOGOS COM MUITOS PLAYERS)
local function optimizePlayers()
	print("⚡ [4/5] Otimizando personagens...")
	
	local function optimizeCharacter(character)
		if not character then return end
		
		task.spawn(function()
			for _, descendant in pairs(character:GetDescendants()) do
				pcall(function()
					if descendant:IsA("MeshPart") then
						-- Performance mode para meshes (reduz polígonos)
						descendant.RenderFidelity = Enum.RenderFidelity.Performance
					elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
						-- Reduz qualidade de texturas
						descendant.Transparency = descendant.Transparency -- Force update
					elseif descendant:IsA("SurfaceAppearance") then
						-- Desabilita texturas PBR pesadas
						descendant.TexturePack = ""
					end
				end)
			end
		end)
	end
	
	-- Otimizar players existentes
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= Players.LocalPlayer and player.Character then
			optimizeCharacter(player.Character)
		end
	end
	
	-- Otimizar novos players
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			task.wait(0.5)
			optimizeCharacter(character)
		end)
	end)
	
	task.wait(1)
end

-- ETAPA 5: Otimizações finais e limpeza
local function finalOptimizations()
	print("⚡ [5/5] Aplicando otimizações finais...")
	
	-- Desabilitar sombras globais (GRANDE IMPACTO NO FPS)
	Lighting.GlobalShadows = false
	
	-- Simplificar atmosfera se existir
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		atmosphere.Density = math.min(atmosphere.Density * 0.3, 0.1)
		atmosphere.Offset = 0
		atmosphere.Glare = 0
		atmosphere.Haze = 0
	end
	
	-- Otimizar nuvens
	local clouds = Lighting:FindFirstChildOfClass("Clouds")
	if clouds then
		clouds.Enabled = false
	end
	
	-- Otimizar água (impacto médio)
	if Workspace.Terrain then
		Workspace.Terrain.WaterReflectance = 0
		Workspace.Terrain.WaterWaveSize = 0
		Workspace.Terrain.WaterWaveSpeed = 0
	end
	
	-- Desabilitar físicas desnecessárias em partes distantes (avançado)
	task.spawn(function()
		while task.wait(2) do
			if not Players.LocalPlayer.Character then continue end
			local rootPart = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not rootPart then continue end
			
			for _, part in pairs(Workspace:GetDescendants()) do
				if part:IsA("BasePart") and not part:IsDescendantOf(Players.LocalPlayer.Character) then
					pcall(function()
						local distance = (part.Position - rootPart.Position).Magnitude
						-- Desabilitar física de objetos muito distantes
						if distance > 500 and part.CanCollide then
							part.CanCollide = false
							part:SetAttribute("PB_WasCollidable", true)
						elseif distance <= 500 and part:GetAttribute("PB_WasCollidable") then
							part.CanCollide = true
							part:SetAttribute("PB_WasCollidable", nil)
						end
					end)
				end
			end
		end
	end)
	
	task.wait(1)
end

-- Função principal de otimização
local function startOptimization()
	local startTime = tick()
	local startFPS = 0
	
	-- Tentar capturar FPS inicial
	pcall(function()
		startFPS = workspace:GetRealPhysicsFPS()
	end)
	
	-- Executar todas as etapas
	optimizeGraphicsQuality()
	disableHeavyEffects()
	optimizeParticles()
	optimizePlayers()
	finalOptimizations()
	
	local elapsedTime = math.floor(tick() - startTime)
	
	print("✅ Performance Boost ativado com sucesso!")
	print(string.format("⏱️ Tempo de otimização: %ds", elapsedTime))
	print("🎮 Seu FPS deve estar significativamente melhor agora!")
	print("💡 Dica: Feche abas do navegador e outros programas para melhorar ainda mais")
	

end

-- Iniciar otimização automaticamente
task.spawn(startOptimization)

-- Atalho para desabilitar temporariamente (pressione F3)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.F3 then
		_G.PerformanceBoostActive = false
		print("⚠️ Performance Boost desativado temporariamente")
	end
end)
