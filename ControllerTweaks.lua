local CT = ControllerTweaks

local function Init(event, name)
    if name ~= CT.AddonName then return end
    
    EVENT_MANAGER:UnregisterForEvent(CT.AddonName, EVENT_ADD_ON_LOADED)

    CT.SettingsInit()
    CT.OptionsPanelInit()
    CT.JunkInit()
    CT.ChatHandlerInit()
    CT.Loot:UpdatePanel()
end

EVENT_MANAGER:RegisterForEvent(CT.AddonName, EVENT_ADD_ON_LOADED, Init)