local CT = ControllerTweaks

local Tooltips = {}

local function TooltipUpdate(tooltip, itemLink, name)
    if not TamrielTradeCentrePrice then
        return false
    end

    if not CT.Settings.ShowTTCPrice then
        return false
    end

    local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
    if priceInfo then
        --Add suggested price before the item name
        local style = {
            layoutPrimaryDirection = "right",
            layoutSecondaryDirection = "down",
            widthPercent = 100,
            childSpacing = 10,
            fontSize = "$(GP_34)",
            height = 32,
            fontColorField = GENERAL_COLOR_WHITE,
        }

        local section = tooltip:AcquireSection(style)
        local suggested = priceInfo.SuggestedPrice or priceInfo.Min
        section:AddLine("TTC")
        section:AddLine(ZO_CurrencyControl_FormatCurrency(suggested, true, nil))
        tooltip:AddSection(section)

        --Also call later to add full TTC details to the bottom of the window
        zo_callLater(function()
            local bottomStyle =
            {
                customSpacing = 30,
                childSpacing = 10,
                widthPercent = 100,
                fontColorField = GENERAL_COLOR_OFF_WHITE,
                fontFace = "$(GAMEPAD_LIGHT_FONT)",
            }

            local bottomSection = tooltip:AcquireSection(bottomStyle)
            if(priceInfo.SuggestedPrice) then
                bottomSection:AddLine(string.format("TTC Suggested %s", ZO_CurrencyControl_FormatCurrency(priceInfo.SuggestedPrice, true, nil)))
            else
                bottomSection:AddLine("TTC")
            end
            bottomSection:AddLine(string.format("Min:%s Avg:%s Max:%s", ZO_CurrencyControl_FormatCurrency(priceInfo.Min, true, nil), ZO_CurrencyControl_FormatCurrency(priceInfo.Avg, true, nil), ZO_CurrencyControl_FormatCurrency(priceInfo.Max, true, nil)))
            bottomSection:AddLine(string.format("%s listings", priceInfo.EntryCount))
            tooltip:AddSection(bottomSection)
        end, 0)
    end

    return false
end

function Tooltips:Init()
    ZO_PreHook(GAMEPAD_TOOLTIPS:GetAndInitializeTooltipContainerTip(GAMEPAD_LEFT_TOOLTIP).tooltip, "AddItemTitle", TooltipUpdate)
end

CT.Tooltips = Tooltips