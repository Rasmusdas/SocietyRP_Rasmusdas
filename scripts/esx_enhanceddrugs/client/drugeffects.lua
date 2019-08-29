
RegisterNetEvent("esx_drugs:activate_coke")
AddEventHandler("esx_drugs:activate_coke",function()
    local playerPed = PlayerId()
	if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
		TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_SMOKING_POT", 0, true)
		Citizen.Wait(10000)
		ClearPedTasks(PlayerPedId())
	else
		Citizen.Wait(10000)
	end	
    SetRunSprintMultiplierForPlayer(playerPed,1.2)
    SetTimecycleModifier("spectator1")
    Citizen.Wait(30000)
    SetTimecycleModifier("default")
    SetRunSprintMultiplierForPlayer(playerPed,1.0)
end)

RegisterNetEvent("esx_drugs:convert")
AddEventHandler("esx_drugs:convert",function(time, ctext)
	if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
		TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
		Citizen.Wait(time)
		ClearPedTasks(PlayerPedId())
	else
		Citizen.Wait(time)
	end	
end)

RegisterNetEvent("esx_drugs:UsableUSB")
AddEventHandler("esx_drugs:UsableUSB",function()
	if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
		TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
		Citizen.Wait(15000)
		ClearPedTasks(PlayerPedId())
	else
		Citizen.Wait(15000)
	end
end)