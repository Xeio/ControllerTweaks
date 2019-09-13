local CT = ControllerTweaks

local JUNK_ICON = "EsoUI/Art/Inventory/inventory_tabIcon_junk_up.dds"
local RESEARCH_ICON = "EsoUI/Art/Inventory/Gamepad/gp_inventory_trait_not_researched_icon.dds"
local BIND_NAME = GetString(SI_GAMEPAD_TOGGLE_OPTION) .. " " .. GetString(SI_ITEMFILTERTYPE9)

local function ShowJunkIcons(control, data, selected, reselectingDuringRebuild, enabled, active)
    local statusIndicator = control.statusIndicator
    zo_callLater(function()
        if statusIndicator then
            if data.traitInformation == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED then
                statusIndicator:ClearIcons()
                statusIndicator:AddIcon(RESEARCH_ICON)
                statusIndicator:Show()
            end
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

local _junkHotkeyIndex = nil
local _destroyHotkeyIndex = nil
local _stackAllHotkeyIndex = nil

local function UpdateInventoryHotkeys(descriptor)
    local inventoryBinds = GAMEPAD_INVENTORY.itemFilterKeybindStripDescriptor

    if not inventoryBinds then
        return false
    end

    if not _destroyHotkeyIndex then
        for i, hotkey in ipairs(inventoryBinds) do
            if hotkey.name == GetString(SI_ITEM_ACTION_STACK_ALL) then
                _stackAllHotkeyIndex = i
            end
            if hotkey.name == GetString(SI_ITEM_ACTION_DESTROY) then
                _destroyHotkeyIndex = i
            end
        end
    end

    inventoryBinds[_destroyHotkeyIndex].keybind = CT.Settings.DestroyHotkey
    inventoryBinds[_stackAllHotkeyIndex].keybind = CT.Settings.StackAllHotkey

    if CT.Settings.JunkHotkey == "None" then
        if _junkHotkeyIndex then
            inventoryBinds.remove(_junkHotkeyIndex)
            _junkHotkeyIndex = nil
        end
    else
        if _junkHotkeyIndex then
            --Already created entry, just make sure the hotkey is up to date
            inventoryBinds[_junkHotkeyIndex].keybind = CT.Settings.JunkHotkey
        else
            _junkHotkeyIndex = #inventoryBinds + 1
            inventoryBinds[_junkHotkeyIndex] = {
                name = BIND_NAME,
                keybind = CT.Settings.JunkHotkey,
                order = 1501,
                disabledDuringSceneHiding = true,

                visible = function()
                    local inventorySlot = GAMEPAD_INVENTORY.itemList:GetTargetData()
                    if inventorySlot then
                        local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
                        return bag and index and CanItemBeMarkedAsJunk(bag, index)
                    else
                        return false
                    end
                end,

                callback = ToggleItemJunk
            }
        end
    end


    return false
end

local function AddItemActions()
    if not GAMEPAD_INVENTORY.itemActions or not GAMEPAD_INVENTORY.itemActions.inventorySlot then
        return false
    end

    local bag, index = ZO_Inventory_GetBagAndIndex(GAMEPAD_INVENTORY.itemActions.inventorySlot)
    if not bag or not index then
        return false
    end

    local canBeJunk =  CanItemBeMarkedAsJunk(bag, index)
    if not IsItemJunk(bag, index) and canBeJunk then
        GAMEPAD_INVENTORY.itemActions.slotActions:AddSlotAction(SI_ITEM_ACTION_MARK_AS_JUNK, function() SetItemIsJunk(bag, index, true) end, nil)
    end
    if IsItemJunk(bag, index) then
        GAMEPAD_INVENTORY.itemActions.slotActions:AddSlotAction(SI_ITEM_ACTION_UNMARK_AS_JUNK, function() SetItemIsJunk(bag, index, false) end, nil)
    end
    
    if PersonalAssistant and PersonalAssistant.Junk then
        local itemLink = GetItemLink(bag, index)
        local itemId = GetItemLinkItemId(itemLink)
        local hasPARule = PersonalAssistant.HelperFunctions.isKeyInTable(PersonalAssistant.Junk.SavedVars.Custom.ItemIds, itemId)
        if CanItemBeMarkedAsJunk(bag, index) and not hasPARule then
            GAMEPAD_INVENTORY.itemActions.slotActions:AddSlotAction(SI_PA_SUBMENU_PAJ_MARK_PERM_JUNK, function() PersonalAssistant.Junk.addItemToPermanentJunk(itemLink, bagId, index) end, nil)
        end
        if hasPARule then
            GAMEPAD_INVENTORY.itemActions.slotActions:AddSlotAction(SI_PA_SUBMENU_PAJ_UNMARK_PERM_JUNK, function() PersonalAssistant.Junk.removeItemFromPermanentJunk(itemLink) end, nil)
        end
    end
    
    return false
end

CT.JunkInit = function()
    ZO_PreHook("ZO_SharedGamepadEntry_OnSetup", ShowJunkIcons)
    ZO_PreHook(ZO_GamepadInventory, "SetActiveKeybinds", UpdateInventoryHotkeys)
    ZO_PreHook(ZO_ItemSlotActionsController, "RefreshKeybindStrip", AddItemActions)
end