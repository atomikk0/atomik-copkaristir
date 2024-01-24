local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("atomik-copkaristir:bitir")
AddEventHandler("atomik-copkaristir:bitir", function()
    local Player = QBCore.Functions.GetPlayer(source)
    local sans = math.random(0, 100)

    for _,v in pairs(Config.Items) do
        if sans >= v.minoran and sans <= v.maxoran then
            Player.Functions.AddItem(v.itemName, 1)
            TriggerClientEvent('QBCore:Notify', source, v.label..' buldun')
        end
    end

end)
