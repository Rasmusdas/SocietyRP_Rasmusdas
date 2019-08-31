ESX = nil
local weaponStorage = {}
local isInService = false
Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(5)

		TriggerEvent("esx:getSharedObject", function(library)
			ESX = library
		end)
		ESX.UI.Menu.CloseAll()
	end
	Citizen.Wait(250)
	ESX.TriggerServerCallback("qalle_policearmory:checkStorage", function(stock) end)
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(response)
	ESX.PlayerData = response
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(response)
	ESX.PlayerData["job"] = response
end)

Citizen.CreateThread(function()
	Citizen.Wait(1000)
	while true do
		if isInService then
			local ped = GetPlayerPed(-1)
			local pos = GetEntityCoords(ped)
			for k,v in pairs(Config.Armory) do
				local dstCheck = GetDistanceBetweenCoords(v.x,v.y,v.z,pos.x,pos.y,pos.z,false)
				if dstCheck <= 100.0 then
					DrawMarker(Config.ArmoryMarker, v.x,v.y,v.z, 0.0, 0.0, 0.0, 0.0, 0, 0.0, 1.0, 1.0, 1.0, Config.ArmoryMarkerColor.r,Config.ArmoryMarkerColor.g,Config.ArmoryMarkerColor.b,Config.ArmoryMarkerColor.a, false, true, 2, true, false, false, false)						
					if dstCheck <= 0.5 then
						ESX.ShowHelpNotification("Tryk på ~INPUT_CONTEXT~ for at tilgå ~y~Våben Arsenalet~s~")
						if IsControlJustPressed(0, 38) then
							OpenPoliceArmory()
						end
					end
				end
			end
			for k,v in pairs(Config.Kevlar) do
				local dstCheck = GetDistanceBetweenCoords(v.x,v.y,v.z,pos.x,pos.y,pos.z,false)
				if dstCheck <= 100.0 then
					DrawMarker(Config.ArmoryMarker, v.x,v.y,v.z, 0.0, 0.0, 0.0, 0.0, 0, 0.0, 1.0, 1.0, 1.0, Config.ArmoryMarkerColor.r,Config.ArmoryMarkerColor.g,Config.ArmoryMarkerColor.b,Config.ArmoryMarkerColor.a, false, true, 2, true, false, false, false)						
					if dstCheck <= 0.5 then
						ESX.ShowHelpNotification("Tryk på ~INPUT_CONTEXT~ for at tilgå ~y~Kevlar Skabet~s~")
						if IsControlJustPressed(0, 38) then
							KevlarMenu()
						end
					end
				end
			end
			for k,v in pairs(Config.Attachment) do
				local dstCheck = GetDistanceBetweenCoords(v.x,v.y,v.z,pos.x,pos.y,pos.z,false)
				if dstCheck <= 100.0 then
					DrawMarker(Config.ArmoryMarker, v.x,v.y,v.z, 0.0, 0.0, 0.0, 0.0, 0, 0.0, 1.0, 1.0, 1.0, Config.ArmoryMarkerColor.r,Config.ArmoryMarkerColor.g,Config.ArmoryMarkerColor.b,Config.ArmoryMarkerColor.a, false, true, 2, true, false, false, false)						
					if dstCheck <= 0.5 then
						ESX.ShowHelpNotification("Tryk på ~INPUT_CONTEXT~ for at tilgå ~y~Attachment Skab~s~")
						if IsControlJustPressed(0, 38) then
							AttachmentMenu()
						end
					end
				end
			end
		end
		Citizen.Wait(5)
	end
end)

OpenPoliceArmory = function()
	PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)

	local elements = {
		{ label = "Våben lager", action = "weapon_storage" },
		
	}
	--if ESX.PlayerData.job.grade > Config.RequiredRefillGrade then
	if ESX.PlayerData.job.grade_name == 'boss' or ESX.PlayerData.job.grade_name == 'captain' or ESX.PlayerData.job.grade_name == 'lieutenant' or ESX.PlayerData.job.grade_name == 'sfsergeant' then
		table.insert(elements, {label = "Restock Våben", action = "fill_up"})
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "police_armory_menu",
		{
			title    = "Våben Arsenal",
			align    = "center",
			elements = elements
		},
	function(data, menu)
		local action = data.current.action

		if action == "weapon_storage" then
			OpenWeaponStorage()
		elseif action == "fill_up" then
			RestockWeapon()
		end	

	end, function(data, menu)
		PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)

		menu.close()
	end, function(data, menu)
		PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
	end)
end

OpenWeaponStorage = function()
	PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
	local storage = nil
	local elements = {}
	local ped = GetPlayerPed(-1)
	ESX.TriggerServerCallback("qalle_policearmory:checkStorage", function(stock)	
	local weapons = WeapSplit(stock[1].weapons, ", ")
	for k,v in pairs(Config.ArmoryWeapons) do
		local yes = false
		for z,x in pairs(weapons) do
			if x == v.weaponHash then
				yes = true
				table.insert(elements,{label = v.name .. " | Taget ud", weaponhash = v.weaponHash, lendable = false})
			end
		end
		if yes == false then
			table.insert(elements,{label = v.name .. " | På lager", weaponhash = v.weaponHash, lendable = true})
		end
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "police_armory_weapon_menu",
		{
			title    = "Våben Lager",
			align    = "center",
			elements = elements
		},
	function(data, menu)
		menu.close()
		
		if data.current.lendable == true then
			print(data.current.weaponhash)
			local giveAmmo = (GetWeaponClipSize(GetHashKey(data.current.weaponhash)) > 0)
			if data.current.weaponhash == "WEAPON_STUNGUN" then
				giveAmmo = false
			end
			TriggerServerEvent("qalle_policearmory:giveWeapon", data.current.weaponhash, giveAmmo)
			TriggerServerEvent("qalle_policearmory:addToLend", data.current.weaponhash)
		elseif PedHasWeapon(data.current.weaponhash) then
			local giveAmmo = (GetWeaponClipSize(GetHashKey(data.current.weaponhash)) > 0)
			if data.current.weaponhash == "WEAPON_STUNGUN" then
				giveAmmo = false
			end
			TriggerServerEvent("qalle_policearmory:removeWeapon", data.current.weaponhash,GetAmmoInPedWeapon(ped,GetHashKey(data.current.weaponhash)),giveAmmo)
			TriggerServerEvent("qalle_policearmory:remToLend", data.current.weaponhash)
		else
			ESX.ShowNotification("Du har allerede taget dette våben ud, kontakt en supervisor!")
		end
	end, function(data, menu)
		PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
		menu.close()
	end, function(data, menu)
		PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
	end)
	end)
	
	
end

local CachedModels = {}

LoadModels = function(models)
	for modelIndex = 1, #models do
		local model = models[modelIndex]

		table.insert(CachedModels, model)

		if IsModelValid(model) then
			while not HasModelLoaded(model) do
				RequestModel(model)
	
				Citizen.Wait(10)
			end
		else
			while not HasAnimDictLoaded(model) do
				RequestAnimDict(model)
	
				Citizen.Wait(10)
			end    
		end
	end
end

UnloadModels = function()
	for modelIndex = 1, #CachedModels do
		local model = CachedModels[modelIndex]

		if IsModelValid(model) then
			SetModelAsNoLongerNeeded(model)
		else
			RemoveAnimDict(model)   
		end

		table.remove(CachedModels, modelIndex)
	end
end

function KevlarMenu()
	local ped = GetPlayerPed(-1)
	local elements = {}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "police_armory_weapon_menu",
			{
				title    = "Kevlar Skab",
				align    = "center",
				elements = {
					{label = "Super Let Vest", armor = 25},
					{label = "Let Vest", armor = 50},
					{label = "Vest", armor = 75},
					{label = "Tung Vest", armor = 100},
					{label = "Fjern Vest", armor = 0},
			}
			},
		function(data, menu)
			PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
			SetPedArmour(ped,data.current.armor)
			menu.close()
		end, function(data, menu)
			PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
			menu.close()
		end, function(data, menu)
			PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
		end)
end

function RestockWeapon()
	local people = {}
	local elements = {}
	PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
	ESX.TriggerServerCallback("qalle_policearmory:superCheck", function(list) people = list end)
	Citizen.Wait(250)
	for k,v in pairs(people) do
		if v.job.name == "police" then
			table.insert(elements, {label = v.name, id = v.id})
		end
	end
	if next(elements) ~= nil then
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), "police_armory_weapon_menu",
			{
				title    = "Restock Våben",
				align    = "center",
				elements = elements
			},
		function(data, menu)
			menu.close()
		TriggerServerEvent("qalle_policearmory:SuperRemLend",data.current.id)
		end, function(data, menu)
			PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
			
			menu.close()
		end, function(data, menu)
			PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
		end)
	else
		ESX.ShowNotification("Der er ikke politi online")
	end
end


RegisterNetEvent('policearmory:service')
AddEventHandler('policearmory:service', function(state)	
	isInService = state
end)


function WeapSplit(inputstr, del)
    if del == nil then
            del = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..del.."]+)") do
            table.insert(t, str)
    end
    return t
end

function PedHasWeapon(hash)
	for k,v in pairs(ESX.GetPlayerData().loadout) do
		if v.name == hash then
			return true
		end
	end
	return false
end

function AttachmentMenu()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "police_armory_menu",
		{
			title    = "Våben Attachments",
			align    = "center",
			elements = {
				{label = "Få Attachments", attachment}
				--{label = "Husk at have det pågældende våben i hånden"}
			}
		},
	function(data, menu)
		local attachment = data.current.attachment
		GiveWeaponComponentToPed(GetPlayerPed(-1),GetSelectedPedWeapon(GetPlayerPed(-1)),0x43FD595B)
		GiveWeaponComponentToPed(GetPlayerPed(-1),GetSelectedPedWeapon(GetPlayerPed(-1)),0x7BC4CDDC)
		GiveWeaponComponentToPed(GetPlayerPed(-1),GetSelectedPedWeapon(GetPlayerPed(-1)),0x49B2945)
		GiveWeaponComponentToPed(GetPlayerPed(-1),GetSelectedPedWeapon(GetPlayerPed(-1)),0x3CC6BA57)
		

	end, function(data, menu)
		PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)

		menu.close()
	end, function(data, menu)
		PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
	end)
end