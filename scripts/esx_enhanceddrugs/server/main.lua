ESX = nil

local startedPlayer = {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Server stuff for the drugcaravan 

RegisterServerEvent("esx_drug_van:start")
AddEventHandler("esx_drug_van:start",function()
	TriggerClientEvent("esx_drug_van:start",-1,Config.DrugVans.PlaceOne)
end)

RegisterServerEvent("esx_drug:addPlayer")
AddEventHandler("esx_drug:addPlayer",function(source)
	table.insert(startedPlayer,{started = GetPlayerIdentifier(source), time = 7200000})
end)

RegisterServerEvent("esx_drug_van:reward")
AddEventHandler("esx_drug_van:reward",function(amount,typed)
	local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.addInventoryItem(typed.."brick",math.ceil(amount))
end)

RegisterServerEvent("esx_drug_van:syncData")
AddEventHandler("esx_drug_van:syncData",function(data)
	TriggerClientEvent("esx_drug_van:syncData",-1,data)
end)

-- Server stuff for the npc syncing and spawning
local dealerTimer = 0
local dealer = 0
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if dealerTimer > 1000 then
			dealerTimer = dealerTimer-1000
			for k,v in pairs(startedPlayer) do
				if v.time <= 0 then
					RemoveStarted(v.started)
				else
					v.time = v.time - 1000
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	Citizen.Wait(1000)
	while true do
		dealer = math.random(1,#Config.DrugNPC)
		dealerTimer = 72000000
		TriggerClientEvent("esx_drugnpc:spawnNpc",-1,Config.DrugNPC[dealer],dealerTimer)		
		TriggerClientEvent('chat:addMessage', -1, { args = { "^0[^3Twitter^0] (^3@US_8429_HHGS^0)", Config.DrugNPC[dealer].Hint }, color = { 0, 153, 204 } })
		Citizen.Wait(7200000)
	end
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	TriggerClientEvent("esx_drugnpc:spawnNpc",playerId,Config.DrugNPC[dealer],dealerTimer)
end)

-- USB buying

RegisterServerEvent("esx_drugNpc:addBurn")
AddEventHandler("esx_drugNpc:addBurn",function(type)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addInventoryItem(string.lower(type).. "burn", 1)
end)

RegisterServerEvent("esx_drugNpc:buyLoc")
AddEventHandler("esx_drugNpc:buyLoc",function(type)
	type = string.sub(type,1,4)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() > Config.Prices[type] then
		xPlayer.removeMoney(Config.Prices[type])
		TriggerClientEvent("esx:showNotification",source,"~y~Positionen~s~ er tilføjet til dit kort!")
		TriggerClientEvent("esx_drugnpc:StartLoc",source,type)
	else
		TriggerClientEvent("esx:showNotification",source,"Du har ~r~ikke~s~ nok penge")
	end
end)

-- USABLE USB

local started = false

ESX.RegisterUsableItem('cokeburn', function(source)
	--TriggerClientEvent("esx_drugs:UsableUSB",source)
	--Citizen.Wait(15000)
	if not CheckedStarted(GetPlayerIdentifier(source)) then
		TriggerClientEvent("esx_drug_van:start",source,0,"coke")
		TriggerClientEvent("esx:showNotification",source,"Stjæl ~r~varevognen~s~ og aflever den ved ~y~leveringsstedet~s~!")
		TriggerEvent("esx_drug:addPlayer",source)
 	else
	 	TriggerClientEvent("esx:showNotification",source,string.format("Du kan først ~y~påbegynde~s~ en ny opgave om ~b~%s minutter~s~",GetTimeForMission(GetPlayerIdentifier(source))))
  	end
end)

-- Item Converter :^)

Citizen.CreateThread(function()
	for k,v in pairs(Config.Convertion) do
		ESX.RegisterUsableItem(v.ItemPre, function(source)
			local xPlayer = ESX.GetPlayerFromId(source)
			if v.ReqItem then
				if v.ReqScale then
					if xPlayer.getInventoryItem("hqscale").count >= 1  then
						if xPlayer.getInventoryItem(v.ReqItem).count >= v.ReqItemAmount then
							TriggerClientEvent("esx_drugs:convert",source,v.ConvertionTime,v.ConvertText)
							Citizen.Wait(v.ConvertionTime)
							xPlayer.addInventoryItem(v.ItemPost,v.Amount)
							xPlayer.removeInventoryItem(v.ItemPre,1)
							xPlayer.removeInventoryItem(v.ReqItem,v.ReqItemAmount)
						else
							TriggerClientEvent("esx:showNotification",source,"Du mangler ~b~"..v.ReqItemAmount.."x~s~ ~y~" .. v.ReqItemName.."~s~")
						end
					else
						TriggerClientEvent("esx:showNotification",source,"Du har ikke en ~y~High Quality Scale~s~ på dig")
					end
				else
					if xPlayer.getInventoryItem(v.ReqItem).count >= v.ReqItemAmount then
						TriggerClientEvent("esx_drugs:convert",source,v.ConvertionTime,v.ConvertText)
						Citizen.Wait(v.ConvertionTime)
						xPlayer.addInventoryItem(v.ItemPost,v.Amount)
						xPlayer.removeInventoryItem(v.ItemPre,1)
						xPlayer.removeInventoryItem(v.ReqItem,v.ReqItemAmount)
					else
						TriggerClientEvent("esx:showNotification",source,"Du mangler ~b~"..v.ReqItemAmount.."x~s~ ~y~" .. v.ReqItemName.."~s~")
					end
				end
			elseif v.ReqScale then
				if xPlayer.getInventoryItem("hqscale").count >= 1  then
					TriggerClientEvent("esx_drugs:convert",source,v.ConvertionTime,v.ConvertText)
					Citizen.Wait(v.ConvertionTime)
					xPlayer.addInventoryItem(v.ItemPost,v.Amount)
					xPlayer.removeInventoryItem(v.ItemPre,1)
				else
					TriggerClientEvent("esx:showNotification",source,"Du har ikke en ~y~High Quality Scale~s~ på dig")
				end
			else
				TriggerClientEvent("esx_drugs:convert",source,v.ConvertionTime,v.ConvertText)
				Citizen.Wait(v.ConvertionTime)
				xPlayer.addInventoryItem(v.ItemPost,v.Amount)
				xPlayer.removeInventoryItem(v.ItemPre,1)
			end
		end)
	end
end)

-- Drug Effects

ESX.RegisterUsableItem('coke', function(source)
	TriggerClientEvent("esx_drugs:activate_coke",source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem("coke1g",1)
end)


function RemoveStarted(source)
	for k,v in pairs(startedPlayer) do
		if v.started == source then
			table.remove(startedPlayer,k)
		end
	end
end

function GetTimeForMission(source)
	for k,v in pairs(startedPlayer) do
		if v.started == source then
			return math.ceil(v.time/60000)
		end
	end
end

function CheckedStarted(source)
	for k,v in pairs(startedPlayer) do
		if v.started == source then
			return true
		end
	end
	return false
end