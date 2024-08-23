RegisterNetEvent('GodsEye:ShareLocation')

RegisterNetEvent('GodsEye:GetCoords')
AddEventHandler('GodsEye:GetCoords', function(serverId)
    local targetPed = GetPlayerPed(serverId)  -- Get the player's ped directly from their server ID
    if targetPed and DoesEntityExist(targetPed) then
        local coords = GetEntityCoords(targetPed)  -- Get the coordinates of the ped
        TriggerClientEvent('GodsEye:SentCoords', source, coords, targetPed)  -- Send the coordinates back to the client
    elseif IsEntityDead(targetPed) then
        TriggerClientEvent('GodsEye:SentCoords', source, nil, targetPed)
    else
        TriggerClientEvent('GodsEye:SentCoords', source, nil, nil)  -- If the ped doesn't exist, send nil
    end
end)