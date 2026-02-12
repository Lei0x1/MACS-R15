local Char 			= script.Parent.Parent
local human 		= Char:WaitForChild("Humanoid")
local ACS_Client 	= script.Parent
local PastaVar 		= script.Parent:WaitForChild("Variaveis")
local PastasStan 	= script.Parent:WaitForChild("Stances")
local ultimavida 	= human.MaxHealth

local Sang 			= PastaVar.Sangue
local Dor 			= PastaVar.Dor
local MLs 			= PastaVar.MLs

local Ragdoll 		= require(game.ReplicatedStorage.ACS_Engine.Modules.Ragdoll)
local configuracao 	= require(game.ReplicatedStorage.ACS_Engine.GameRules.Config)

local debounce = true

if configuracao.EnableRagdoll == true then
	Char.Humanoid.Died:Connect(function()
		Ragdoll(Char)
	end)
end

human.HealthChanged:Connect(function(Health)

	if (Health- ultimavida < 0) then
		Sang.Value = Sang.Value + (Health - ultimavida)*((configuracao.BloodMult)*(configuracao.BloodMult)*(configuracao.BloodMult))
		Dor.Value = math.clamp(Dor.Value+ (Health - ultimavida)*(-configuracao.PainMult), 0, 300)
		MLs.Value = MLs.Value + ((ultimavida - Health) * (configuracao.BloodMult))
	end	
	
	if Health < ultimavida - configuracao.BleedDamage then
		ACS_Client:SetAttribute("Bleeding",true)
	end
	
	if Health < ultimavida - configuracao.InjuredDamage then
		ACS_Client:SetAttribute("Injured",true)
	end
	
	if Health < ultimavida - configuracao.KODamage then
		ACS_Client:SetAttribute("Collapsed",true)
	end	
	
	ultimavida = Health
end)

while configuracao.EnableMedSys do
	if ACS_Client:GetAttribute("Bleeding") then
		if ACS_Client:GetAttribute("Tourniquet")then
			Sang.Value = (Sang.Value - 0.5)
		else
			Sang.Value = (Sang.Value - (MLs.Value/120))
			MLs.Value =  math.max(0,MLs.Value + 0.025)
		end
	end

	if ACS_Client:GetAttribute("Tourniquet") then
		Dor.Value = math.clamp(Dor.Value + 0.05, 0, 300)
	end

	if human.Health >= human.MaxHealth and not ACS_Client:GetAttribute("Bleeding") then
		Sang.Value = Sang.Value + 0.05	
		Dor.Value = math.clamp(Dor.Value - 0.025, 0, 300)
		MLs.Value =  math.max(0,MLs.Value - 0.1)
	end

	if Sang.Value <= 0 then
		human.Health = 0
	end

	if Sang.Value >= 3500 and Dor.Value < 200 and ACS_Client:GetAttribute("Collapsed") and debounce then
		spawn(function(timer)
			debounce = false
			wait(math.random(60,120))
			if Sang.Value >= 3500 and Dor.Value < 200 and ACS_Client:GetAttribute("Collapsed") then
				ACS_Client:SetAttribute("Collapsed",false)
			end
			debounce = true	
		end)
	end
	wait()
end




-- Quero um pouco de credito,plox :P --
--  FEITO 100% POR SCORPION --
-- Oficial Release 2.0 --
