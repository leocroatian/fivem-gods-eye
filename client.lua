RegisterNetEvent('GodsEye:SentCoords')

local foundPlayer = false
local count = 0
local count2 = 0
local targetId
local activeLocations = {}
local blip
local coords
local ped

AddEventHandler('GodsEye:SentCoords', function(cd, pd) -- server sided event when the coordinates get sent back to the client
    coords = cd
    ped = pd
end)

local function Notify(message, type, duration)
    if not duration then
        duration = 3000
    end
    lib.notify({title='God\'s Eye', description=message, type=type, position='center-right', duration=duration})
end

function GetInformation() -- getting the coordinates for the selected player
    TriggerServerEvent('GodsEye:GetCoords', targetId)
    Wait(500)

    if coords == nil then
        Notify('The specified player could not be found', 'error')
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
        Notify('Reset you are still on cooldown for ' .. 300 - count .. ' seconds', 'success')
        return
    end

    local input = lib.inputDialog("God's Eye Menu", {
        {type = 'number', label = 'Player ID', description = 'Input a Player ID to track using God\'s Eye', icon = 'hashtag'}
    })

    if not input then return end

    targetId = input[1]  -- Convert the target ID to a number

    if targetId == cache.serverId then -- check if the person is self.
        Notify('You cannot track yourself.', 'error', 6000)
        targetId = nil
        return
    end

    if count ~= 0 then
        Notify('You are still on cooldown for ' .. 300 - count .. ' seconds', 'warning', 6000)
        return
    end

    if foundPlayer then
        Notify('Player search already in-progress', 'warning', 3000)
        return
    end

    GodsEye(false)

    Wait(100)

    if foundPlayer then
        Notify('Player #' .. targetId .. ' located', 'success', 6000)
    end
end

-- Distance thread variables --
local curLocation
local distance

CreateThread(function()
    while true do
        for i, locations in pairs(GELocations) do
            local coords2 = GetEntityCoords(cache.ped)
            if curLocation then
                distance = GetDistanceBetweenCoords(coords2.x, coords2.y, coords2.z, curLocation.x, curLocation.y, curLocation.z, true)
            else
                distance = GetDistanceBetweenCoords(coords2.x, coords2.y, coords2.z, locations.x, locations.y, locations.z, true)
                if distance < 3 then
                    curLocation = vector3(locations.x, locations.y, locations.z)
                end
            end
        end
        Wait(2000)
    end
end)

CreateThread(function()
    while true do
        local sleep = 2000
        if distance < 3 then
            sleep = 50
            lib.showTextUI('[E] - Track Player', {
                posistion = "top-center",
                icon = 'globe',
                style = {
                    borderRadius = 1,
                    backgroundColor = '#06402B',
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
        end
        if distance > 10 and foundPlayer then
            curLocation = nil
            GodsEye(true)
            foundPlayer = false
            count = 0
            count2 = 0
        end 
        Wait(sleep)
    end
end)

-- RegisterCommand('ge', function(source, raw)
--     GodsEyes()
-- end)