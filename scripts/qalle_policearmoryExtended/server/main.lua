local ESX = nil

local CachedPedState = false

TriggerEvent("esx:getSharedObject", function(response)
    ESX = response
end)

ESX.RegisterServerCallback("qalle_policearmory:pedExists", function(source, cb)
    if CachedPedState then
        cb(true)
    else
        CachedPedState = true
        cb(false)
    end
end)

RegisterServerEvent("qalle_policearmory:giveWeapon")
AddEventHandler("qalle_policearmory:giveWeapon", function(weapon,giveAmmo)
    local player = ESX.GetPlayerFromId(source)
    if player then
        player.addWeapon(weapon, Config.ReceiveAmmo)
        local ting = "**" .. player.getName() .. "** [" .. player.getIdentifier() .. "] **|** " .. os.date() .. " har taget **" .. ESX.GetWeaponLabel(weapon) .. "** ud af PoliceArmory"
        PerformHttpRequest('WEBHOOK', function(err, text, headers) end, 'POST', json.encode({username = "Cordinator", content = ting}), { ['Content-Type'] = 'application/json' })
        if giveAmmo then
            TriggerClientEvent("esx:showNotification", source, "Du har modtaget 1x " .. ESX.GetWeaponLabel(weapon) .. " med " .. Config.ReceiveAmmo .. "x ammo.")
        else
            TriggerClientEvent("esx:showNotification", source, "Du har modtaget 1x " .. ESX.GetWeaponLabel(weapon))
        end
    end
end)

RegisterServerEvent("qalle_policearmory:removeWeapon")
AddEventHandler("qalle_policearmory:removeWeapon", function(weapon,ammo,giveAmmo)
    local player = ESX.GetPlayerFromId(source)

    if player then
        local ting = "**" .. player.getName() .. "** [" .. player.getIdentifier() .. "] **|** " .. os.date() .. " har lagt **" .. ESX.GetWeaponLabel(weapon) .. "** tilbage i PoliceArmory"
        player.removeWeapon(weapon, ammo)
        PerformHttpRequest('WEBHOOK', function(err, text, headers) end, 'POST', json.encode({username = "Cordinator", content = ting}), { ['Content-Type'] = 'application/json' })
        if giveAmmo then
            TriggerClientEvent("esx:showNotification", source, "Du har lagt 1x " .. ESX.GetWeaponLabel(weapon) .. " med " .. ammo .. "x skud tilbage")
        else
            TriggerClientEvent("esx:showNotification", source, "Du har lagt 1x " .. ESX.GetWeaponLabel(weapon) .. " tilbage")
        end
    end
end)

RegisterServerEvent("qalle_policearmory:addToLend")
AddEventHandler("qalle_policearmory:addToLend", function(weapon)
    local id = ESX.GetPlayerFromId(source).getIdentifier()
    MySQL.Async.fetchAll('SELECT weapons FROM policearmory WHERE steamID=\"'.. id .. '\"', {}, function(weapRow)
        local newLend
        for k,v in pairs(weapRow) do
            newLend = v.weapons
        end
        newLend = newLend .. weapon .. ", "
        MySQL.Async.execute("UPDATE policearmory SET weapons=\"".. newLend .. "\" WHERE steamID=\"" .. id .. "\"", {}, function ()
        end)
    end)
end)


RegisterServerEvent("qalle_policearmory:remToLend")
AddEventHandler("qalle_policearmory:remToLend", function(weapon)
    local id = ESX.GetPlayerFromId(source).getIdentifier()
    MySQL.Async.fetchAll('SELECT weapons FROM policearmory WHERE steamID=\"'.. id .. '\"', {}, function(weapRow)
        for k,v in pairs(weapRow) do
            newLend = string.gsub(v.weapons,weapon .. ", ", "")
        end
        MySQL.Async.execute("UPDATE policearmory SET weapons=\"".. newLend .. "\" WHERE steamID=\"" .. id .. "\"", {}, function ()
        end)
    end)
end)

ESX.RegisterServerCallback("qalle_policearmory:checkStorage", function(source, cb)
    local id = ESX.GetPlayerFromId(source).getIdentifier()
    MySQL.Async.fetchAll('SELECT weapons FROM policearmory WHERE steamID = \"' .. id .. '\"', {}, function(rowsChanged)
        if next(rowsChanged) == nil then
            MySQL.Async.execute("INSERT INTO policearmory (steamID,weapons) VALUES(\"" ..id .. "\",\"\")", {}, function () end)
            cb(nil)
        end
        cb(rowsChanged)
    end)
end)

ESX.RegisterServerCallback("qalle_policearmory:superCheck", function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM policearmory', {}, function(rowsChanged)
        local people = {}
        for k,v in pairs(rowsChanged) do
            local xPlayer = ESX.GetPlayerFromIdentifier(v.steamID)
            if xPlayer ~= nil then
                table.insert(people,{id = v.steamID,name = xPlayer.getRPname(),job = xPlayer.getJob()})
            end
        end
        cb(people)
    end)
end)


RegisterServerEvent("qalle_policearmory:SuperRemLend")
AddEventHandler("qalle_policearmory:SuperRemLend", function(id)
    MySQL.Async.execute("UPDATE policearmory SET weapons= \"\" WHERE steamID=\"" .. id .. "\"", {}, function ()
    end)   
end)

ESX.RegisterServerCallback("qalle_policearmory:GetJobGrade", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.getJob().grade)
end)

