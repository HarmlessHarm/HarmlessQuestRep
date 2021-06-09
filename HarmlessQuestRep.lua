local addOnName, ns = ...
------ Information -------
-- Author: HarmlessHarm
-- Server: Zandalari Tribe | EU

------ Credits -------
-- I want to give credits to SevenEuros!
-- This addon relies heavily on his/her Rep DB that is bundled with the QuestRep Addon
-- For more information about QuestRep visit: https://www.curseforge.com/wow/addons/questrep
-- I also want to give credits to KindredTwitch
-- The idea of adding tags to the quest log as well as the implementation of it leaded directly
-- to the creation of my AddOn
-- For more information about Quest XP Tracker visit https://www.curseforge.com/wow/addons/quest-xp-tracker


------ ToDo's -------
-- - [V] Fix functionality at level cap
-- - [V] Handle quests that give no REP
-- - [ ] Make Rep visibility toggle
-- - [V] Get REP from current quest log items
-- - [V] Use Slash Commands to indicate how many characters to show
-- - [ ] Handel factions starting with "The"
-- - [ ] Add option to show XP. Take a look at old addon 
-- - [ ] Add option to show Gold reward at max level. conversion rate: 6c per exp


-- - [ ] USE LeatrixPlus quest lvl tag code : LTP:3820
-- - [ ] Add REP to quest tooltips (in chat, on map? needs questie?)
--      - Questie/Modules/Tooltips/Link.lua:27 ItemRefTooltip
--      - Use QuestieLoader to import Tooltip modules and Chat filter
--      - Use the QuestieTooltip to add a line to tooltip



local QRep = CreateFrame("FRAME")

QRep:RegisterEvent("ADDON_LOADED")

SLASH_QREP1 = "/qr"
SLASH_QREP2 = "/qrep"
SLASH_QREP3 = "/questrep"



----------------------------------------------
----------- Rep Questie Tooltips -------------
----------------------------------------------


local function HarmlessQuestRepTooltip(questID_str)
    local questID = tonumber(questID_str)
    local db_item = ns.quest_rep_db[questID]
    if db_item then
        ItemRefTooltip:AddLine(" ", 1, 1, 1, 0)
        ItemRefTooltip:AddLine("Reputation:", 1, 1, 1, 1)
        local textLeft, textRight
        for _, q in ipairs(db_item) do
            ItemRefTooltip:AddDoubleLine(q[1], q[2], 1, 1, 1, 1, 1, 1)
        end
    end
end

-- local HarmlessGameTooltip = function()
--     GameTooltip:AddLine("Harmless Tooltip", 1, 1, 1, nil)
-- end

LoadAddOn("Questie")

if Questie and QuestieLoader then
    local QuestieLink = QuestieLoader:ImportModule("QuestieLink")
    local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
    local QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips");
    
    local oldItemSetHyperlink = ItemRefTooltip.SetHyperlink
    
    -- Use the Questie Code to create a tooltip if a link is a quest
    function ItemRefTooltip:SetHyperlink(link, ...)
        local _, isQuestieLink, questId
        isQuestieLink, questId = string.match(link, "(questie):(%d+):")
        QuestieLink.lastItemRefTooltip = QuestieLink.lastItemRefTooltip or link
        
        if QRepDB.SHOW_TOOLTIP and isQuestieLink and questId then
            Questie:Debug(DEBUG_DEVELOP, "[QuestieTooltips:ItemRefTooltip] SetHyperlink: " .. link)
            ShowUIPanel(ItemRefTooltip)
            ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
            QuestieLink:CreateQuestTooltip(link)
            -- Add Reputation information below the Questie Tooltip
            HarmlessQuestRepTooltip(questId)
            ItemRefTooltip:Show()
    
            -- Clear tooltip if tooltip is open and link is clicked
            local tooltipText = ItemRefTooltipTextLeft1:GetText()
            if QuestieLink.lastItemRefTooltip == tooltipText then
                ItemRefTooltip:Hide()
                QuestieLink.lastItemRefTooltip = ""
                return
            end
    
            QuestieLink.lastItemRefTooltip = tooltipText
            return
        else
            -- Make sure to call the default function so everything that is not Questie can be handled (item links e.g.)
            oldItemSetHyperlink(self, link, ...)
        end
    end

    -- Clears the lastItemRefTooltip on tooltip close
    -- ItemRefTooltip:HookScript("OnTooltipSetItem", _QuestieTooltips.AddItemDataToTooltip)
    ItemRefTooltip:HookScript("OnHide", function(self)
        if (not self.IsForbidden) or (not self:IsForbidden()) then -- do we need this here also
            QuestieLink.lastItemRefTooltip = ""
        end
    end)
end


----------------------------------------------
function QRep:ShowHelp()
    print("Harmless Quest Rep Reward")
    print("- Use /qr tooltip to toggle reputation line in questie quest link tooltips")
    print("- Use /qr taglength [NUM] to set the number of character used to display the faction tag")
    print("- Use /qr taglength 0 to display the entire faction name")
end

function QRep:SlashHandler(input_string)
    if (input_string == "") then
        QRep:ShowHelp()
    else
        -- Split input on space
        args = {}
        for token in string.gmatch(input_string, "[^%s]+") do
            table.insert(args, token)
        end
        if args[1] == "tooltip" or args[1] == "tt" then
            -- toggle tooltip
            QRepDB.SHOW_TOOLTIP = not QRepDB.SHOW_TOOLTIP
            if QRepDB.SHOW_TOOLTIP then
                print("Reputation tooltips enabled")
            else
                print("Reputation tooltips disabled")
            end


        elseif args[1] == "taglength" or args[1] == "tl" then
            local intN = tonumber(args[2]) or nil
            if not (intN == nil) then
                if (intN >= 0) then
                    QRepDB.FACTION_LENGTH = intN
                else
                    QRepDB.FACTION_LENGTH = 0
                end
            else
                print("Invalid tag length")
            end
        elseif args[1] == "help" or args[1] == "h" then
            QRep:ShowHelp()
        else
            print("Invalid arguments")
        end
    end
end

SlashCmdList["QREP"] = function(self)
    QRep:SlashHandler(self)
end

function QRep:ADDON_LOADED(loadedAddOnName)
    -- print("Harmless Quest Rep Reward Loaded")
    if loadedAddOnName == addOnName then
        QRepDB = QRepDB or {}
        if (not QRepDB.FACTION_LENGTH) then
            QRepDB.FACTION_LENGTH = 3
            QRepDB.SHOW_TOOLTIP = true
        end

        QRep:RegisterEvent("QUEST_DETAIL")
        -- QRep:RegisterEvent("QUEST_ACCEPTED")
        -- QRep:RegisterEvent("QUEST_REMOVED")
        -- QRep:RegisterEvent("QUEST_FINISHED")
        QRep:RegisterEvent("QUEST_COMPLETE")
        -- QRep:RegisterEvent("QUEST_PROGRESS")


        hooksecurefunc("QuestLog_Update", function()
            QRep:QuestLog_Update("QuestLog")
        end)

        -- support QuestLogEx
        if QuestLogEx then
            hooksecurefunc("QuestLog_Update", function()
                QRep:QuestLog_Update("QuestLogEx")
            end)
        end
    end
end

local function printQuestRep()

    local questID = GetQuestID()
    local questRep = getQuestRep(questID, false)
    if questRep then 
        print(questRep)
    end
end

function QRep:QUEST_DETAIL()
    -- print("In QUEST_DETAIL")
    printQuestRep()
end

function QRep:QUEST_COMPLETE()
    -- print("In QUEST_COMPLETE")
    printQuestRep()

end

function QRep:QuestLog_Update(addonName)
    -- print("HOI")
    local headerXP = {}
    local header

    if addonName == "QuestLogEx" then
        numQuestsDisplayed = QuestLogEx.db.global.maxQuestsDisplayed
    else
        numQuestsDisplayed = QUESTS_DISPLAYED * 2
    end

    for i=1, numQuestsDisplayed, 1 do
        local questIndex = i + FauxScrollFrame_GetOffset(_G[addonName.."ListScrollFrame"])
        local questLogTitleText, level, questTag, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(questIndex);

        local questTitleTag = _G[addonName.."Title"..i.."Tag"]
        
        -- questTitleTag is sometimes NIL
        if not questTitleTag then return end
        if not questLogTitleText then return end

        local questTitleTagText = questTitleTag:GetText() or ""
        local questNormalText = _G[addonName.."Title"..i.."NormalText"]
        
        if ( isComplete and isComplete < 0 ) then
            questTag = FAILED;
        elseif ( isComplete and isComplete > 0 ) then
            questTag = COMPLETE;
        end

        local questRep = getQuestRep(questID, true)
        if questRep then
            -- questTitleTag:SetText(string.format("%s [%s]", string.sub(questTitleTagText, 2,5), questRep))
            questTitleTag:SetText(string.format("%s [%s]", questTitleTagText, questRep))
        -- else
        --     questTitleTag:SetText(string.format("%s", string.sub(questTitleTagText, 2,5)))
        end

        -- Blizz code for calculating widths
        QuestLogDummyText:SetText("  "..questLogTitleText);
        -- Shrink text to accomdate quest tags without wrapping
        tempWidth = 275 - questTitleTag:GetWidth();
        -- print(tempWidth)
        
        if ( QuestLogDummyText:GetWidth() > tempWidth ) then
            textWidth = tempWidth;
        else
            textWidth = QuestLogDummyText:GetWidth();
        end

        questNormalText:SetWidth(tempWidth); 
        -- if ( questTag ) then
        --     QuestLogDummyText:SetText("  "..questLogTitleText);
        --     -- Shrink text to accomdate quest tags without wrapping
        --     tempWidth = 275 - questTitleTag:GetWidth();
        --     print(tempWidth)
            
        --     if ( QuestLogDummyText:GetWidth() > tempWidth ) then
        --         textWidth = tempWidth;
        --     else
        --         textWidth = QuestLogDummyText:GetWidth();
        --     end

        --     questNormalText:SetWidth(tempWidth); 
        -- else
        --     if ( questNormalText:GetWidth() > 275 ) then
        --         questNormalText:SetWidth(260);
        --     end
        -- end
    end
end

function getQuestRep(questID, compact)
    local questRep = nil
    local db_item = ns.quest_rep_db[questID]
    if db_item then
        for i, q in ipairs(db_item) do
            if (compact) then
                if (QRepDB.FACTION_LENGTH and QRepDB.FACTION_LENGTH > 0) then 
                    questRep = string.sub(q[1], 1, QRepDB.FACTION_LENGTH)
                else
                    questRep = q[1]
                end

                if (i > 1) then 
                    questRep = questRep.."+"
                    break
                end
            else
                if (i > 1) then
                    questRep = questRep.."\n"..q[1]..": "..q[2]
                else
                    questRep = "Rep Reward:\n"..q[1]..": "..q[2]
                end
            end
        end
    end
    return questRep
end

QRep:SetScript("OnEvent",
    function (self, event, ...)
        if self[event] then
            return self[event](self, ...)
        end
    end
)