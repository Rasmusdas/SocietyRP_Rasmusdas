ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end
	PlayerData = ESX.GetPlayerData()
end)

local ped = nil
RegisterNetEvent("esx_drugnpc:spawnNpc")
AddEventHandler("esx_drugnpc:spawnNpc",function(npc,time)
	local location = npc.spot
	local heading = npc.Heading
	RequestModel(2120901815)
	while not HasModelLoaded(-459818001) do
		Citizen.Wait(100)
	end
	ped = CreatePed(7,-459818001,location.x,location.y,location.z,heading,0,true,true)
	FreezeEntityPosition(ped,true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	SetEntityInvincible(ped,true)
	Citizen.Wait(time)
	ped = nil
	SetPedAsNoLongerNeeded(ped,true)
	SetEntityCoords(ped,0,0,0)
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPos = GetEntityCoords(GetPlayerPed(-1))
		local pos = GetEntityCoords(ped)
		if GetDistanceBetweenCoords(pos,playerPos) < 2 then
			ESX.ShowHelpNotification("Tryk på ~INPUT_CONTEXT~ for at ~y~snakke~s~ med manden")
			if IsControlJustPressed(1,38) then
				OpenBurnerShop()
			end
		end
	end
end)
function OpenBurnerShop()
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'civilian_actions',
		{
			title    = "USB Stik",
			align    = 'center',
			elements = {
				{label = "Coke <b style='color:#00aa00;'>$" .. Config.Prices["Coke"] .."</b>"},
			}
		},
		function(data, menu)
			TriggerServerEvent("esx_drugNpc:buyLoc",data.current.label)
		end, function(data,menu) menu.close()end)
end

RegisterNetEvent("esx_drugnpc:StartLoc")
AddEventHandler("esx_drugnpc:StartLoc",function(type)
	CreateLocationForStick(type)
end)

function CreateLocationForStick(type)
	local num = math.random(1,#Config.StickLoc)
	local loc = Config.StickLoc[num]
	local taken = false
	RequestModel(-459818001)
	while not HasModelLoaded(-459818001) do
		Citizen.Wait(100)
	end
	local blip = CreateEndBlip(loc.Location)
	AddRelationshipGroup('DrugNPC')
	AddRelationshipGroup('PlayerPed')
	for k,v in pairs(loc.GoonSpawns) do
		pedy = CreatePed(7,-459818001,v.x,v.y,v.z,0,true,true)
		SetPedRelationshipGroupHash(pedy, 'DrugNPC')
		GiveWeaponToPed(pedy,GetHashKey("WEAPON_PISTOL"),100,false,true)
	end
	SetRelationshipBetweenGroups(5,GetPedRelationshipGroupDefaultHash(GetPlayerPed(-1)),'DrugNpc')
	SetRelationshipBetweenGroups(5,'DrugNpc',GetPedRelationshipGroupDefaultHash(GetPlayerPed(-1)))	
	while not taken do
		Citizen.Wait(10)
		if GetDistanceBetweenCoords(loc.Location, GetEntityCoords(GetPlayerPed(-1))) < 5 then
			ESX.Game.Utils.DrawText3D(loc.Location,"Tryk på ~g~[E]~s~ for at tage ~y~USB Stikket~s~",1,0)
			if IsControlJustPressed(1,38) then
				taken = true
				TriggerServerEvent("esx_drugNpc:addBurn",type)
				RemoveBlip(blip)
			end
		end
		
	end
end

function CreateEndBlip(location)
	local blip = AddBlipForCoord(location.x,location.y,location.z)
	SetBlipSprite(blip, 1)
	SetBlipColour(blip, 5)
	AddTextEntry('MYBLIP', "Position fra dealeren")
	BeginTextCommandSetBlipName('MYBLIP')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
	SetBlipScale(blip, 0.8) -- set scale
	SetBlipAsShortRange(blip, true)
	return blip
end
