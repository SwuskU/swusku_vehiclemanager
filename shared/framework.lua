-- Framework Handler
Framework = {}
Framework.Ready = false

-- Initialize Framework
function Framework.Init()
    if Config.Framework == 'ESX' then
        Framework.InitESX()
    elseif Config.Framework == 'QB' then
        Framework.InitQB()
    else
        print('^1[ERROR] Unknown framework: ' .. Config.Framework .. '. Please use "ESX" or "QB"^7')
        return false
    end
    return true
end

-- Initialize ESX
function Framework.InitESX()
    if IsDuplicityVersion() then -- Server
        ESX = exports["es_extended"]:getSharedObject()
        Framework.Ready = true
        if Config.Debug then
            print('^2[FRAMEWORK] ESX initialized (Server)^7')
        end
    else -- Client
        ESX = exports["es_extended"]:getSharedObject()
        Framework.Ready = true
        if Config.Debug then
            print('^2[FRAMEWORK] ESX initialized (Client)^7')
        end
    end
end

-- Initialize QB-Core
function Framework.InitQB()
    if IsDuplicityVersion() then -- Server
        QBCore = exports['qb-core']:GetCoreObject()
        Framework.Ready = true
        if Config.Debug then
            print('^2[FRAMEWORK] QB-Core initialized (Server)^7')
        end
    else -- Client
        QBCore = exports['qb-core']:GetCoreObject()
        Framework.Ready = true
        if Config.Debug then
            print('^2[FRAMEWORK] QB-Core initialized (Client)^7')
        end
    end
end

-- Get Player Data
function Framework.GetPlayerData()
    if Config.Framework == 'ESX' then
        if ESX and ESX.GetPlayerData then
            return ESX.GetPlayerData()
        end
    elseif Config.Framework == 'QB' then
        if QBCore and QBCore.Functions and QBCore.Functions.GetPlayerData then
            return QBCore.Functions.GetPlayerData()
        end
    end
    return {}
end

-- Get Player (Server-side)
function Framework.GetPlayer(source)
    if not IsDuplicityVersion() then return nil end
    
    if Config.Framework == 'ESX' then
        if ESX and ESX.GetPlayerFromId then
            return ESX.GetPlayerFromId(source)
        end
    elseif Config.Framework == 'QB' then
        if QBCore and QBCore.Functions and QBCore.Functions.GetPlayer then
            return QBCore.Functions.GetPlayer(source)
        end
    end
    return nil
end

-- Show Notification
function Framework.ShowNotification(message, type)
    if Config.Framework == 'ESX' then
        if ESX and ESX.ShowNotification then
            ESX.ShowNotification(message, type or 'info')
        end
    elseif Config.Framework == 'QB' then
        if QBCore and QBCore.Functions and QBCore.Functions.Notify then
            local qbType = 'primary'
            if type == 'error' then qbType = 'error'
            elseif type == 'success' then qbType = 'success'
            elseif type == 'warning' then qbType = 'warning' end
            
            QBCore.Functions.Notify(message, qbType)
        end
    else
        -- Fallback to native GTA notification
        SetNotificationTextEntry('STRING')
        AddTextComponentString(message)
        DrawNotification(0, 1)
    end
end

-- Check if player is admin
function Framework.IsPlayerAdmin(source)
    if not IsDuplicityVersion() then return false end
    
    local player = Framework.GetPlayer(source)
    if not player then return false end
    
    if Config.Framework == 'ESX' then
        return player.getGroup() == 'admin' or player.getGroup() == 'superadmin'
    elseif Config.Framework == 'QB' then
        local permission = QBCore.Functions.GetPermission(source)
        return permission == 'admin' or permission == 'god'
    end
    
    return false
end

-- Get player job
function Framework.GetPlayerJob(playerData)
    if not playerData then return nil end
    
    if Config.Framework == 'ESX' then
        return playerData.job
    elseif Config.Framework == 'QB' then
        return playerData.job
    end
    
    return nil
end

-- Check if player has job
function Framework.HasJob(playerData, jobName)
    local job = Framework.GetPlayerJob(playerData)
    if not job then return false end
    
    if Config.Framework == 'ESX' then
        return job.name == jobName
    elseif Config.Framework == 'QB' then
        return job.name == jobName
    end
    
    return false
end

-- Get framework name for display
function Framework.GetFrameworkName()
    if Config.Framework == 'ESX' then
        return 'ESX Legacy'
    elseif Config.Framework == 'QB' then
        return 'QB-Core'
    end
    return 'Unknown'
end

-- Wait for framework to be ready
function Framework.WaitForReady()
    while not Framework.Ready do
        Wait(100)
    end
end

-- Initialize framework on resource start
CreateThread(function()
    Wait(1000) -- Wait a bit for other resources to load
    
    if Framework.Init() then
        if Config.Debug then
            print('^2[SWUSKU VEHICLE MANAGER] Framework initialized: ' .. Framework.GetFrameworkName() .. '^7')
        end
    else
        print('^1[SWUSKU VEHICLE MANAGER] Failed to initialize framework!^7')
    end
end)
