local CT = ControllerTweaks

CT.Settings = {
    JunkHotkey = "UI_SHORTCUT_LEFT_STICK"
}

CT.SettingsInit = function()
    CT.Settings = ZO_SavedVars:NewAccountWide(CT.AddonName .. "SavedVariables", 2, nil, CT.Settings)
end