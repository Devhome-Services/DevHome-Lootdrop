ESX = exports["es_extended"]:getSharedObject()
local dropInterval = Config.DropInterval * 60000 -- Umrechnung in Millisekunden

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(dropInterval)
        local randomDrop = Config.DropCoords[math.random(#Config.DropCoords)]
        TriggerEvent('lootdrop:drop', randomDrop)
    end
end)

RegisterNetEvent('lootdrop:drop')
AddEventHandler('lootdrop:drop', function(coords)
    TriggerClientEvent('lootdrop:createDrop', -1, coords)
end)

RegisterNetEvent('lootdrop:claimLoot')
AddEventHandler('lootdrop:claimLoot', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    for _, item in pairs(Config.LootItems) do
        if item.type == 'weapon' then
            xPlayer.addWeapon(item.name, 250)
        else
            xPlayer.addInventoryItem(item.name, 1)
        end
    end
end)
