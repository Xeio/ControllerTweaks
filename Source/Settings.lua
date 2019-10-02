local CT = ControllerTweaks

CT.Settings = {
    JunkHotkey = "UI_SHORTCUT_RIGHT_STICK",
    StackAllHotkey = "UI_SHORTCUT_LEFT_STICK",
    DestroyHotkey = "UI_SHORTCUT_QUATERNARY",
    ShowTTCPrice = true
}

CT.SettingsInit = function()
    CT.Settings = ZO_SavedVars:NewAccountWide(CT.AddonName .. "SavedVariables", 2, nil, CT.Settings)
end