
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
    DoBlips()
	ESX.PlayerData = ESX.GetPlayerData()
end)
local inHouse = false
local house = nil
local playerOldPos = nil
local housePos = nil
function EnterHouse(houseType,preview) 
    
    houseType.Preview = preview
    if houseType.Inside then
        
        SetEntityCoords(house,0,0,0)
        house = nil
        houseType.Inside = false
        TriggerServerEvent("esx_property:remHouse",housePos.x)
        SetEntityCoords(GetPlayerPed(-1),playerOldPos)
    else
        playerOldPos = GetEntityCoords(GetPlayerPed(-1))
        local pos = Config.HouseStart
        RequestModel(GetHashKey(houseType.Type))
        local object,distance = ESX.Game.GetClosestObject({}, pos)
        local notTaken = false
        while not notTaken do
            ESX.TriggerServerCallback("esx_property:houseTaken",function(state) notTaken = state end,pos)
            Citizen.Wait(25)
            pos = pos + vector3(50.0,50.0,0.0)
            object,distance = ESX.Game.GetClosestObject({}, pos)
        end
        
        while not HasModelLoaded(GetHashKey(houseType.Type)) do
            Citizen.Wait(100)
            print("gae")
        end
        
        house = CreateObject(GetHashKey(houseType.Type),pos.x,pos.y,pos.z,true,false,true)
        FreezeEntityPosition(house,true) 
        housePos = GetEntityCoords(house)
        TriggerServerEvent("esx_property:addHouse",housePos.x)
        while house == nil do
            Citizen.Wait(100)
        end

        SetEntityCoords(GetPlayerPed(-1),pos-houseType.EntranceOffset)
        houseType.Inside = true 
    end
end

RegisterCommand('rain', function(source, args)
    insideWeather = "CLEAR"
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypePersist(insideWeather)
    SetWeatherTypeNow(insideWeather)
    SetWeatherTypeNowPersist(insideWeather)

end,false)



local ExitHouseMarker = nil
Citizen.CreateThread(function() 
    local pos = Config.Motel
    while true do
        local playerPos = GetEntityCoords(GetPlayerPed(-1))
        Citizen.Wait(1)
        for k,v in pairs(Config.HouseTypes) do
            if GetDistanceBetweenCoords(v.EnterLocation,playerPos) < 10 then
                DrawMarker(25, v.EnterLocation.x,v.EnterLocation.y,v.EnterLocation.z+1.95, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 255, false, true, 2, nil, nil, false)
                if GetDistanceBetweenCoords(v.EnterLocation,playerPos) < 0.8 then
                    ESX.ShowHelpNotification("Tryk på ~INPUT_CONTEXT~ for at åbne menuen")
                    if IsControlJustPressed(1,38) then
                        HouseMenu(v)
                    end
                end
            end
            if v.Inside then
                ExitHouseMarker = housePos-v.EntranceOffset
                DrawMarker(25, ExitHouseMarker.x,ExitHouseMarker.y,ExitHouseMarker.z-1.3, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 255, false, true, 2, nil, nil, false)
                if GetDistanceBetweenCoords(ExitHouseMarker,playerPos) < 0.8 then
                    ESX.ShowHelpNotification("Tryk på ~INPUT_CONTEXT~ for at åbne menuen")
                    if IsControlJustPressed(1,38) then
                        HouseMenu(v)
                    end
                end
                if not v.Preview then
                    local InventoryHouseMarker = housePos-v.InventoryOffset
                    DrawMarker(25, InventoryHouseMarker.x,InventoryHouseMarker.y,InventoryHouseMarker.z-1.3, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 255, false, true, 2, nil, nil, false)
                    if GetDistanceBetweenCoords(InventoryHouseMarker,playerPos) < 0.8 then
                        ESX.ShowHelpNotification("Tryk på ~INPUT_CONTEXT~ for at åbne skufferne")
                        if IsControlJustPressed(1,38) then
                            print(GetPlayerServerId(PlayerId()))
                            OpenPropertyInventoryMenu(GetPlayerServerId(PlayerId()))
                        end
                    end
                end
            end
        end
    end
end)


function HouseMenu(houseData)
    local elements = {}
    ESX.TriggerServerCallback("esx_property:ownedProperties",function(owned)
        if houseData.Inside then
            table.insert(elements,{label = "Gå ud af Værelse",value = "goin"})
            if not houseData.Preview then
                table.insert(elements,{label = "Inviter Person",value = "inv"})
            end
        else
            if owned == nil then
                table.insert(elements,{label = "Køb Værelse <b style='color:#00ff00;'>$20000</b>", value = "buy"})
                table.insert(elements,{label = "Se Værelse",value = "look"})
            else
                table.insert(elements,{label = "Gå ind på Værelse",value = "goin"})
                table.insert(elements,{label = "Sælg Værelse",value = "sell"})
            end
        end
        ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'pung_menu',
            {
                title    = "Motel",
                align    = 'center',
                elements = elements
            },
            function(data, menu)
                menu.close()
                if data.current.value == "goin" then
                    EnterHouse(houseData,false)
                elseif data.current.value == "sell" then
                    ESX.TriggerServerCallback("esx_property:sellProperty",function(owned)
                        HouseMenu(houseData)
                    end,houseData.Type)
                elseif data.current.value == "look" then
                    EnterHouse(houseData,true)
                elseif data.current.value == "inv" then
                    local peeps = ESX.Game.GetPlayersInArea(playerOldPos,5)
                    for k,v in pairs(peeps) do
                        TriggerServerEvent("esx_property:invite",GetPlayerServerId(v),houseData.Type,housePos)
                    end
                elseif data.current.value == "buy" then
                    ESX.TriggerServerCallback("esx_property:buyProperty",function(owned)
                        if owned then
                            HouseMenu(houseData)
                        else
                            ESX.ShowNotification("Du har ikke råd")
                        end
                    end,houseData.Type)
                end
            end, function(data,menu) menu.close() end)
    end,houseData.Type)
end

function OpenPropertyInventoryMenu(id)
    local owner = nil
    ESX.TriggerServerCallback("GetSteamID",function(id) owner = id end,id)
    while owner == nil do
        Citizen.Wait(10)
    end
	ESX.TriggerServerCallback(
		"esx_property:getPropertyInventory",
		function(inventory)
			TriggerEvent("esx_inventoryhud:openPropertyInventory", inventory)
		end,
	owner
    )
    ESX.TriggerServerCallback("GetSteamID",function(id) end,id)
end

RegisterNetEvent("esx_property:invite")
AddEventHandler("esx_property:invite",function(houseType,pos)
    playerOldPos = GetEntityCoords(GetPlayerPed(-1))
    Config.HouseTypes[houseType].Inside = true
    Config.HouseTypes[houseType].Preview = true
    ExitHouseMarker = pos-Config.HouseTypes[houseType].EntranceOffset
    housePos = pos
    FreezeEntityPosition(obj,true)
    SetEntityCoords(GetPlayerPed(-1),pos-Config.HouseTypes[houseType].EntranceOffset)
end)

function DoBlips()
    for k,v in pairs(Config.HouseTypes) do
        local blip = AddBlipForCoord(v.EnterLocation.x, v.EnterLocation.y, v.EnterLocation.z)
        SetBlipSprite               (blip, v.BlipSprite)
        SetBlipDisplay              (blip, 3)
        SetBlipScale                (blip, 0.60)
        SetBlipColour               (blip, 27)
        SetBlipAsShortRange         (blip, false)
        SetBlipHighDetail           (blip, true)
        BeginTextCommandSetBlipName ("STRING")
        AddTextComponentString      (v.BlipName)
        EndTextCommandSetBlipName   (blip)
    end
end