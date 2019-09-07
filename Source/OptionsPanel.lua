local CT = ControllerTweaks

local panelData = {
    type = "panel",
    name = "Controller Tweaks",
    displayName = "Controlle Tweaks Options",
    author = "Xeio",
    version = "0.1",
    slashCommand = "/controllertweaks",
    registerForRefresh = true,
    registerForDefaults = true,
}

local NONE = GetString(SI_ITEMTYPE0)
local LEFT_STICK = GetString(SI_KEYCODE129)
local RIGHT_STICK = GetString(SI_KEYCODE130)
local QUATERNARY = GetString(SI_BINDING_NAME_UI_SHORTCUT_QUATERNARY)

local options = {
    {
        type = "dropdown",
        name = "Toggle Junk Hotkey",
        tooltip = "Hotkey for toggle junk command.",
        choices = {NONE, LEFT_STICK, RIGHT_STICK, QUATERNARY},
        choicesValues = {"NONE", "UI_SHORTCUT_LEFT_STICK", "UI_SHORTCUT_RIGHT_STICK", "UI_SHORTCUT_QUATERNARY"},
        getFunc = function() return CT.Settings.JunkHotkey end,
        setFunc = function(var) CT.Settings.JunkHotkey = var end,
        width = "full",
        default = "UI_SHORTCUT_LEFT_STICK"
        -- warning = "Will need to reload the UI.",	--(optional)
    }
}

CT.OptionsPanelInit = function()
    LibAddonMenu2:RegisterAddonPanel("ControllerTweaks", panelData)
    LibAddonMenu2:RegisterOptionControls("ControllerTweaks", options)
end