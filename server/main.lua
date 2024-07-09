QBCore = exports['qb-core']:GetCoreObject()

local function getBlacklistInfo(citizenid, callback)
    exports.oxmysql:execute('SELECT * FROM blacklisted_citizens WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            callback(result[1])
        else
            callback(nil)
        end
    end)
end

RegisterServerEvent('blacklist:enforceJobRestriction')
AddEventHandler('blacklist:enforceJobRestriction', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local citizenid = player.PlayerData.citizenid

    getBlacklistInfo(citizenid, function(info)
        if info then
            for _, job in ipairs(Config.RestrictedJobs) do
                if player.PlayerData.job.name == job then
                    player.Functions.SetJob('unemployed', 0)
                    TriggerClientEvent('QBCore:Notify', player.PlayerData.source, 'You are blacklisted and have been set to unemployed.', 'error')
                    break
                end
            end
        end
    end)
end)

RegisterServerEvent('blacklist:checkDriving')
AddEventHandler('blacklist:checkDriving', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local citizenid = player.PlayerData.citizenid

    getBlacklistInfo(citizenid, function(info)
        if info then
            if info.DrivingBan == 1 or info.DrivingBan == true then
                TriggerClientEvent('blacklist:preventDriving', src, true)
            else
                TriggerClientEvent('blacklist:preventDriving', src, false)
            end
        end
    end)
end)

QBCore.Commands.Add('blacklistmenu', 'Open the blacklist menu', {}, false, function(source)
    TriggerClientEvent('blacklist:openMenu', source)
end, 'admin')

QBCore.Functions.CreateCallback('blacklist:getBlacklistedCitizens', function(source, cb)
    exports.oxmysql:execute('SELECT * FROM blacklisted_citizens', {}, function(result)
        cb(result)
    end)
end)

RegisterServerEvent('blacklist:addCitizen')
AddEventHandler('blacklist:addCitizen', function(data)
    local src = source
    local citizenid = data.citizenid
    local drivingBan = data.drivingBan

    getBlacklistInfo(citizenid, function(info)
        if info then
            TriggerClientEvent('QBCore:Notify', src, 'Citizen ID already blacklisted.', 'error')
        else
            exports.oxmysql:insert('INSERT INTO blacklisted_citizens (citizenid, DrivingBan) VALUES (?, ?)', { citizenid, drivingBan }, function(id)
                if id then
                    TriggerClientEvent('QBCore:Notify', src, 'Citizen ID blacklisted successfully.', 'success')
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Failed to blacklist Citizen ID.', 'error')
                end
            end)
        end
    end)
end)

RegisterServerEvent('blacklist:removeCitizen')
AddEventHandler('blacklist:removeCitizen', function(citizenid)
    local src = source

    exports.oxmysql:execute('DELETE FROM blacklisted_citizens WHERE citizenid = ?', { citizenid }, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Citizen ID removed from blacklist successfully.', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to remove Citizen ID from blacklist.', 'error')
        end
    end)
end)
