ESX = nil
local playersProcessing = {}
local sell = {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("esx_drugSale:sellDrugs")
AddEventHandler("esx_drugSale:sellDrugs", function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local drugType = nil
	if xPlayer.getInventoryItem("meth").count <= 0 and xPlayer.getInventoryItem("coke").count <= 0  then
		TriggerClientEvent("esx:showNotification",source,"Du har ikke nok stoffer på dig")
	elseif xPlayer.getInventoryItem("meth").count <= 0 then
		drugType = "coke"
	elseif xPlayer.getInventoryItem("coke").count <= 0 then
		drugType = "meth"
	elseif xPlayer.getInventoryItem("weed").count <= 0 then
		drugType = "weed"
	else
		drugType = math.random(1,3)
		if drugType == 1 then
			drugType = "coke"
		elseif drugType == 2 then
			drugType = "meth"
		else
			drugType = "weed"
		end
	end
	
	if drugType ~= nil then
		local price = 0
		local drugamount = 0
		if xPlayer.getInventoryItem(drugType).count < 3 then
			drugamount = math.random(1,xPlayer.getInventoryItem(drugType).count)
		else
			drugamount = math.random(1,3)
		end
		if drugType == "meth" then
			price = drugamount*math.random(11,12)*10
		elseif drugType == "coke" then
			price = drugamount*math.random(9,11)*10
		elseif drugType == "weed" then
			price = drugamount*math.random(7,8)*10
		end
		AddSellAmount(xPlayer.getIdentifier(),drugamount)
		xPlayer.removeInventoryItem(drugType,drugamount)
		xPlayer.addAccountMoney("black_money",price)
		TriggerClientEvent("esx:showNotification",source,"Du har solgt " .. drugamount .. "x " .. firstToUpper(drugType) ..  " til ~r~$" .. price .. " Sorte Penge~s~")
	end
end)

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

RegisterServerEvent("esx_drugSale:canSellDrugs")
AddEventHandler("esx_drugSale:canSellDrugs", function()
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
		local sell = (xPlayer.getInventoryItem("coke").count > 0 or xPlayer.getInventoryItem("meth").count > 0 or xPlayer.getInventoryItem("weed").count > 0) and CheckSellAmount(xPlayer.getIdentifier()) < 100
		TriggerClientEvent("esx_drugSale:canSellDrugs",source,sell)
	end
end)

function AddSellAmount(source,amount)
	for k,v in pairs(sell) do
		if v.id == source then
			v.amount = v.amount + amount
			return
		end
	end
end

function CheckSellAmount(source)
	for k,v in pairs(sell) do
		if v.id == source then
			return v.amount
			
		end
	end
	table.insert(sell,{id = source, amount = 0})
	return CheckSellAmount(source)
end

