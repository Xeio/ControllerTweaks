local CT = ControllerTweaks

local function Init(event, name)
    if name ~= CT.AddonName then return end
    
    EVENT_MANAGER:UnregisterForEvent(CT.AddonName, EVENT_ADD_ON_LOADED)

    CT.Settings:Init()
    CT.OptionsPanel:Init()
    CT.Inventory:Init()
    CT.Chat:Init()
    CT.Tooltips:Init()
    CT.Mail:Init()
    CT.GroupFinder:Init()
    CT.Provisioning:Init()
    CT.Loot:UpdatePanel()
end

EVENT_MANAGER:RegisterForEvent(CT.AddonName, EVENT_ADD_ON_LOADED, Init)