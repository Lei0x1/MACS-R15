
local ServerConfig = {
----------------------------------------------------------------------------------------------------
-----------------=[ General ]=----------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
	 TeamKill = true					--- Enable TeamKill?
	,TeamDmgMult = 1					--- Between 0-1 | This will make you cause less damage if you hit your teammate
	
	,ReplicatedBullets = true			--- Keep in mind that some bullets will pass through surfaces...
	
	,AntiBunnyHop = true				--- Enable anti bunny hop system?
	,JumpCoolDown = 1.5					--- Seconds before you can jump again
	,JumpPower = 50						--- Jump power, default is 50
	
	,RealisticLaser = true				--- True = Laser line is invisible
	,ReplicatedLaser = true				
	,ReplicatedFlashlight = true
	
	,EnableRagdoll = true				--- Enable ragdoll death?
	,TeamTags = true					--- Aaaaaaa
	,HitmarkerSound = false				--- GGWP MLG 360 NO SCOPE xD
	,Crosshair = false					--- Crosshair for Hipfire shooters and arcade modes
	,CrosshairOffset = 5				--- Crosshair size offset
----------------------------------------------------------------------------------------------------
------------------=[ Core GUI ]=--------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
	,CoreGuiHealth = false				--- Enable Health Bar?
	,CoreGuiPlayerList = true			--- Enable Player List?
	,TopBarTransparency = 1
----------------------------------------------------------------------------------------------------
------------------=[ Status UI ]=-------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
	,EnableStatusUI 	= true				--- Don't disabled it...
	,RunWalkSpeed 		= 24
	,NormalWalkSpeed 	= 12
	,SlowPaceWalkSpeed 	= 6	
	,CrouchWalkSpeed 	= 6
	,ProneWalksSpeed 	= 3
	
	,InjuredWalksSpeed 		= 8
	,InjuredCrouchWalkSpeed = 4

	,EnableHunger = true				--- Hunger and Thirst system 		(Removed)
	,HungerWaitTime = 25

	,CanDrown = true 					--- Glub glub glub *ded*
	
	,EnableStamina = true 				--- Weapon Sway based on stamina	(Unused)
	,RunValue = 1						--- Stamina consumption
	,StandRecover = .25					--- Stamina recovery while stading
	,CrouchRecover = .5					--- Stamina recovery while crouching
	,ProneRecover = 1					--- Stamina recovery while lying

	,EnableGPS = true					--- GPS shows your allies around you
	,GPSdistance = 150

	,InteractionMenuKey = Enum.KeyCode.LeftAlt
	
	,BuildingEnabled = true
	,BuildingKey = Enum.KeyCode.RightAlt
----------------------------------------------------------------------------------------------------
----------------=[ Medic System ]=------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
	,EnableMedSys = true
	,BleedDamage = 30					--- The damage needed to start bleeding
	,InjuredDamage = 45					--- The damage needed to get injured
	,KODamage = 85						--- The damage needed to pass out
	,PainMult = 1.5						--- 
	,BloodMult = 1.75					--- 

	,EnableFallDamage = true			--- Enable Fall Damage?
	,MaxVelocity = 75					--- Velocity that will trigger the damage
	,DamageMult = 1 					--- The min time a player has to fall in order to take fall damage.
----------------------------------------------------------------------------------------------------
--------------------=[ Others ]=--------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
	,VehicleMaxZoom = 150
	
	,AgeRestrictEnabled = true
	,AgeLimit = 60
	
	,WaterMark = true
	
	,Blacklist = {1363303139, 112962460, 115267378, 496075583} 		--- Auto kick the player (via ID) when he tries to join
	
	,Version = "ACS 2.0 - R15"
----------------------------------------------------------------------------------------------------
--------------------=[ RCM ]=--------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
	,ShellLimit = 100
	,ShellDespawn = 30
}

return ServerConfig
