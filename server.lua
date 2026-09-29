local ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('delta_system:getSettings', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier
    
    MySQL.Async.fetchScalar('SELECT fly_enabled FROM delta_system WHERE player_id = @player_id', {
        ['@player_id'] = playerId
    }, function(flyEnabled)
        MySQL.Async.fetchScalar('SELECT auto_pickup_enabled FROM delta_system WHERE player_id = @player_id', {
            ['@player_id'] = playerId
        }, function(autoPickupEnabled)
            cb(flyEnabled, autoPickupEnabled)
        end)
    end)
end)

RegisterNetEvent('delta_system:toggleFly')
AddEventHandler('delta_system:toggleFly', function(enabled)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier
    
    MySQL.Async.execute('UPDATE delta_system SET fly_enabled = @enabled WHERE player_id = @player_id', {
        ['@enabled'] = enabled,
        ['@player_id'] = playerId
    }, function(rowsChanged)
        if rowsChanged == 0 then
            MySQL.Async.execute('INSERT INTO delta_system (player_id, fly_enabled) VALUES (@player_id, @enabled)', {
                ['@player_id'] = playerId,
                ['@enabled'] = enabled
            })
        end
    end)
end)

RegisterNetEvent('delta_system:toggleAutoPickup')
AddEventHandler('delta_system:toggleAutoPickup', function(enabled)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier
    
    MySQL.Async.execute('UPDATE delta_system SET auto_pickup_enabled = @enabled WHERE player_id = @player_id', {
        ['@enabled'] = enabled,
        ['@player_id'] = playerId
    }, function(rowsChanged)
        if rowsChanged == 0 then
            MySQL.Async.execute('INSERT INTO delta_system (player_id, auto_pickup_enabled) VALUES (@player_id, @enabled)', {
                ['@player_id'] = playerId,
                ['@enabled'] = enabled
            })
        end
    end)
end)