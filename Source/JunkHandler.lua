local CT = ControllerTweaks

local JUNK_ICON = "EsoUI/Art/Inventory/inventory_tabIcon_junk_up.dds"
local BIND_NAME = GetString(SI_GAMEPAD_TOGGLE_OPTION) .. " " .. GetString(SI_ITEMFILTERTYPE9)

local function ShowJunkIcons(control, data, selected, reselectingDuringRebuild, enabled, active)
    local statusIndicator = control.statusIndicator
    zo_callLater(function()
        if statusIndicator then
            if data.isJunk then
                statusIndicator:ClearIcons()
                statusIndicator:AddIcon(JUNK_ICON)
                statusIndicator:Show()
            end
        end
     end, 1)
    return false
end

local function ToggleItemJunk()
    local targetData = GAMEPAD_INVENTORY.itemList:GetTargetData()
    local bag, index = ZO_Inventory_GetBagAndIndex(targetData)
    SetItemIsJunk(bag, index, not IsItemJunk(bag, index))
end

local junkHotkeyIndex = nil

local function AddToggleJunkKeybind(descriptor)
    local inventoryBinds = GAMEPAD_INVENTORY.itemFilterKeybindStripDescriptor

    if not inventoryBinds then
        return false
    end

    if CT.Settings.JunkHotkey == "None" then
        if junkHotkeyIndex then
            inventoryBinds.remove(junkHotkeyIndex)
            junkHotkeyIndex = nil
        end

        return false
    end

    if junkHotkeyIndex then
        --Already created entry, just make sure the hotkey is up to d ate
        inventoryBinds[junkHotkeyIndex].keybind = CT.Settings.JunkHotkey
        return false
    end

    junkHotkeyIndex = #inventoryBinds + 1
    inventoryBinds[junkHotkeyIndex] = {
        name = BIND_NAME,
        keybind = CT.Settings.JunkHotkey,
        order = 1501,
        disabledDuringSceneHiding = true,

        visible = function()
            local targetData = GAMEPAD_INVENTORY.itemList:GetTargetData()
            if targetData then
                local bag, index = ZO_Inventory_GetBagAndIndex(targetData)
                return IsItemJunk(bag, index) or CanItemBeMarkedAsJunk(bag, index)
            else
                return false
            end
        end,

        callback = ToggleItemJunk
    }

    return false
end

local function AddItemActions()
    if not GAMEPAD_INVENTORY.itemActions.inventorySlot then
        return false
    end

    local bag, index = ZO_Inventory_GetBagAndIndex(GAMEPAD_INVENTORY.itemActions.inventorySlot)
    if not IsItemJunk(bag, index) and CanItemBeMarkedAsJunk(bag, index) then
        GAMEPAD_INVENTORY.itemActions.slotActions:AddSlotAction(SI_ITEM_ACTION_MARK_AS_JUNK, function() SetItemIsJunk(bag, index, true) end, nil)
    end
    if IsItemJunk(bag, index) then
        GAMEPAD_INVENTORY.itemActions.slotActions:AddSlotAction(SI_ITEM_ACTION_UNMARK_AS_JUNK, function() SetItemIsJunk(bag, index, false) end, nil)
    end
    return false
end

CT.JunkInit = function()
    ZO_PreHook("ZO_SharedGamepadEntry_OnSetup", ShowJunkIcons)
    ZO_PreHook(ZO_GamepadInventory, "SetActiveKeybinds", AddToggleJunkKeybind)
    ZO_PreHook(ZO_ItemSlotActionsController, "RefreshKeybindStrip", AddItemActions)
end