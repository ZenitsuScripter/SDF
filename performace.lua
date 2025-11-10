_G.PerformanceBoost = _G.PerformanceBoost or {}

local PB = _G.PerformanceBoost
PB.isOptimized = PB.isOptimized or false
PB.savedSettings = PB.savedSettings or {}
PB.effectsCache = PB.effectsCache or {}
PB.particleConnections = PB.particleConnections or {}
PB.isProcessing = PB.isProcessing or false

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local function saveSettings()
	if next(PB.savedSettings) ~= nil then return end
	
	PB.savedSettings = {
		Brightness = Lighting.Brightness,
		GlobalShadows = Lighting.GlobalShadows,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		StreamingEnabled = Workspace.StreamingEnabled,
		FogEnd = Lighting.FogEnd,
		FogStart = Lighting.FogStart,
	}
	
	PB.effectsCache.Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	PB.effectsCache.Clouds = Lighting:FindFirstChildOfClass("Clouds")
	PB.effectsCache.Bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	PB.effectsCache.Blur = Lighting:FindFirstChildOfClass("BlurEffect")
	PB.effectsCache.SunRays = Lighting:FindFirstChildOfClass("SunRaysEffect")
	PB.effectsCache.ColorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	PB.effectsCache.DepthOfField = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
	
	if PB.effectsCache.Atmosphere then
		PB.savedSettings.Atmosphere = {
			Density = PB.effectsCache.Atmosphere.Density,
			Offset = PB.effectsCache.Atmosphere.Offset,
			Glare = PB.effectsCache.Atmosphere.Glare,
			Haze = PB.effectsCache.Atmosphere.Haze,
		}
	end
	
	if PB.effectsCache.Clouds then
		PB.savedSettings.CloudsEnabled = PB.effectsCache.Clouds.Enabled
	end
	
	if Workspace.Terrain then
		PB.savedSettings.WaterReflectance = Workspace.Terrain.WaterReflectance
		PB.savedSettings.WaterTransparency = Workspace.Terrain.WaterTransparency
		PB.savedSettings.WaterWaveSize = Workspace.Terrain.WaterWaveSize
		PB.savedSettings.WaterWaveSpeed = Workspace.Terrain.WaterWaveSpeed
		PB.savedSettings.Decoration = Workspace.Terrain.Decoration
	end
end

local function disableParticleEffectsGradual()
	task.spawn(function()
		local descendants = Workspace:GetDescendants()
		local batchSize = 50
		
		for i = 1, #descendants, batchSize do
			if not PB.isOptimized then break end
			
			for j = i, math.min(i + batchSize - 1, #descendants) do
				local obj = descendants[j]
				pcall(function()
					if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
						if obj.Enabled then
							obj.Enabled = false
							obj:SetAttribute("WasEnabled", true)
						end
					elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
						if obj.Enabled then
							obj.Enabled = false
							obj:SetAttribute("WasEnabled", true)
						end
					end
				end)
			end
			
			task.wait()
		end
	end)
end

local function enableParticleEffectsGradual()
	task.spawn(function()
		local descendants = Workspace:GetDescendants()
		local batchSize = 50
		
		for i = 1, #descendants, batchSize do
			if PB.isOptimized then break end
			
			for j = i, math.min(i + batchSize - 1, #descendants) do
				local obj = descendants[j]
				pcall(function()
					if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or
					   obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
						if obj:GetAttribute("WasEnabled") then
							obj.Enabled = true
							obj:SetAttribute("WasEnabled", nil)
						end
					end
				end)
			end
			
			task.wait()
		end
	end)
end

local function optimizeTerrain()
	if Workspace.Terrain then
		Workspace.Terrain.WaterReflectance = 0
		Workspace.Terrain.WaterTransparency = 0.5
		Workspace.Terrain.WaterWaveSize = 0
		Workspace.Terrain.WaterWaveSpeed = 0
		Workspace.Terrain.Decoration = false
	end
end

local function restoreTerrain()
	if Workspace.Terrain and PB.savedSettings.WaterReflectance then
		Workspace.Terrain.WaterReflectance = PB.savedSettings.WaterReflectance
		Workspace.Terrain.WaterTransparency = PB.savedSettings.WaterTransparency
		Workspace.Terrain.WaterWaveSize = PB.savedSettings.WaterWaveSize
		Workspace.Terrain.WaterWaveSpeed = PB.savedSettings.WaterWaveSpeed
		Workspace.Terrain.Decoration = PB.savedSettings.Decoration
	end
end

local function optimizePlayersGradual()
	task.spawn(function()
		for _, player in pairs(Players:GetPlayers()) do
			if not PB.isOptimized then break end
			if player == Players.LocalPlayer then continue end
			if not player.Character then continue end
			
			local descendants = player.Character:GetDescendants()
			for _, part in pairs(descendants) do
				pcall(function()
					if part:IsA("BasePart") then
						part.Material = Enum.Material.SmoothPlastic
						if part:IsA("MeshPart") then
							part.RenderFidelity = Enum.RenderFidelity.Performance
						end
					end
				end)
			end
			
			task.wait()
		end
	end)
end

local function restorePlayersGradual()
	task.spawn(function()
		for _, player in pairs(Players:GetPlayers()) do
			if PB.isOptimized then break end
			if player == Players.LocalPlayer then continue end
			if not player.Character then continue end
			
			local descendants = player.Character:GetDescendants()
			for _, part in pairs(descendants) do
				pcall(function()
					if part:IsA("MeshPart") then
						part.RenderFidelity = Enum.RenderFidelity.Automatic
					end
				end)
			end
			
			task.wait()
		end
	end)
end

function PB.enable()
	if PB.isOptimized or PB.isProcessing then return end
	PB.isProcessing = true
	
	saveSettings()
	PB.isOptimized = true
	
	task.spawn(function()
		local folder = Workspace:FindFirstChild("Folder")
		if folder then
			for _, v in pairs(folder:GetChildren()) do
				pcall(function() v:Destroy() end)
				task.wait()
			end
		end
		
		Lighting.GlobalShadows = false
		task.wait()
		
		Lighting.Brightness = 2
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		task.wait()
		
		Lighting.FogEnd = 9e9
		Lighting.FogStart = 0
		task.wait()
		
		if PB.effectsCache.Atmosphere then
			PB.effectsCache.Atmosphere.Density = 0
			PB.effectsCache.Atmosphere.Offset = 0
			PB.effectsCache.Atmosphere.Glare = 0
			PB.effectsCache.Atmosphere.Haze = 0
		end
		task.wait()
		
		if PB.effectsCache.Bloom then PB.effectsCache.Bloom.Enabled = false end
		if PB.effectsCache.Blur then PB.effectsCache.Blur.Enabled = false end
		task.wait()
		
		if PB.effectsCache.SunRays then PB.effectsCache.SunRays.Enabled = false end
		if PB.effectsCache.ColorCorrection then PB.effectsCache.ColorCorrection.Enabled = false end
		if PB.effectsCache.DepthOfField then PB.effectsCache.DepthOfField.Enabled = false end
		task.wait()
		
		if PB.effectsCache.Clouds then
			PB.effectsCache.Clouds.Enabled = false
		end
		task.wait()
		
		disableParticleEffectsGradual()
		optimizeTerrain()
		task.wait()
		
		PB.particleConnections.DescendantAdded = Workspace.DescendantAdded:Connect(function(obj)
			if PB.isOptimized then
				task.wait()
				if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or
				   obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
					obj.Enabled = false
				end
			end
		end)
		
		pcall(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)
		task.wait()
		
		Workspace.StreamingEnabled = true
		
		optimizePlayersGradual()
		
		PB.isProcessing = false
	end)
end

function PB.disable()
	if not PB.isOptimized or PB.isProcessing then return end
	PB.isProcessing = true
	PB.isOptimized = false
	
	task.spawn(function()
		if PB.particleConnections.DescendantAdded then
			PB.particleConnections.DescendantAdded:Disconnect()
			PB.particleConnections.DescendantAdded = nil
		end
		task.wait()
		
		Lighting.Brightness = PB.savedSettings.Brightness
		Lighting.GlobalShadows = PB.savedSettings.GlobalShadows
		task.wait()
		
		Lighting.OutdoorAmbient = PB.savedSettings.OutdoorAmbient
		Lighting.FogEnd = PB.savedSettings.FogEnd
		Lighting.FogStart = PB.savedSettings.FogStart
		task.wait()
		
		if PB.effectsCache.Atmosphere and PB.savedSettings.Atmosphere then
			PB.effectsCache.Atmosphere.Density = PB.savedSettings.Atmosphere.Density
			PB.effectsCache.Atmosphere.Offset = PB.savedSettings.Atmosphere.Offset
			PB.effectsCache.Atmosphere.Glare = PB.savedSettings.Atmosphere.Glare
			PB.effectsCache.Atmosphere.Haze = PB.savedSettings.Atmosphere.Haze
		end
		task.wait()
		
		if PB.effectsCache.Bloom then PB.effectsCache.Bloom.Enabled = true end
		if PB.effectsCache.Blur then PB.effectsCache.Blur.Enabled = true end
		task.wait()
		
		if PB.effectsCache.SunRays then PB.effectsCache.SunRays.Enabled = true end
		if PB.effectsCache.ColorCorrection then PB.effectsCache.ColorCorrection.Enabled = true end
		if PB.effectsCache.DepthOfField then PB.effectsCache.DepthOfField.Enabled = true end
		task.wait()
		
		if PB.effectsCache.Clouds and PB.savedSettings.CloudsEnabled ~= nil then
			PB.effectsCache.Clouds.Enabled = PB.savedSettings.CloudsEnabled
		end
		task.wait()
		
		enableParticleEffectsGradual()
		restoreTerrain()
		task.wait()
		
		pcall(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
		end)
		task.wait()
		
		Workspace.StreamingEnabled = PB.savedSettings.StreamingEnabled
		
		restorePlayersGradual()
		
		PB.isProcessing = false
	end)
end

function PB.isActive()
	return PB.isOptimized
end

return PB
