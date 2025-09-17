local PlayerData = {}
local currentVehicle = nil
local isInVehicle = false
local isDriver = false
local vehicleData = {}
local menuOpen = false

-- Vehicle states
local vehicleStates = {
    locked = false,
    engine = false,
    lights = false,
    speedLimiter = {
        enabled = false,
        speed = 0
    },
    cruiseControl = {
        enabled = false,
        speed = 0
    },
    indicators = {
        left = false,
        right = false,
        hazard = false
    }
}

-- Wait for framework to be ready
CreateThread(function()
    Framework.WaitForReady()
    PlayerData = Framework.GetPlayerData()
    
    if Config.Debug then
        print('^2[CLIENT] Framework ready, player data loaded^7')
    end
end)

-- Framework-specific event handlers
if Config.Framework == 'ESX' then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
    end)

    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        PlayerData.job = job
    end)
elseif Config.Framework == 'QB' then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = Framework.GetPlayerData()
    end)

    RegisterNetEvent('QBCore:Client:OnJobUpdate')
    AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
        PlayerData.job = JobInfo
    end)
end

-- Main thread for vehicle detection
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        if vehicle ~= 0 then
            if not isInVehicle or currentVehicle ~= vehicle then
                currentVehicle = vehicle
                isInVehicle = true
                isDriver = GetPedInVehicleSeat(vehicle, -1) == ped
                
                -- Initialize vehicle data
                vehicleData = {
                    model = GetEntityModel(vehicle),
                    class = GetVehicleClass(vehicle),
                    plate = GetVehicleNumberPlateText(vehicle),
                    hash = GetEntityModel(vehicle)
                }
                
                -- Update vehicle states
                UpdateVehicleStates()
            end
        else
            if isInVehicle then
                currentVehicle = nil
                isInVehicle = false
                isDriver = false
                vehicleData = {}
                ResetVehicleStates()
                
                if menuOpen then
                    CloseVehicleMenu()
                end
            end
        end
        
        Wait(500)
    end
end)

-- Update vehicle states
function UpdateVehicleStates()
    if not currentVehicle or currentVehicle == 0 then return end
    
    vehicleStates.locked = GetVehicleDoorLockStatus(currentVehicle) >= 2
    vehicleStates.engine = GetIsVehicleEngineRunning(currentVehicle)
    vehicleStates.lights = IsVehicleLightOn(currentVehicle, 0) or IsVehicleLightOn(currentVehicle, 1)
end

-- Reset vehicle states
function ResetVehicleStates()
    vehicleStates = {
        locked = false,
        engine = false,
        lights = false,
        speedLimiter = {enabled = false, speed = 0},
        cruiseControl = {enabled = false, speed = 0},
        indicators = {left = false, right = false, hazard = false}
    }
end

-- Check permissions
function HasPermission()
    if not PlayerData then return false end
    
    if Config.Permissions.adminOnly then
        if Config.Framework == 'ESX' then
            return PlayerData.group == 'admin' or PlayerData.group == 'superadmin'
        elseif Config.Framework == 'QB' then
            return PlayerData.metadata and (PlayerData.metadata.group == 'admin' or PlayerData.metadata.group == 'god')
        end
    end
    
    if Config.Permissions.jobRestricted then
        local job = Framework.GetPlayerJob(PlayerData)
        if job then
            for _, allowedJob in ipairs(Config.Permissions.allowedJobs) do
                if job.name == allowedJob then
                    return true
                end
            end
        end
        return false
    end
    
    return true
end

-- Check if vehicle is allowed
function IsVehicleAllowed()
    if not currentVehicle or not vehicleData.class then return false end
    return Config.AllowedVehicleClasses[vehicleData.class] == true
end

-- Lock/Unlock vehicle
function ToggleVehicleLock()
    if not isInVehicle or not isDriver then
        ShowNotification(_('not_driver'))
        return
    end
    
    if not IsVehicleAllowed() then return end
    
    local isLocked = GetVehicleDoorLockStatus(currentVehicle) >= 2
    
    if isLocked then
        SetVehicleDoorsLocked(currentVehicle, 1)
        vehicleStates.locked = false
        ShowNotification(_('vehicle_unlocked'))
        PlaySoundEffect('car_unlock')
    else
        SetVehicleDoorsLocked(currentVehicle, 2)
        vehicleStates.locked = true
        ShowNotification(_('vehicle_locked'))
        PlaySoundEffect('car_lock')
    end
end

-- Toggle engine
function ToggleEngine()
    if not isInVehicle or not isDriver then
        ShowNotification(_('not_driver'))
        return
    end
    
    if not IsVehicleAllowed() then return end
    
    local engineRunning = GetIsVehicleEngineRunning(currentVehicle)
    
    if engineRunning then
        SetVehicleEngineOn(currentVehicle, false, false, true)
        vehicleStates.engine = false
        ShowNotification(_('engine_stopped'))
        PlaySoundEffect('engine_stop')
    else
        SetVehicleEngineOn(currentVehicle, true, false, true)
        vehicleStates.engine = true
        ShowNotification(_('engine_started'))
        PlaySoundEffect('engine_start')
    end
end

-- Toggle lights
function ToggleLights()
    if not isInVehicle or not isDriver then
        ShowNotification(_('not_driver'))
        return
    end
    
    if not IsVehicleAllowed() then return end
    
    local lightsOn = IsVehicleLightOn(currentVehicle, 0) or IsVehicleLightOn(currentVehicle, 1)
    
    if lightsOn then
        SetVehicleLights(currentVehicle, 1) -- Turn off
        vehicleStates.lights = false
        ShowNotification(_('lights_off'))
    else
        SetVehicleLights(currentVehicle, 2) -- Turn on
        vehicleStates.lights = true
        ShowNotification(_('lights_on'))
    end
end

-- Control windows
function ControlWindow(windowIndex, action)
    if not isInVehicle or not isDriver then
        ShowNotification(_('not_driver'))
        return
    end
    
    if not IsVehicleAllowed() then return end
    
    if action == 'up' then
        RollUpWindow(currentVehicle, windowIndex)
        ShowNotification(_('window_up'))
    elseif action == 'down' then
        RollDownWindow(currentVehicle, windowIndex)
        ShowNotification(_('window_down'))
    end
end

-- Control doors
function ControlDoor(doorIndex, action)
    if not isInVehicle then
        ShowNotification(_('no_vehicle'))
        return
    end
    
    if not IsVehicleAllowed() then return end
    
    if action == 'open' then
        SetVehicleDoorOpen(currentVehicle, doorIndex, false, false)
        ShowNotification(_('door_open'))
    elseif action == 'close' then
        SetVehicleDoorShut(currentVehicle, doorIndex, false)
        ShowNotification(_('door_close'))
    end
end

-- Control indicators
function ControlIndicator(direction)
    if not isInVehicle or not isDriver then
        ShowNotification(_('not_driver'))
        return
    end
    
    if not IsVehicleAllowed() then return end
    
    if direction == 'left' then
        SetVehicleIndicatorLights(currentVehicle, 1, not vehicleStates.indicators.left)
        vehicleStates.indicators.left = not vehicleStates.indicators.left
        vehicleStates.indicators.right = false
        vehicleStates.indicators.hazard = false
        ShowNotification(_('left_indicator'))
    elseif direction == 'right' then
        SetVehicleIndicatorLights(currentVehicle, 0, not vehicleStates.indicators.right)
        vehicleStates.indicators.right = not vehicleStates.indicators.right
        vehicleStates.indicators.left = false
        vehicleStates.indicators.hazard = false
        ShowNotification(_('right_indicator'))
    elseif direction == 'hazard' then
        local hazardState = not vehicleStates.indicators.hazard
        SetVehicleIndicatorLights(currentVehicle, 0, hazardState)
        SetVehicleIndicatorLights(currentVehicle, 1, hazardState)
        vehicleStates.indicators.hazard = hazardState
        vehicleStates.indicators.left = false
        vehicleStates.indicators.right = false
        ShowNotification(_('hazard_lights'))
    end
end

-- Speed limiter
function ToggleSpeedLimiter()
    if not isInVehicle or not isDriver then
        ShowNotification(_('not_driver'))
        return
    end
    
    if not IsVehicleAllowed() then return end
    
    if vehicleStates.speedLimiter.enabled then
        SetEntityMaxSpeed(currentVehicle, 0.0)
        vehicleStates.speedLimiter.enabled = false
        vehicleStates.speedLimiter.speed = 0
        ShowNotification(_('speed_limiter_off'))
    else
        local speed = GetEntitySpeed(currentVehicle) * 3.6 -- Convert to km/h
        if speed > 10 then -- Only set if moving
            SetEntityMaxSpeed(currentVehicle, speed / 3.6) -- Convert back to m/s
            vehicleStates.speedLimiter.enabled = true
            vehicleStates.speedLimiter.speed = math.floor(speed)
            ShowNotification(_('speed_limited', {speed = vehicleStates.speedLimiter.speed}))
        end
    end
end

-- Cruise control
function ToggleCruiseControl()
    if not isInVehicle or not isDriver then
        ShowNotification(_('not_driver'))
        return
    end
    
    if not IsVehicleAllowed() then return end
    
    if vehicleStates.cruiseControl.enabled then
        SetVehicleForwardSpeed(currentVehicle, 0.0)
        vehicleStates.cruiseControl.enabled = false
        vehicleStates.cruiseControl.speed = 0
        ShowNotification(_('cruise_control_off'))
    else
        local speed = GetEntitySpeed(currentVehicle) * 3.6 -- Convert to km/h
        if speed > 20 then -- Only set if moving at reasonable speed
            vehicleStates.cruiseControl.enabled = true
            vehicleStates.cruiseControl.speed = math.floor(speed)
            ShowNotification(_('cruise_control_on', {speed = vehicleStates.cruiseControl.speed}))
            
            -- Maintain cruise control speed
            CreateThread(function()
                while vehicleStates.cruiseControl.enabled and isInVehicle and isDriver do
                    if GetEntitySpeed(currentVehicle) * 3.6 < vehicleStates.cruiseControl.speed - 5 then
                        SetVehicleForwardSpeed(currentVehicle, vehicleStates.cruiseControl.speed / 3.6)
                    end
                    Wait(100)
                end
            end)
        end
    end
end

-- Show notification
function ShowNotification(message, type)
    Framework.ShowNotification(message, type)
end

-- Play sound effect
function PlaySoundEffect(soundName)
    if not Config.Sounds.enabled then return end
    
    -- You can implement custom sounds here
    -- For now, we'll use basic game sounds
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
end

-- Key bindings
CreateThread(function()
    while true do
        Wait(0)
        
        if isInVehicle and HasPermission() then
            -- Vehicle menu
            if IsControlJustPressed(0, 167) then -- F6
                if not menuOpen then
                    OpenVehicleMenu()
                else
                    CloseVehicleMenu()
                end
            end
            
            -- Quick actions
            if IsControlJustPressed(0, 303) then -- U
                ToggleVehicleLock()
            end
            
            if IsControlJustPressed(0, 47) then -- G
                ToggleEngine()
            end
            
            if IsControlJustPressed(0, 182) then -- L
                ToggleLights()
            end
            
            -- Indicators
            if IsControlJustPressed(0, 44) then -- Q
                ControlIndicator('left')
            end
            
            if IsControlJustPressed(0, 38) then -- E
                ControlIndicator('right')
            end
            
            if IsControlJustPressed(0, 73) then -- X
                ControlIndicator('hazard')
            end
        else
            Wait(500)
        end
    end
end)

-- Vehicle menu functions (will be implemented with NUI)
function OpenVehicleMenu()
    if not isInVehicle then
        ShowNotification(_('no_vehicle'))
        return
    end
    
    if not HasPermission() then
        ShowNotification(_('no_permission'))
        return
    end
    
    if not IsVehicleAllowed() then return end
    
    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openMenu',
        vehicleData = vehicleData,
        vehicleStates = vehicleStates,
        isDriver = isDriver,
        translations = {
            title = _('vehicle_menu_title'),
            lock_unlock = _('lock_unlock'),
            engine_toggle = _('engine_toggle'),
            lights_toggle = _('lights_toggle'),
            windows = _('windows'),
            doors = _('doors'),
            indicators = _('indicators'),
            speed_limiter = _('speed_limiter'),
            cruise_control = _('cruise_control')
        }
    })
end

function CloseVehicleMenu()
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeMenu'
    })
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    CloseVehicleMenu()
    cb('ok')
end)

RegisterNUICallback('vehicleAction', function(data, cb)
    local action = data.action
    local param = data.param
    
    if action == 'lock' then
        ToggleVehicleLock()
    elseif action == 'engine' then
        ToggleEngine()
    elseif action == 'lights' then
        ToggleLights()
    elseif action == 'window' then
        ControlWindow(param.index, param.action)
    elseif action == 'door' then
        ControlDoor(param.index, param.action)
    elseif action == 'indicator' then
        ControlIndicator(param.direction)
    elseif action == 'speedLimiter' then
        ToggleSpeedLimiter()
    elseif action == 'cruiseControl' then
        ToggleCruiseControl()
    end
    
    cb('ok')
end)

-- Update notifications from server
RegisterNetEvent('swusku_vehiclemanager:updateAvailable')
AddEventHandler('swusku_vehiclemanager:updateAvailable', function(version, url)
    if Framework.IsPlayerAdmin and Framework.IsPlayerAdmin(PlayerId()) then
        ShowNotification(_('update_available', {version = version}), 'info')
    end
end)

RegisterNetEvent('swusku_vehiclemanager:updateCheckFailed')
AddEventHandler('swusku_vehiclemanager:updateCheckFailed', function()
    if Framework.IsPlayerAdmin and Framework.IsPlayerAdmin(PlayerId()) then
        ShowNotification(_('update_check_failed'), 'error')
    end
end)

-- General notification event
RegisterNetEvent('swusku_vehiclemanager:notification')
AddEventHandler('swusku_vehiclemanager:notification', function(message, type)
    ShowNotification(message, type)
end)
