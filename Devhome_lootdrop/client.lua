local blip = nil
local crate = nil
local isNearCrate = false
local smokeParticle = nil
local dropZoneBlip = nil -- Neuer Blip für den markierten Bereich

RegisterNetEvent('lootdrop:createDrop')
AddEventHandler('lootdrop:createDrop', function(coords)
    print("Lootdrop Event ausgelöst mit Koordinaten: ", coords.x, coords.y, coords.z)

    RequestModel(GetHashKey('prop_drop_armscrate_01'))

    while not HasModelLoaded(GetHashKey('prop_drop_armscrate_01')) do
        Citizen.Wait(1)
    end

    local startHeight = coords.z + 200.0
    local endHeight = coords.z

    crate = CreateObject(GetHashKey('prop_drop_armscrate_01'), coords.x, coords.y, startHeight, true, true, true)
    FreezeEntityPosition(crate, true)

    blip = AddBlipForCoord(coords.x, coords.y, endHeight)
    SetBlipSprite(blip, 478)
    SetBlipColour(blip, 1)
    SetBlipScale(blip, 1.0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Lootdrop")
    EndTextCommandSetBlipName(blip)

    -- Blip für den Bereich erstellen
    dropZoneBlip = AddBlipForRadius(coords.x, coords.y, coords.z, 60.0) -- Radius von 60.0
    SetBlipHighDetail(dropZoneBlip, true)
    SetBlipColour(dropZoneBlip, 1) -- Rot
    SetBlipAlpha(dropZoneBlip, 128) -- Halbtransparenz

    local glideSpeed = 0.2
    while startHeight > endHeight do
        Citizen.Wait(10)
        startHeight = startHeight - glideSpeed
        SetEntityCoords(crate, coords.x, coords.y, startHeight)
    end

    SetEntityCoords(crate, coords.x, coords.y, endHeight)
    PlaceObjectOnGroundProperly(crate)
    FreezeEntityPosition(crate, true)

    Citizen.Wait(2000)

    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do
        Citizen.Wait(1)
    end

    UseParticleFxAssetNextCall("core")
    smokeParticle = StartParticleFxLoopedAtCoord("exp_grd_flare", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)

    Citizen.Wait(12000)
    if smokeParticle then
        StopParticleFxLooped(smokeParticle, false)
        smokeParticle = nil
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if crate then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local crateCoords = GetEntityCoords(crate)
            local distance = #(playerCoords - crateCoords)

            if distance < 5.0 then
                isNearCrate = true
                ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~ um den Lootdrop zu plündern")

                if IsControlJustReleased(0, 38) then -- Taste "E"
                    TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true) -- Mechaniker-ähnliche Animation

                    Citizen.Wait(5000)

                    ClearPedTasksImmediately(playerPed)

                    TriggerServerEvent('lootdrop:claimLoot')

                    DeleteEntity(crate)
                    RemoveBlip(blip)
                    RemoveBlip(dropZoneBlip) -- Entferne den Bereichsblip, wenn der Loot eingesammelt wurde
                    crate = nil
                    isNearCrate = false
                end
            elseif isNearCrate then
                ESX.ShowHelpNotification("") -- Entfernt die Benachrichtigung
                isNearCrate = false
            end
        end
    end
end)
