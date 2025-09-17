Locales = {}

local currentLocale = Config.Locale or 'en'
local translations = {}

-- Load translation file
function LoadLocale(locale)
    local file = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. locale .. '.json')
    if file then
        translations[locale] = json.decode(file)
        return true
    end
    return false
end

-- Initialize locales
function InitLocales()
    -- Load default locale
    if not LoadLocale(currentLocale) then
        print('[ERROR] Failed to load locale: ' .. currentLocale)
        currentLocale = 'en'
        if not LoadLocale('en') then
            print('[ERROR] Failed to load fallback locale: en')
            return false
        end
    end
    
    -- Load English as fallback
    if currentLocale ~= 'en' then
        LoadLocale('en')
    end
    
    return true
end

-- Get translated text
function _(key, ...)
    local args = {...}
    local translation = nil
    
    -- Try current locale first
    if translations[currentLocale] and translations[currentLocale][key] then
        translation = translations[currentLocale][key]
    -- Fallback to English
    elseif translations['en'] and translations['en'][key] then
        translation = translations['en'][key]
    else
        -- Return key if no translation found
        translation = key
        if Config.Debug then
            print('[WARNING] Missing translation for key: ' .. key)
        end
    end
    
    -- Replace placeholders
    if #args > 0 then
        for i, arg in ipairs(args) do
            translation = string.gsub(translation, '{' .. i .. '}', tostring(arg))
        end
    end
    
    -- Replace named placeholders
    if type(args[1]) == 'table' then
        for k, v in pairs(args[1]) do
            translation = string.gsub(translation, '{' .. k .. '}', tostring(v))
        end
    end
    
    return translation
end

-- Set current locale
function SetLocale(locale)
    if LoadLocale(locale) then
        currentLocale = locale
        return true
    end
    return false
end

-- Get current locale
function GetLocale()
    return currentLocale
end

-- Get available locales
function GetAvailableLocales()
    local locales = {}
    local files = {'de', 'en', 'ru', 'ja'}
    
    for _, locale in ipairs(files) do
        if LoadLocale(locale) then
            table.insert(locales, locale)
        end
    end
    
    return locales
end

-- Initialize on resource start
CreateThread(function()
    if not InitLocales() then
        print('[ERROR] Failed to initialize locales for ' .. GetCurrentResourceName())
    else
        if Config.Debug then
            print('[INFO] Locales initialized for ' .. GetCurrentResourceName() .. ' (Current: ' .. currentLocale .. ')')
        end
    end
end)
