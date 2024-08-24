RegisterNetEvent('GodsEye:SentCoords')

local foundPlayer = false
local count = 0
local count2 = 0
local targetId
local activeLocations = {}
local blip = nil
local coords
local ped

AddEventHandler('GodsEye:SentCoords', function(cd, pd) -- server sided event when the coordinates get sent back to the client
    coords = cd
    ped = pd
end)

function GetInformation() -- getting the coordinates for the selected player
    TriggerServerEvent('GodsEye:GetCoords', targetId)
    Wait(500)

    if coords == nil then
        lib.notify({
            title = 'Player Not Found',
            description = 'The specified player could not be found',
            type = 'error',
            position = 'center-right',
            duration = 6000,
        })
        foundPlayer = false
        count = 0
        count2 = 0
        return
    end

    local Location = {
        pos = {x = coords.x, y = coords.y, z = coords.z},
    }

    table.insert(activeLocations, Location)
end

function GodsEye(reset) -- drawing / removing the blip
    if not reset then
        GetInformation()
        for i, location in pairs(activeLocations) do
            blip = AddBlipForRadius(location.pos.x, location.pos.y, location.pos.z, 400.0)
            SetBlipColour(blip, 69)
            SetBlipAlpha(blip, 50)
            SetBlipDisplay(blip, 2)
            SetBlipRotation(blip, 50)
            SetBlipAsShortRange(blip, true)
            foundPlayer = true
        end
    elseif reset then
        for i, location in pairs(activeLocations) do
            RemoveBlip(blip)
            foundPlayer = false
            activeLocations = {}
        end
    end
end

CreateThread(function() -- checking the countdown/cooldown on the blip
    while true do
        while foundPlayer do
            Wait(1*1000)
            count = count + 1
            count2 = count2 + 1
            if count2 == 15 then
                GodsEye(true)
                Wait(10)
                GodsEye(false)
                count2 = 0
            end
            if count == 300 then
                GodsEye(true)
                count = 0
                count2 = 0
                foundPlayer = false
            end
        end
        if count ~= 0 then
            while true do
                Wait(1*1000)
                count = count + 1
                if count == 300 then
                    count = 0
                    count2 = 0
                end
            end
        end
        Wait(1*1000)
    end
end)

function GodsEyes() -- basic information for the script
    if foundPlayer then -- remove the blip for the player & leave the cooldown
        GodsEye(true)
        foundPlayer = false
        lib.notify({
            title = 'God\'s Eye Reset',
            description = 'Removed the blip, you are still on cooldown for ' .. 300 - count .. ' seconds',
            type = 'success',
            position = 'center-right',
            duration = 6000,
        })
        return
    end

    local input = lib.inputDialog("God's Eye Menu", {
        {type = 'number', label = 'Player ID', description = 'Input a Player ID to track using God\'s Eye', icon = 'hashtag'}
    })

    if not input then return end

    targetId = input[1]  -- Convert the target ID to a number

    if targetId == cache.serverId then -- check if the person is self.
        lib.notify({
            title = 'God\'s Eye',
            description = 'You cannot track yourself.',
            type = 'error',
            position = 'center-right',
            duration = 6000,
        })
        targetId = nil
        return
    end

    if count ~= 0 then
        lib.notify({
            title = 'Active Cooldown',
            description = 'You are still on cooldown for ' .. 300 - count .. ' seconds',
            type = 'warning',
            position = 'center-right',
            duration = 6000,
        })
        return
    end

    if foundPlayer then
        lib.notify({
            title = 'Search In-Progress',
            description = 'Player search already in-progress',
            type = 'error',
            position = 'center-right',
            duration = 6000,
        })
        return
    end

    GodsEye(false)

    Wait(100)

    if foundPlayer then
        lib.notify({
            title = 'Located Player',
            description = 'We have successfully located player with ID: ' .. targetId .. ' God\'s Eye active for 5 minutes.',
            type = 'success',
            position = 'center-right',
            duration = 6000,
        })
    end
end

CreateThread(function() -- markers thread
    while true do
        local sleep = 2000
        for i, locations in pairs(GELocations) do
            local coords2 = GetEntityCoords(cache.ped)
            local distance = GetDistanceBetweenCoords(coords2.x, coords2.y, coords2.z, locations.x, locations.y, locations.z, true)
            if distance < 3 then -- draw the marker and allow the user to interact with God's Eye
                sleep = 50
                --DrawMarker(31, locations.x, locations.y, locations.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 128, 0, 50, false, true, 2, false, nil, nil)
                lib.showTextUI('[E] - Track Player', {
                    posistion = "top-center",
                    icon = 'globe',
                    style = {
                        borderRadius = 1,
                        backgroundColor = '#06402Bw',
                        color = 'white'
                    }
                })
                if IsControlPressed(0, 153) then
                    GodsEyes()
                end
            elseif distance > 3 then
                local isOpen = lib.isTextUIOpen()
                if isOpen then
                    lib.hideTextUI()
                end
            elseif distance > 10 and foundPlayer then -- remove the blip if person is not near the marker.
                GodsEye(true)
                foundPlayer = false
                count = 0
                count2 = 0
            end
        end
        Wait(sleep)
    end
end)

-- RegisterCommand('ge', function(source, raw)
--     GodsEyes()
-- end)