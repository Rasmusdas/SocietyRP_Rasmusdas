ESX = nil
local menuOpen = false
local wasOpen = false
local streetName
local _
local playerGender
local canSell = false
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	ESX.PlayerData = ESX.GetPlayerData()
	TriggerEvent('skinchanger:getSkin', function(skin)
		playerGender = skin.sex
	end)
end)
RequestAnimDict("mp_common")
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local handle, ped = FindFirstPed()
		local success
		local playerpos = GetEntityCoords(GetPlayerPed(-1))
		repeat
			success, ped = FindNextPed(handle)
			local pos = GetEntityCoords(ped)
			local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, playerpos.x, playerpos.y, playerpos.z, true)
			if distance < 2 and CanSellToPed(ped) and canSell then
				if canSell and not IsPedInAnyVehicle(GetPlayerPed(-1)) then
					ESX.ShowHelpNotification("Tryk på ~g~[H]~s~ for at tilbyde ~r~stoffer~s~")
					--Draw3DText(pos.x,pos.y,pos.z-1.5,"Tryk ~g~[H]~s~ for at tilbyde ~r~stoffer~s~",0,0.03,0.03)
					if IsControlJustPressed(1,74) then
						local playerPed = GetPlayerPed(-1)
						local chance = math.random(1,2)
						oldped = ped
						TaskStandStill(ped,5000.0)
						SetEntityAsMissionEntity(ped)
						FreezeEntityPosition(ped,true)
						FreezeEntityPosition(playerPed,true)
						SetEntityHeading(ped,GetHeadingFromVector_2d(pos.x-playerpos.x,pos.y-playerpos.y)+180)
						SetEntityHeading(playerPed,GetHeadingFromVector_2d(pos.x-playerpos.x,pos.y-playerpos.y))
						exports['progressBars']:startUI(5000, "SÆLGER STOFFER")
						Citizen.Wait(5000)
						if chance == 1 then
							TaskPlayAnim(GetPlayerPed(-1), "mp_common", "givetake2_a", 8.0, 8.0, 2000, 0, 1, 0,0,0)
							TaskPlayAnim(ped, "mp_common", "givetake2_a", 8.0, 8.0, 2000, 0, 1, 0,0,0)
							TriggerServerEvent("esx_drugSale:sellDrugs")
						else
							chance = math.random(1,2)
							if chance == 1 then
								TriggerServerEvent('esx_outlawalert:drugsaleInProgress',pos,streetName)
								ESX.ShowNotification("Personen afviste dit tilbud")
							else
								ESX.ShowNotification("Personen afviste dit tilbud")	
							end
						end
						SetPedAsNoLongerNeeded(ped)
						FreezeEntityPosition(ped,false)
						FreezeEntityPosition(playerPed,false)
						Citizen.Wait(10000)
						break
					end
				end
			end
		until not success
		EndFindPed(handle)
	end
end)

Citizen.CreateThread(function()
	while true do
		TriggerServerEvent("esx_drugSale:canSellDrugs")
		Citizen.Wait(10000)
		
	end
end)
function Draw3DText(x,y,z,textInput,fontId,scaleX,scaleY)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)    
	local scale = (1/dist)*20
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov   
	SetTextScale(scaleX*scale, scaleY*scale)
	SetTextFont(fontId)
	SetTextProportional(1)
	SetTextColour(250, 250, 250, 255)		-- You can change the text color here
	SetTextDropshadow(1, 1, 1, 1, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(textInput)
	SetDrawOrigin(x,y,z+2, 0)
	DrawText(0.0, 0.0)
	ClearDrawOrigin()
end



Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3000)
		local playerCoords = GetEntityCoords(PlayerPedId())
		streetName,_ = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
		streetName = GetStreetNameFromHashKey(streetName)
	end
end)


function CanSellToPed(ped)
	if not IsPedAPlayer(ped) and not IsPedInAnyVehicle(ped,false) and not IsEntityDead(ped) and IsPedHuman(ped) and GetEntityModel(ped) ~= GetHashKey("s_m_y_cop_01") and GetEntityModel(ped) ~= GetHashKey("s_m_y_dealer_01") and canSell then 
		return true
	end
	return false
end

RegisterNetEvent("esx_drugSale:canSellDrugs")
AddEventHandler("esx_drugSale:canSellDrugs", function(sell)
	canSell = sell
end)