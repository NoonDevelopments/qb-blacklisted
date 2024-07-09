QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('blacklist:openMenu')
AddEventHandler('blacklist:openMenu', function()
    local menu = {
        {
            header = "Blacklist Menu",
            isMenuHeader = true,
        },
        {
            header = "Add Citizen to Blacklist",
            txt = "Add a new Citizen ID to the blacklist",
            params = {
                event = "blacklist:addCitizenInput"
            }
        },
        {
            header = "Remove Citizen from Blacklist",
            txt = "Remove a Citizen ID from the blacklist",
            params = {
                event = "blacklist:removeCitizenInput"
            }
        }
    }

    QBCore.Functions.TriggerCallback('blacklist:getBlacklistedCitizens', function(citizens)
        for _, citizen in ipairs(citizens) do
            table.insert(menu, {
                header = "Citizen ID: " .. citizen.citizenid,
                txt = "Click to remove",
                params = {
                    event = "blacklist:removeCitizen",
                    args = {
                        citizenid = citizen.citizenid
                    }
                }
            })
        end

        exports['qb-menu']:openMenu(menu)
    end)
end)

RegisterNetEvent('blacklist:addCitizenInput')
AddEventHandler('blacklist:addCitizenInput', function()
    local dialog = exports['qb-input']:ShowInput({
        header = "Add to Blacklist",
        submitText = "Add",
        inputs = {
            {
                text = "Citizen ID (#)",
                name = "citizenid",
                type = "text",
                isRequired = true,
            },
            {
                text = "Driving Ban (Yes/No)",
                name = "drivingBan",
                type = "radio",
                options = {
                    { value = "1", text = "Yes" },
                    { value = "0", text = "No" }
                },
                isRequired = true,
            }
        }
    })

    if dialog then
        local data = {
            citizenid = dialog.citizenid,
            drivingBan = tonumber(dialog.drivingBan)
        }
        TriggerServerEvent('blacklist:addCitizen', data)
    end
end)

RegisterNetEvent('blacklist:removeCitizenInput')
AddEventHandler('blacklist:removeCitizenInput', function()
    local dialog = exports['qb-input']:ShowInput({
        header = "Remove from Blacklist",
        submitText = "Remove",
        inputs = {
            {
                text = "Citizen ID (#)",
                name = "citizenid",
                type = "text",
                isRequired = true,
            }
        }
    })

    if dialog then
        TriggerServerEvent('blacklist:removeCitizen', dialog.citizenid)
    end
end)

RegisterNetEvent('blacklist:removeCitizen')
AddEventHandler('blacklist:removeCitizen', function(data)
    TriggerServerEvent('blacklist:removeCitizen', data.citizenid)
end)

local function checkJobRestriction(playerJob)
    for _, restrictedJob in ipairs(Config.RestrictedJobs) do
        if playerJob == restrictedJob then
            return true
        end
    end
    return false
end

local function checkVehicleRestriction(vehicle)
    local model = GetEntityModel(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(model):upper()

    for _, restrictedVehicle in ipairs(Config.RestrictedVehicles) do
        if modelName == restrictedVehicle:upper() then
            return true
        end
    end
    return false
end

CreateThread(function()
    while true do
        Wait(1000)
        local playerPed = PlayerPedId()
        local playerData = QBCore.Functions.GetPlayerData()

        if playerData and checkJobRestriction(playerData.job.name) then
            TriggerServerEvent('blacklist:enforceJobRestriction')
        end

        if IsPedInAnyVehicle(playerPed, false) then
            TriggerServerEvent('blacklist:checkDriving')
        end
    end
end)

RegisterNetEvent('blacklist:preventDriving')
AddEventHandler('blacklist:preventDriving', function(isDrivingBan)
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if isDrivingBan or checkVehicleRestriction(vehicle) then
            TaskLeaveVehicle(playerPed, vehicle, 16)
            if isDrivingBan == true then
                TriggerEvent('QBCore:Notify', 'You are banned from driving any vehicle.', 'error')
            else
                TriggerEvent('QBCore:Notify', 'You are blacklisted from driving this vehicle.', 'error')
            end
        end
    end
end)
