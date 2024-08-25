RegisterNetEvent('GodsEye:GetCoords')
AddEventHandler('GodsEye:GetCoords', function(serverId)
    if not serverId then
        TriggerClientEvent('GodsEye:SentCoords', source, nil, nil)
        return
    end
    local targetPed = GetPlayerPed(serverId)  -- Get the player's ped directly from their sersver ID
    if targetPed == 0 then
        TriggerClientEvent('GodsEye:SentCoords', source, nil, nil)
        return
    end
    if targetPed and DoesEntityExist(targetPed) then
        local coords = GetEntityCoords(targetPed)  -- Get the coordinates of the ped
        TriggerClientEvent('GodsEye:SentCoords', source, coords, targetPed)  -- Send the coordinates back to the client
        return
    elseif IsEntityDead(targetPed) then
        TriggerClientEvent('GodsEye:SentCoords', source, nil, targetPed)
        return
    else
        TriggerClientEvent('GodsEye:SentCoords', source, nil, nil)  -- If the ped doesn't exist, send nil
        return
    end
end)