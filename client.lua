local ESX = exports['es_extended']:getSharedObject()

local isFlying = false
local isAutoPickup = false
local boxEntity = nil

-- Create the box
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if not boxEntity then
            RequestModel(GetHashKey('prop_box_wood02a'))
            while not HasModelLoaded(GetHashKey('prop_box_wood02a')) do
                Citizen.Wait(0)
            end
            boxEntity = CreateObject(GetHashKey('prop_box_wood02a'), Config.BoxPosition.x, Config.BoxPosition.y, Config.BoxPosition.z, false, false, false)
            SetEntityCollision(boxEntity, false, false)
            FreezeEntityPosition(boxEntity, true)
            SetEntityVisible(boxEntity, true, false)
            SetEntityAlpha(boxEntity, Config.BoxColor.a, false)
            SetEntityDrawOutline(boxEntity, true)
            SetEntityDrawOutlineColor(Config.BoxColor.r, Config.BoxColor.g, Config.BoxColor.b, Config.BoxColor.a)
        end
    end
end)

-- Handle button interactions
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.BoxPosition)
        
        if distance < 2.0 then
            DrawText3D(Config.BoxPosition.x, Config.BoxPosition.y, Config.BoxPosition.z + 1.0, 'Press ~INPUT_CONTEXT~ to interact')
            if IsControlJustPressed(0, 38) then
                OpenDeltaSystemMenu()
            end
        end
    end
end)

function OpenDeltaSystemMenu()
    local elements = {
        {label = 'Toggle Fly', value = 'fly'},
        {label = 'Toggle Auto Pickup', value = 'auto_pickup'}
    }
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'delta_system_menu', {
        title = 'DeltaSystem',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'fly' then
            isFlying = not isFlying
            TriggerServerEvent('delta_system:toggleFly', isFlying)
            if isFlying then
                ESX.ShowNotification('Fly mode enabled')
            else
                ESX.ShowNotification('Fly mode disabled')
            end
        elseif data.current.value == 'auto_pickup' then
            isAutoPickup = not isAutoPickup
            TriggerServerEvent('delta_system:toggleAutoPickup', isAutoPickup)
            if isAutoPickup then
                ESX.ShowNotification('Auto pickup enabled')
            else
                ESX.ShowNotification('Auto pickup disabled')
            end
        end
    end, function(data, menu)
        menu.close()
    end)
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    
    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry('STRING')
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Handle flying
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isFlying then
            local playerPed = PlayerPedId()
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
            DisableControlAction(0, 268, true)
            DisableControlAction(0, 269, true)
            
            if IsDisabledControlPressed(0, 21) then
                local playerCoords = GetEntityCoords(playerPed)
                local playerHeading = GetEntityHeading(playerPed)
                local offset = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, Config.FlySpeed, 0.0)
                SetEntityCoordsNoOffset(playerPed, offset.x, offset.y, offset.z, true, true, true)
            end
            
            if IsDisabledControlPressed(0, 22) then
                local playerCoords = GetEntityCoords(playerPed)
                local playerHeading = GetEntityHeading(playerPed)
                local offset = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, -Config.FlySpeed, 0.0)
                SetEntityCoordsNoOffset(playerPed, offset.x, offset.y, offset.z, true, true, true)
            end
        end
    end
end)

-- Handle auto pickup
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if isAutoPickup then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for _, entity in ipairs(GetGamePool('CObject')) do
                local entityCoords = GetEntityCoords(entity)
                local distance = #(playerCoords - entityCoords)
                
                if distance < Config.AutoPickupRadius then
                    local model = GetEntityModel(entity)
                    if IsEntityAPickup(entity) then
                        NetworkRequestControlOfEntity(entity)
                        while not NetworkHasControlOfEntity(entity) do
                            Citizen.Wait(0)
                        end
                        SetEntityAsMissionEntity(entity, true, true)
                        DeleteObject(entity)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('delta_system:updateSettings')
AddEventHandler('delta_system:updateSettings', function(flyEnabled, autoPickupEnabled)
    isFlying = flyEnabled
    isAutoPickup = autoPickupEnabled
end)