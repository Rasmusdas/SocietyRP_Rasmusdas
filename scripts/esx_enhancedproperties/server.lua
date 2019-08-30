ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback("esx_property:ownedProperties",function(source,cb,houseType)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM esx_property WHERE identifier=@identifier AND type=@houseType', {
        ["@identifier"] = xPlayer.getIdentifier(),
        ["@houseType"] = houseType
    },
    function(rows)
        if rows[1] == nil then
            cb(nil)
            print("nil")
        else
            cb(rows[1])
        end
    end)
end)

ESX.RegisterServerCallback("esx_property:buyProperty",function(source,cb,houseType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() + xPlayer.getBank()> Config.HouseTypes[houseType].Price then
        MySQL.Async.execute('INSERT INTO esx_property (identifier,type,data) VALUES (@identifier,@houseType,@data)', {
            ["@identifier"] = xPlayer.getIdentifier(),
            ["@houseType"] = houseType,
            ["@data"] = "{}"
        })
        xPlayer.removeAllMoney(Config.HouseTypes[houseType].Price)
        TriggerClientEvent("esx:showNotification",source,Config.HouseTypes[houseType].BuyMessage)
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback("esx_property:sellProperty",function(source,cb,houseType)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('DELETE FROM esx_property WHERE identifier=@identifier AND type = @houseType', {
        ["@identifier"] = xPlayer.getIdentifier(),
        ["@houseType"] = houseType,
    })
    xPlayer.addAccountMoney("bank",Config.HouseTypes[houseType].Price/2)
    TriggerClientEvent("esx:showNotification",source,Config.HouseTypes[houseType].SellMessage)
    cb(true)
end)
local Houses = {}
RegisterNetEvent("esx_property:invite")
AddEventHandler("esx_property:invite",function(target,houseType,pos)
    TriggerClientEvent("esx_property:invite",target,houseType,pos)
end)

RegisterNetEvent("esx_property:addHouse")
AddEventHandler("esx_property:addHouse",function(house)
    table.insert(Houses,{o = house})
    print(ESX.DumpTable(Houses))
end)

RegisterNetEvent("esx_property:remHouse")
AddEventHandler("esx_property:remHouse",function(house)
    for k,v in pairs(Houses) do
        if v.o == house then
            table.remove(Houses,k)
        end
    end
    print(ESX.DumpTable(Houses))
end)

ESX.RegisterServerCallback("esx_property:houseTaken",function(source,cb,houseType)
    for k,v in pairs(Houses) do
        print(v)
        if v.o == house then
            cb(false)
        end
    end
    cb(true)
end)