ESX = nil
local StopMission = false
local vehicle = nil
local peds = {}
local goon = nil
local goonvehicle = nil
local PlayerData = nil
local CurrentEventNum = nil
local missionblip = nil
local aptitude = 155
local backColor = {r = 127 ,g = 30, b = 0} -- Farven på baggrunden
local backBox = {x = 0.88, y =  0.92, width = 0.065, height = 0.060, r = 0 ,g = 0, b = 0, aptitude = 155} -- Placering og størrelse af baggrunden
local healthBox = {x = 0.89, y =  0.960, width = 0.045, height = 0.010, r = 255 ,g = 30, b = 0, aptitude = 255} -- Placering og størrelse af health boxen
local vanText = {x = 0.912, y =  0.92, scale = 0.4} -- Placering og størrelse af texen


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

RegisterCommand("startVan",function(type)
	TriggerEvent("esx_drug_van:start",type)

end)


RegisterNetEvent("esx_drug_van:start")
AddEventHandler("esx_drug_van:start",function(spot,type)
	TriggerEvent("esx_drug_van:failMission")
	local num = math.random(1,#Config.DrugVans)
	local numy = 0
	while Config.DrugVans[num].InUse and numy < 100 do
		numy = numy+1
		num = math.random(1,#Config.DrugVans)
	end
	if numy == 100 then
		ESX.ShowNotification("Der er ikke nogen ledige opgaver lige nu")
	else
		CurrentEventNum = num
		TriggerEvent("esx_drug_van:startEvent",num,type)
	end
	
end)
local drawText
RegisterNetEvent("esx_drug_van:startEvent")
AddEventHandler("esx_drug_van:startEvent",function(num,typey)
	RequestModel("speedo")
	RequestModel("baller")
	RequestModel(2120901815)
	while not HasModelLoaded("speedo") do
		Citizen.Wait(100)
	end
	while not HasModelLoaded("baller") do
		Citizen.Wait(100)
	end
	while not HasModelLoaded(2120901815) do
		Citizen.Wait(100)
	end
	-- Makes the job unavailable for everyone
	local vanSpawn = Config.DrugVans[num].Location
	local vanHeading = Config.DrugVans[num].Heading
	local goonSpawnTwo = Config.DrugVans[num].GoonSpawns["one"]
	local goonSpawnOne = Config.DrugVans[num].GoonSpawns["two"]
	local typed = typey
	Config.DrugVans[num].InUse = true
	local playerped = GetPlayerPed(-1)
	TriggerServerEvent("esx_drug_van:syncData",Config.DrugVans)
	-- 99% of this can be made into a for loop :^) Just iterate through the locations and make peds with vehicles. Might take a little more config work but it's alot better than this :^) I just didn't do it because this works fine and i dont want to redo the code D:
	local vehicle = CreateVehicle("speedo",vanSpawn,vanHeading,true,true)
	local ped = CreatePedInsideVehicle(vehicle,5,2120901815,-1,true,true)
	local goonvehicleone = CreateVehicle("baller",goonSpawnOne,vanHeading,true,true)
	local goonone = CreatePedInsideVehicle(goonvehicleone,5,2120901815,-1,true,true)
	local goonvehicletwo = CreateVehicle("baller",goonSpawnTwo,vanHeading,true,true)
	local goontwo = CreatePedInsideVehicle(goonvehicletwo,5,2120901815,-1,true,true)
	local deliveryPoint = Config.DeliveryPoints[math.random(1,#Config.DeliveryPoints)]
	local done = false
	local varblip = CreateVarevognBlip(vehicle,"Varevogn")
	--local goonblipone = CreateVarevognBlip(goonvehicleone,"Goon")
	--local goonbliptwo = CreateVarevognBlip(goonvehicletwo,"Goon")
	AddRelationshipGroup('VanDefenders')
	SetPedRelationshipGroupHash(ped, 'VanDefenders')
	SetPedRelationshipGroupHash(goonone, 'VanDefenders')
	SetPedRelationshipGroupHash(goontwo, 'VanDefenders')
	SetRelationshipBetweenGroups(5,GetPedRelationshipGroupDefaultHash(GetPlayerPed(-1)),'VanDefenders')
	SetRelationshipBetweenGroups(5,'VanDefenders',GetPedRelationshipGroupDefaultHash(GetPlayerPed(-1)))	
	GiveWeaponToPed(ped,GetHashKey("WEAPON_PISTOL"),100,false,true)
	GiveWeaponToPed(goonone,GetHashKey("WEAPON_PISTOL"),100,false,true)
	GiveWeaponToPed(goontwo,GetHashKey("WEAPON_PISTOL"),100,false,true)
	local endblip = CreateEndBlip2(deliveryPoint)
	TaskVehicleDriveWander(goonone, goonvehicleone, 70.0, 786603)
	TaskVehicleFollow(ped, vehicle, goonvehicleone, 100.0, 786603, 5)
	TaskVehicleFollow(goontwo, goonvehicletwo ,vehicle, 100.0, 786603, 5)
	drawVehicleHealth(vehicle,typey)
	while not done and GetEntityHealth(vehicle) > 1 and not StopMission do
		SetVehicleDoorsLocked(vehicle,1)
		Citizen.Wait(10)
		SetRelationshipBetweenGroups(5,GetPedRelationshipGroupDefaultHash(GetPlayerPed(-1)),'VanDefenders')
		SetRelationshipBetweenGroups(5,'VanDefenders',GetPedRelationshipGroupDefaultHash(GetPlayerPed(-1)))
		while (IsPedInVehicle(playerped,vehicle) or IsPedDeadOrDying(ped)) and GetEntityHealth(vehicle) > 1 do
			SetVehicleDoorsLocked(vehicle,1)
			TaskCombatPed(goontwo,playerped)
			TaskCombatPed(goonone,playerped)
			SetRelationshipBetweenGroups(5,GetPedRelationshipGroupDefaultHash(GetPlayerPed(-1)),'VanDefenders')
			SetRelationshipBetweenGroups(5,'VanDefenders',GetPedRelationshipGroupDefaultHash(GetPlayerPed(-1)))
			Citizen.Wait(10)
			if GetDistanceBetweenCoords(GetEntityCoords(vehicle),deliveryPoint) < 10 then
				ESX.Game.Utils.DrawText3D(deliveryPoint, "Tryk på ~g~E~s~ for at aflevere varevognen", 2)
				if IsControlJustPressed(1,38) then
					TriggerServerEvent("esx_drug_van:reward",GetEntityHealth(vehicle)*(Config.Reward[typed]/1000),typed)
					ESX.Game.DeleteVehicle(vehicle)
					done = true
					break
				end
			end
		end
	end
	RemoveBlip(endblip)
	RemoveBlip(varblip)
	--RemoveBlip(goonblipone)
	--RemoveBlip(goonbliptwo)
	SetEntityAsNoLongerNeeded(goonone)
	SetEntityAsNoLongerNeeded(goontwo)
	SetEntityAsNoLongerNeeded(vehicle)
	SetEntityAsNoLongerNeeded(ped)
	SetEntityAsNoLongerNeeded(goonvehicleone)
	SetEntityAsNoLongerNeeded(goonvehicletwo)
	drawText = false
	-- Makes the job available again and does a bit of cleanup
	Config.DrugVans[num].InUse = false
	TriggerServerEvent("esx_drug_van:syncData",Config.DrugVans)
	vehicle = nil	
end)

function drawVehicleHealth(vehicle,typed)
	Citizen.CreateThread(function()
		drawText = true
        while drawText do
            Citizen.Wait(1)
            local health = (GetEntityHealth(vehicle)/10)
    
            drug_drawTxt(typed:gsub("^%l", string.upper) .. " Tilbage",vanText.scale,vanText.x,vanText.y)
    
            drug_drawRct(backBox.x, backBox.y, backBox.width,backBox.height,backBox.r,backBox.g,backBox.b,aptitude)
    
            drug_drawRct(healthBox.x,healthBox.y, healthBox.width,healthBox.height,backColor.r,backColor.g,backColor.b,healthBox.aptitude) -- health box
            drug_drawRct(healthBox.x,healthBox.y, healthBox.width*(health*0.01),healthBox.height,healthBox.r,healthBox.g,healthBox.b,healthBox.aptitude) -- health bar

        end
    end)
end

function drug_drawRct(x,y,width,height,r,g,b,a)
    DrawRect(x + width/2, y + height/2, width, height, r, g, b, a)
end

function drug_drawTxt(text,Scale,_y,_x)
    SetTextScale(Scale,Scale)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 55)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(_y,_x)
end

function CreateVarevognBlip(ped,text)
	local blip = GetBlipFromEntity(ped)
	
	if not DoesBlipExist(blip) then -- Add blip and create head display on player
		blip = AddBlipForEntity(ped)
		if text == "Varevogn" then
			SetBlipSprite(blip, 318)
		else
			SetBlipSprite(blip, 225)
		end
		SetBlipColour(blip, 1)
		SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		ShowHeadingIndicatorOnBlip(blip, false) -- Player Blip indicator
		AddTextEntry('MYBLIP', text)
		BeginTextCommandSetBlipName('MYBLIP')
		AddTextComponentSubstringPlayerName(name)
		EndTextCommandSetBlipName(blip)
		SetBlipScale(blip, 0.80) -- set scale
		SetBlipAsShortRange(blip, true)
	end
	return blip
end

function CreateEndBlip2(location)
	local blip = AddBlipForCoord(location.x,location.y,location.z)
	SetBlipSprite(blip, 355)
	SetBlipColour(blip, 5)
	AddTextEntry('MYBLIP', "Leveringssted")
	BeginTextCommandSetBlipName('MYBLIP')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
	SetBlipScale(blip, 0.70) -- set scale
	SetBlipAsShortRange(blip, true)
	return blip
end


RegisterNetEvent("esx_drug_van:syncData")
AddEventHandler("esx_drug_van:syncData",function(data)
	Config.DrugVans = data
end)


RegisterNetEvent("esx_drug_van:failMission")
AddEventHandler("esx_drug_van:failMission",function(data)
	Citizen.Wait(15*60*1000)
	StopMission = true
	ESX.ShowNotification("Du fejlede missionen")
	Citizen.Wait(10000)
	StopMission = false
end)