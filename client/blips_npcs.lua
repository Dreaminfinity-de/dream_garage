blips = {}
npcs  = {}



Citizen.CreateThread(function()

	if not Config.EnableBlips then return end

    blips['garages'] = {}
	for i, v in ipairs(Config.Garages) do

        -- Blips
        if v.blip ~= nil then
            blips['garages'][v.id] = createBlip(v.blip.pos, v.blip.sprite or 524, v.blip.display, v.blip.color or 3, v.blip.scale, v.blip.titel or _U('garage_blip_name'))
        end

        -- NPCs
        spawnNPC(v.garagemanager.type, v.garagemanager.model, v.garagemanager.pos, v.garagemanager.heading)

        -- Debug - Blip Parkingin Zones
        for i2, v2 in ipairs(v.parking) do
            createDebugBlipForRadius(v2.pos, v2.radius)
        end

	end

    blips['towyards'] = {}
    for k, v in pairs(Config.Towyards) do

        -- Blips
        if v.blip ~= nil then
            blips['towyards'][k] = createBlip(v.parking_pos, v.blip.sprite or 68, v.blip.display, v.blip.color or 17, v.blip.scale, v.blip.titel or _U('towyard_blip_name'))
        end

        -- NPCs
        spawnNPC(v.towyardmanager.type, v.towyardmanager.model, v.towyardmanager.pos, v.towyardmanager.heading)

        -- Debug - Blip Parkingin Zones
        createDebugBlipForRadius(v.parking_pos, v.parking_radius)
	end
end)


function removeNPCs()

    for i, v in ipairs(npcs) do
        DeleteEntity(v)
    end

end

function spawnNPC(type, model, pos, heading)

    if type == nil then
        type = Config.NPCsDefaultType
    end

    if model ~= nil then
        model = GetHashKey(model)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
    else
        RequestModel(GetHashKey(Config.NPCsDefaultModel))
        while not HasModelLoaded(GetHashKey(Config.NPCsDefaultModel)) do
            Wait(1)
        end
        model = GetHashKey(Config.NPCsDefaultModel)
    end

    ped = CreatePed(type, model, pos.x, pos.y, pos.z, heading, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    RequestAnimDict("mini@strip_club@idles@bouncer@base")
    while not HasAnimDictLoaded("mini@strip_club@idles@bouncer@base") do
        Wait(1)
    end
    TaskPlayAnim(ped,"mini@strip_club@idles@bouncer@base","base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)

    table.insert( npcs, ped )
end

function createBlip(pos, sprite, display, color, scale, titel)
    local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, display or 2)
    SetBlipColour(blip, color)
    SetBlipScale(blip, scale or 1.0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(titel)
    EndTextCommandSetBlipName(blip)
    return blip
end

function createDebugBlipForRadius(pos, radius)
    if Config.Debugmode.enable == true and Config.Debugmode.blips then
        local debug_blip = AddBlipForRadius(pos.x, pos.y, pos.z, 0.0 + radius)
        SetBlipHighDetail(debug_blip, true)
        SetBlipColour(debug_blip, 1)
        SetBlipAlpha (debug_blip, 128)
    end
end



Citizen.CreateThread(function()
    while Config.Debugmode.enable == true and Config.Debugmode.marker do
        Citizen.Wait(0)
        for i, v in ipairs(Config.Garages) do
            for i2, v2 in ipairs(v.garagemanager.spawnpoints) do
                DrawMarker(28, v2.coords.x, v2.coords.y, v2.coords.z, 0, 0, 0, 0, 0, 0,
                    v2.radius, v2.radius, v2.radius, 255, 255, 0, 100, 0, 0, 0, 0)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while Config.Debugmode.enable == true and Config.Debugmode.notification do
        Citizen.Wait(500)
        for i, v in ipairs(Config.Garages) do
            for i2, v2 in ipairs(v.garagemanager.spawnpoints) do
                for i3, v3 in ipairs(ESX.Game.GetVehiclesInArea(v2.coords, v2.radius)) do
                    if GetVehicleNumberPlateText(v3) == 'DEBUG 10' or GetVehicleNumberPlateText(v3) == 'DEBUG 20' then
                        TriggerEvent("swt_notifications:captionIcon",_U('notification_message_parkingout_debug_spawnpoint2', v.id),_U('notification_message_parkingout_debug_spawnpoint', GetVehicleNumberPlateText(v3),i2),
                            Config.Notification.pos,Config.Notification.timeout,Config.Notification.color.debug,'black',true,Config.Notification.icons.debug)
                    end
                end
            end
        end
    end
end)
