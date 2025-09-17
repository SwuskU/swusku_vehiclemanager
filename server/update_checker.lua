local UpdateChecker = {}

-- GitHub API endpoint for releases
local GITHUB_API = 'https://api.github.com/repos/%s/releases/latest'

-- Check for updates
function UpdateChecker.CheckForUpdates()
    if not Config.UpdateCheck.enabled then
        return
    end
    
    local url = string.format(GITHUB_API, Config.UpdateCheck.repository)
    
    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)
            if data and data.tag_name then
                local latestVersion = data.tag_name:gsub('v', '') -- Remove 'v' prefix if present
                local currentVersion = Config.UpdateCheck.currentVersion
                
                if UpdateChecker.CompareVersions(latestVersion, currentVersion) > 0 then
                    -- New version available
                    print('^3[UPDATE CHECKER] ^7New version available: ^2' .. latestVersion .. '^7 (Current: ^1' .. currentVersion .. '^7)')
                    print('^3[UPDATE CHECKER] ^7Download: ^4' .. data.html_url .. '^7')
                    
                    -- Notify all players with admin permission
                    TriggerClientEvent('swusku_vehiclemanager:updateAvailable', -1, latestVersion, data.html_url)
                else
                    if Config.Debug then
                        print('^2[UPDATE CHECKER] ^7You are running the latest version: ^2' .. currentVersion .. '^7')
                    end
                end
            end
        else
            if Config.Debug then
                print('^1[UPDATE CHECKER] ^7Failed to check for updates. Status code: ^1' .. statusCode .. '^7')
            end
            TriggerClientEvent('swusku_vehiclemanager:updateCheckFailed', -1)
        end
    end, 'GET', '', {
        ['User-Agent'] = 'Swusku-VehicleManager/' .. Config.UpdateCheck.currentVersion
    })
end

-- Compare version strings (returns: 1 if v1 > v2, -1 if v1 < v2, 0 if equal)
function UpdateChecker.CompareVersions(v1, v2)
    local function normalize(v)
        local parts = {}
        for part in v:gmatch('[^%.]+') do
            table.insert(parts, tonumber(part) or 0)
        end
        return parts
    end
    
    local parts1 = normalize(v1)
    local parts2 = normalize(v2)
    
    local maxLength = math.max(#parts1, #parts2)
    
    for i = 1, maxLength do
        local p1 = parts1[i] or 0
        local p2 = parts2[i] or 0
        
        if p1 > p2 then
            return 1
        elseif p1 < p2 then
            return -1
        end
    end
    
    return 0
end

-- Initialize update checker
function UpdateChecker.Initialize()
    if not Config.UpdateCheck.enabled then
        return
    end
    
    -- Check on startup
    CreateThread(function()
        Wait(5000) -- Wait 5 seconds after resource start
        UpdateChecker.CheckForUpdates()
    end)
    
    -- Set up periodic checks
    if Config.UpdateCheck.checkInterval > 0 then
        CreateThread(function()
            while true do
                Wait(Config.UpdateCheck.checkInterval)
                UpdateChecker.CheckForUpdates()
            end
        end)
    end
end

-- Manual update check command (admin only)
RegisterCommand('checkupdates', function(source, args, rawCommand)
    if source == 0 then -- Console
        UpdateChecker.CheckForUpdates()
        return
    end
    
    -- Check if player is admin
    if Framework.IsPlayerAdmin(source) then
        UpdateChecker.CheckForUpdates()
        TriggerClientEvent('swusku_vehiclemanager:notification', source, _('update_check_started'), 'info')
    else
        TriggerClientEvent('swusku_vehiclemanager:notification', source, _('no_permission'), 'error')
    end
end, false)

-- Export functions
exports('CheckForUpdates', UpdateChecker.CheckForUpdates)
exports('CompareVersions', UpdateChecker.CompareVersions)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        UpdateChecker.Initialize()
        print('^2[SWUSKU VEHICLE MANAGER] ^7' .. _('script_loaded', {version = Config.UpdateCheck.currentVersion}) .. '^7')
    end
end)
