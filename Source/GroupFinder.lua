local CT = ControllerTweaks

local GroupFinder = {}

local function FindPledgeQuestForDungeon(dungeonLocation)
    for i = 1, MAX_JOURNAL_QUESTS do
        if IsValidQuestIndex(i) then
            local questName = GetJournalQuestName(i)
            local dungeonRegex = string.gsub(dungeonLocation.rawName, "-", ".")
            dungeonRegex = string.gsub(dungeonRegex, "Caverns ", "C?a?v?e?r?n?s? ?")
            if string.match(questName, dungeonRegex) then
                if not string.match(dungeonLocation.rawName, " I$") or not string.match(questName, "II") then
                    return questName
                end
            end
        end
    end
    return false
end

local function ShowPledgeDungeons()
    if not DUNGEON_FINDER_GAMEPAD:IsShowing() or DUNGEON_FINDER_GAMEPAD.navigationMode ~= 3 then
        return false
    end

    local isSearching = IsCurrentlySearchingForGroup()
    local modes = DUNGEON_FINDER_GAMEPAD.dataManager:GetFilterModeData()
    local lockReasonTextOverride = DUNGEON_FINDER_GAMEPAD:GetGlobalLockText()

    ZO_ACTIVITY_FINDER_ROOT_MANAGER:RebuildSelections( {DUNGEON_FINDER_GAMEPAD.currentSpecificActivityType } )
    local locationData = ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetLocationsData(DUNGEON_FINDER_GAMEPAD.currentSpecificActivityType)

    local function AddLocationEntry(location, overrideName)
        local entryData = ZO_GamepadEntryData:New(location:GetNameGamepad(), DUNGEON_FINDER_GAMEPAD.categoryData.menuIcon)
        entryData.data = location
        entryData.data:SetLockReasonTextOverride(lockReasonTextOverride)
        entryData:SetEnabled(not location:IsLocked() and not isSearching)
        entryData:SetSelected(location:IsSelected())
        entryData:SetText(overrideName)
        DUNGEON_FINDER_GAMEPAD.entryList:AddEntryAtIndex(2, "ZO_GamepadItemSubEntryTemplate", entryData)
    end

    for _, location in ipairs(locationData) do
        if modes:IsEntryTypeVisible(location:GetEntryType()) and not location:HasRewardData() then
            local pledgeQuest = FindPledgeQuestForDungeon(location)
            if pledgeQuest then
                AddLocationEntry(location, pledgeQuest)
            end
        end
    end

    return false
end

function GroupFinder:Init()
    ZO_PreHook(DUNGEON_FINDER_GAMEPAD.entryList, "Commit", ShowPledgeDungeons)
end

CT.GroupFinder = GroupFinder