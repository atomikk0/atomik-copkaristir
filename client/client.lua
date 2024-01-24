local QBCore = exports['qb-core']:GetCoreObject()
local lastMixedTrash = {} 
local mixCooldown = Config.MixCooldown 
local aktif = false

CreateThread(function()
    models = { 
    "prop_dumpster_01a", "prop_dumpster_02a", "prop_dumpster_02b", "prop_dumpster_3a", "prop_dumpster_4a", "prop_dumpster_4b",
    "prop_bin_05a", "prop_bin_06a", "prop_bin_07a", "prop_bin_07b", "prop_bin_07c", "prop_bin_07d", "prop_bin_08a", "prop_bin_08open",
    "prop_bin_09a", "prop_bin_10a", "prop_bin_10b", "prop_bin_11a", "prop_bin_12a", "prop_bin_13a", "prop_bin_14a", "prop_bin_14b",
    "prop_bin_beach_01d", "prop_bin_delpiero", "prop_bin_delpiero_b", "prop_recyclebin_01a", "prop_recyclebin_02_c", "prop_recyclebin_02_d",
    "prop_recyclebin_02a", "prop_recyclebin_02b", "prop_recyclebin_03_a", "prop_recyclebin_04_a", "prop_recyclebin_04_b", "prop_recyclebin_05_a",
    "zprop_bin_01a_old", "hei_heist_kit_bin_01", "ch_prop_casino_bin_01a", "vw_prop_vw_casino_bin_01a", "mp_b_kit_bin_01",
}
    exports['qb-target']:AddTargetModel(models, {
        options = {
            {
                type = "client",
                event = "atomik-copkaristir:karistir",
                icon = "fas fa-dumpster",
                label = "Çöpü Karıştır",
            },
        },
        distance = 1.5, 
    })
end)

RegisterNetEvent('atomik-copkaristir:karistir')
AddEventHandler('atomik-copkaristir:karistir', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestTrash = GetClosestTrash(coords)

    if closestTrash then
        local trashId = NetworkGetNetworkIdFromEntity(closestTrash)

        if not lastMixedTrash[trashId] or (GetGameTimer() - lastMixedTrash[trashId] >= mixCooldown * 1000) then
            if not aktif then
                aktif = true
                QBCore.Functions.Progressbar("cop_kariştir", "Çöpü Karıştırıyorsun", Config.PickTime, false, true, {
                    disableMovement = true,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = "amb@prop_human_bum_bin@base",
                    anim = "base",
                    flags = 33,
                }, {}, {}, function() -- Tamamlandı
                    TriggerServerEvent("atomik-copkaristir:bitir")
                    lastMixedTrash[trashId] = GetGameTimer()
                    Citizen.Wait(Config.Cooldown)
                    aktif = false
                end, function() -- İptal
                end)
            else
                local kalan = Config.Cooldown / 1000
                QBCore.Functions.Notify('Tekrar karıştırmak için '.. kalan ..' saniye beklemelisin.')     
            end
        else
            local remainingTime = math.max(0, (lastMixedTrash[trashId] + mixCooldown * 1000 - GetGameTimer()) / 1000)
            local minutes = math.floor(remainingTime / 60)
            local seconds = math.floor(remainingTime % 60)
            QBCore.Functions.Notify('Bu çöp kutusunu şu anda karıştıramazsın! Kalan süre: ' .. minutes .. ' dakika ' .. seconds .. ' saniye')     
        end
    else
        QBCore.Functions.Notify('Yakınında çöp kutusu bulunamadı.')
    end
end)


function GetClosestTrash(coords)
    local trashObjects = GetTrashObjectsInRadius(coords, 5.0)
    return GetClosestObject(coords, trashObjects)
end

function GetClosestObject(coords, objects)
    local closestObject = nil
    local closestDistance = -1

    for _, object in ipairs(objects) do
        local objectCoords = GetEntityCoords(object)
        local distance = #(coords - objectCoords)

        if closestDistance == -1 or distance < closestDistance then
            closestDistance = distance
            closestObject = object
        end
    end

    return closestObject
end


function GetTrashObjectsInRadius(coords, radius)
    local trashObjects = {}
    local allObjects = GetGamePool("CObject")
    
    for _, object in ipairs(allObjects) do
        local model = GetEntityModel(object)
        for _, trashModel in ipairs(models) do
            if model == GetHashKey(trashModel) then
                local objectCoords = GetEntityCoords(object)
                local distance = #(coords - objectCoords)
                if distance <= radius then
                    table.insert(trashObjects, object)
                end
                break
            end
        end
    end

    return trashObjects
end

