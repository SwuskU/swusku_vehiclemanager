Config = {}

-- Framework Settings
Config.Framework = 'ESX' -- Choose your framework: 'ESX' or 'QB' (QB-Core)

-- General Settings
Config.Locale = 'de' -- Default language (de, en, ru, ja)
Config.UpdateChecker = true -- Enable update checker
Config.Debug = false -- Enable debug mode

-- Update Checker Settings
Config.UpdateCheck = {
    enabled = true,
    repository = 'SwuskuRP/swusku_vehiclemanager',
    checkInterval = 3600000, -- Check every hour (in ms)
    currentVersion = '1.0.0'
}

-- Key Bindings
Config.Keys = {
    vehicleMenu = 'F6', -- Open vehicle menu
    lockVehicle = 'U', -- Lock/Unlock vehicle
    engine = 'G', -- Toggle engine
    lights = 'L', -- Toggle lights
    indicators = {
        left = 'Q',
        right = 'E',
        hazard = 'X'
    }
}

-- Vehicle Features
Config.Features = {
    lockSystem = true, -- Enable lock/unlock system
    engineToggle = true, -- Enable engine toggle
    lightToggle = true, -- Enable light toggle
    windowControl = true, -- Enable window control
    doorControl = true, -- Enable door control
    indicatorControl = true, -- Enable indicator control
    speedLimiter = true, -- Enable speed limiter
    cruiseControl = true -- Enable cruise control
}

-- Permissions
Config.Permissions = {
    adminOnly = false, -- Restrict to admins only
    jobRestricted = false, -- Restrict to specific jobs
    allowedJobs = {'police', 'ambulance', 'mechanic'} -- Jobs allowed to use (if jobRestricted = true)
}

-- UI Settings
Config.UI = {
    position = 'top-right', -- Position of notifications (top-left, top-right, bottom-left, bottom-right)
    theme = 'dark', -- Theme (dark, light)
    showKeybinds = true, -- Show keybind hints
    animationSpeed = 300 -- Animation speed in ms
}

-- Vehicle Classes (which vehicle classes can use the system)
Config.AllowedVehicleClasses = {
    [0] = true,  -- Compacts
    [1] = true,  -- Sedans
    [2] = true,  -- SUVs
    [3] = true,  -- Coupes
    [4] = true,  -- Muscle
    [5] = true,  -- Sports Classics
    [6] = true,  -- Sports
    [7] = true,  -- Super
    [8] = true,  -- Motorcycles
    [9] = true,  -- Off-road
    [10] = true, -- Industrial
    [11] = true, -- Utility
    [12] = true, -- Vans
    [13] = false, -- Cycles (disabled by default)
    [14] = false, -- Boats (disabled by default)
    [15] = false, -- Helicopters (disabled by default)
    [16] = false, -- Planes (disabled by default)
    [17] = true, -- Service
    [18] = false, -- Emergency (police, ambulance, fire)
    [19] = true, -- Military
    [20] = true, -- Commercial
    [21] = false  -- Trains (disabled by default)
}

-- Sound Settings
Config.Sounds = {
    enabled = true,
    lockSound = 'car_lock',
    unlockSound = 'car_unlock',
    engineStartSound = 'engine_start',
    engineStopSound = 'engine_stop',
    volume = 0.5
}
