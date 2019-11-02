local CT = ControllerTweaks

local Mail = {}

local _destroyAllIndex = nil

local function DeleteEmptyMail()
    for mailId in ZO_GetNextMailIdIter do
        local mailData = {}
        ZO_MailInboxShared_PopulateMailData(mailData, mailId)

        local attachmentsCount, attachedMoney, codAmount = GetMailAttachmentInfo(mailId)

        if mailData.isReadInfoReady and attachmentsCount == 0 and attachedMoney == 0 and codAmount == 0 then
            DeleteMail(mailId, false)
            zo_callLater(DeleteEmptyMail, 150)
            return
        end
    end
end

local function UpdateMailHotkeys()
    local mailBinds = MAIL_MANAGER_GAMEPAD.inbox.mainKeybindDescriptor

    if not mailBinds then
        return false
    end

    if not _destroyAllIndex then
        _destroyAllIndex = #mailBinds + 1
        mailBinds[_destroyAllIndex] = {
            name = "Delete empty mail",
            keybind = "UI_SHORTCUT_QUATERNARY",

            visible = function()
                return true
            end,

            callback = function()
                ZO_Dialogs_ShowGamepadDialog("DELETE_MAIL", { callback = DeleteEmptyMail })
            end
        }
    end

    return false
end

function Mail:Init()
    ZO_PreHook(MAIL_MANAGER_GAMEPAD.inbox, "EnterMailList", UpdateMailHotkeys)
end

CT.Mail = Mail