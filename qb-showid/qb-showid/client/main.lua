local QBCore = exports['qb-core']:GetCoreObject()

local showIds = false

RegisterNetEvent('qb-showid:id')
AddEventHandler('qb-showid:id', function()
    showIds = not showIds
    if showIds then
        NotifyToggleIds(true)
    else
        NotifyToggleIds(false)
    end
end)

-- Toggle Show IDs on key press
CreateThread(function()
    while true do
        Wait(0)
        if Config.Key.Enabled then
            if IsControlJustReleased(0, Config.Key.Code) then
                showIds = not showIds
                NotifyToggleIds(showIds)
            end
        end
    end
end)

-- Toggle Show IDs Command
RegisterCommand('toggleids', function()
    showIds = not showIds
    NotifyToggleIds(showIds)
end, false)

-- Draw Things
CreateThread(function()
    while true do
        Wait(0)
        if showIds then
            local nearbyPlayers = GetNeareastPlayers()
            for k, v in pairs(nearbyPlayers) do
                local x, y, z = table.unpack(v.coords)
                Draw3DText(x, y, z + 1.1, v.playerId)
            end
        end
    end
end)

function Draw3DText(x, y, z, text)
    -- Check if coords are visible and get 2D screen coords
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        -- Calculate text scale to use
        local dist = GetDistanceBetweenCoords(GetGameplayCamCoords(), x, y, z, 1)
        local scale = 1 * (1 / dist) * (1 / GetGameplayCamFov()) * 100

        -- Draw text on screen
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function GetNeareastPlayers()
    local playerPed = PlayerPedId()
    local players, _ = QBCore.Functions.GetPlayers(GetEntityCoords(playerPed), Config.DrawDistance)

    local players_clean = {}
    local found_players = false

    for i = 1, #players, 1 do
        found_players = true
        table.insert(players_clean, { playerName = GetPlayerName(players[i]), playerId = GetPlayerServerId(players[i]), coords = GetEntityCoords(GetPlayerPed(players[i])) })
    end
    return players_clean
end

function NotifyToggleIds(enabled)
    local message = enabled and 'Show IDs enabled' or 'Show IDs disabled'
    local color = enabled and 'success' or 'error'
    QBCore.Functions.Notify(message, color)
end
