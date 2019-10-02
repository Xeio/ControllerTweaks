local CT = ControllerTweaks

local Loot = {}

function Loot:UpdatePanel()
    local anchor = ZO_Anchor:New(LEFT, GuiRoot, LEFT, 0, CT.Settings.LootPanelOffset)
    LOOT_HISTORY_GAMEPAD.lootStream.control:GetParent():ClearAnchors()
    anchor:Set(LOOT_HISTORY_GAMEPAD.lootStream.control:GetParent())
end

CT.Loot = Loot;