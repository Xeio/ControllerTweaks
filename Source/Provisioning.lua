local CT = ControllerTweaks

local Provisioning = {}

local showLowLevelOptionKey = nil
local showLowLevel = false

local function HideRecipies(recipeList)
    if showLowLevel then
        return false
    end

    local i = 1
    while i < recipeList:GetNumEntries() do
        local recipe = recipeList:GetEntryData(i):GetDataSource();
        if recipe then
            local itemLink = GetRecipeResultItemLink(recipe.recipeListIndex, recipe.recipeIndex)
            local hasAbility, abilityHeader, abilityDescription, cooldown, hasScaling, minLevel, maxLevel, isChampionPoints, remainingCooldown = GetItemLinkOnUseAbilityInfo(itemLink)
            if hasScaling and maxLevel < 160 then
                local template = recipeList.templateList[i]
                local recipeData = recipeList.dataList[i]
                if template == "ZO_GamepadItemSubEntryTemplateWithHeader" and 
                        i + 1 <= recipeList:GetNumEntries() and 
                        not recipeList.dataList[i + 1].header then
                    recipeList.dataList[i + 1].header = recipeData.header
                    recipeList.templateList[i + 1] = template
                end
                recipeList:RemoveEntry(template, recipeData)
                i = i - 1
            end
        end
        i = i + 1
    end

    return false
end

local function BuildOptions()
    if not showLowLevelOptionKey then
        showLowLevelOptionKey = #GAMEPAD_PROVISIONER.optionDataList + 1
        local newOptionData = ZO_GamepadEntryData:New("Show Low Level Recipes")
        newOptionData:SetDataSource({ optionName = GetString(SI_PROVISIONER_HAVE_SKILLS) })
        newOptionData.currentValue = showLowLevel
        GAMEPAD_PROVISIONER.optionDataList[showLowLevelOptionKey] = newOptionData
    end
end

local function SaveOptions()
    showLowLevel = GAMEPAD_PROVISIONER.optionDataList[showLowLevelOptionKey].currentValue
end

function Provisioning:Init()
    ZO_PreHook(GAMEPAD_PROVISIONER.recipeList, "Commit", HideRecipies)
    ZO_PreHook(GAMEPAD_PROVISIONER, "RefreshOptionList", BuildOptions)
    ZO_PostHook(GAMEPAD_PROVISIONER, "SaveFilters", SaveOptions)
end

CT.Provisioning = Provisioning