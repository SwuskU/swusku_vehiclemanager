let vehicleData = {};
let vehicleStates = {};
let translations = {};
let isDriver = false;

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    setupEventListeners();
});

// Setup event listeners
function setupEventListeners() {
    // Close button
    document.getElementById('close-btn').addEventListener('click', closeMenu);
    
    // Action buttons
    document.querySelectorAll('.action-btn').forEach(btn => {
        btn.addEventListener('click', handleActionClick);
    });
    
    // Control buttons
    document.querySelectorAll('.control-btn').forEach(btn => {
        btn.addEventListener('click', handleControlClick);
    });
    
    // ESC key to close menu
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeMenu();
        }
    });
    
    // Prevent context menu
    document.addEventListener('contextmenu', function(e) {
        e.preventDefault();
    });
}

// Handle action button clicks
function handleActionClick(e) {
    const btn = e.currentTarget;
    const action = btn.dataset.action;
    const direction = btn.dataset.direction;
    
    if (!isDriver && ['lock', 'engine', 'lights', 'speedLimiter', 'cruiseControl', 'indicator'].includes(action)) {
        return; // Only driver can perform these actions
    }
    
    let payload = { action: action };
    
    if (direction) {
        payload.param = { direction: direction };
    }
    
    sendAction(payload);
    updateButtonStates();
}

// Handle control button clicks
function handleControlClick(e) {
    const btn = e.currentTarget;
    const action = btn.dataset.action;
    const index = parseInt(btn.dataset.index);
    const param = btn.dataset.param;
    
    const payload = {
        action: action,
        param: {
            index: index,
            action: param
        }
    };
    
    sendAction(payload);
}

// Send action to Lua
function sendAction(payload) {
    fetch(`https://${GetParentResourceName()}/vehicleAction`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
    }).catch(err => console.error('Error sending action:', err));
}

// Close menu
function closeMenu() {
    document.getElementById('vehicle-menu').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).catch(err => console.error('Error closing menu:', err));
}

// Update button states based on vehicle states
function updateButtonStates() {
    // Lock button
    const lockBtn = document.getElementById('lock-btn');
    const lockText = document.getElementById('lock-text');
    if (vehicleStates.locked) {
        lockBtn.classList.add('active');
        lockText.textContent = '🔓 Unlock';
    } else {
        lockBtn.classList.remove('active');
        lockText.textContent = '🔒 Lock';
    }
    
    // Engine button
    const engineBtn = document.getElementById('engine-btn');
    const engineText = document.getElementById('engine-text');
    if (vehicleStates.engine) {
        engineBtn.classList.add('active');
        engineText.textContent = '⛽ Stop Engine';
    } else {
        engineBtn.classList.remove('active');
        engineText.textContent = '🔥 Start Engine';
    }
    
    // Lights button
    const lightsBtn = document.getElementById('lights-btn');
    const lightsText = document.getElementById('lights-text');
    if (vehicleStates.lights) {
        lightsBtn.classList.add('active');
        lightsText.textContent = '🌙 Lights Off';
    } else {
        lightsBtn.classList.remove('active');
        lightsText.textContent = '💡 Lights On';
    }
    
    // Speed limiter button
    const speedLimiterBtn = document.getElementById('speed-limiter-btn');
    const speedLimiterText = document.getElementById('speed-limiter-text');
    if (vehicleStates.speedLimiter && vehicleStates.speedLimiter.enabled) {
        speedLimiterBtn.classList.add('active');
        speedLimiterText.textContent = `⚡ Limited (${vehicleStates.speedLimiter.speed} km/h)`;
    } else {
        speedLimiterBtn.classList.remove('active');
        speedLimiterText.textContent = '⚡ Speed Limiter';
    }
    
    // Cruise control button
    const cruiseControlText = document.getElementById('cruise-control-text');
    if (vehicleStates.cruiseControl && vehicleStates.cruiseControl.enabled) {
        cruiseControlText.textContent = `🎯 Cruise (${vehicleStates.cruiseControl.speed} km/h)`;
    } else {
        cruiseControlText.textContent = '🎯 Cruise Control';
    }
    
    // Disable buttons if not driver
    if (!isDriver) {
        document.querySelectorAll('.action-btn').forEach(btn => {
            const action = btn.dataset.action;
            if (['lock', 'engine', 'lights', 'speedLimiter', 'cruiseControl', 'indicator'].includes(action)) {
                btn.classList.add('disabled');
            }
        });
    } else {
        document.querySelectorAll('.action-btn').forEach(btn => {
            btn.classList.remove('disabled');
        });
    }
}

// Update translations
function updateTranslations() {
    if (!translations) return;
    
    // Update text elements
    const elements = {
        'menu-title': translations.title,
        'lock-text': translations.lock_unlock,
        'engine-text': translations.engine_toggle,
        'lights-text': translations.lights_toggle,
        'windows-title': translations.windows,
        'doors-title': translations.doors,
        'indicators-title': translations.indicators,
        'speed-limiter-text': translations.speed_limiter,
        'cruise-control-text': translations.cruise_control
    };
    
    for (const [id, text] of Object.entries(elements)) {
        const element = document.getElementById(id);
        if (element && text) {
            element.textContent = text;
        }
    }
}

// Handle messages from Lua
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch (data.action) {
        case 'openMenu':
            vehicleData = data.vehicleData || {};
            vehicleStates = data.vehicleStates || {};
            translations = data.translations || {};
            isDriver = data.isDriver || false;
            
            updateTranslations();
            updateButtonStates();
            
            document.getElementById('vehicle-menu').classList.remove('hidden');
            break;
            
        case 'closeMenu':
            document.getElementById('vehicle-menu').classList.add('hidden');
            break;
            
        case 'updateStates':
            vehicleStates = data.vehicleStates || {};
            updateButtonStates();
            break;
    }
});

// Utility function to get current resource name
function GetParentResourceName() {
    return window.location.hostname;
}
