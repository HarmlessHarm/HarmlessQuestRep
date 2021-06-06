local addOnName, ns = ...
local factionLength = 3

-- TODOS FOR REPUTATION
-- - [V] Fix functionality at level cap
-- - [V] Handle quests that give no REP
-- - [ ] Make Rep visibility toggle
-- - [V] Get REP from current quest log items
-- - [V] Use Slash Commands to indicate how many characters to show

-- - [ ] USE LeatrixPlus quest lvl tag code : LTP:3820
-- - [ ] Add REP to quest tooltips (in chat, on map? needs questie?)
--      - Questie/Modules/Tooltips/Link.lua:27 ItemRefTooltip



local QRep = CreateFrame("FRAME")
QRep:RegisterEvent("ADDON_LOADED")
-- QRep:RegisterEvent("MODIFIER_STATE_CHANGED")

SLASH_QREP1 = "/qr"
SLASH_QREP2 = "/qrep"
SLASH_QREP3 = "/questrep"

function QRep:SlashHandler(N)
    if (not (N == "")) then
        QRepDB.factionLength = tonumber(N)
        -- QRep:QuestLog_Update("QuestLog")
    else
        print("Harmless Quest Rep Reward")
        print("- Use /qr NUM to set the number of character used to display the faction tag")
        print("- Use /qr 0 to display the entire faction name")
    end
end

SlashCmdList["QREP"] = function(self)
    QRep:SlashHandler(self)
end

function QRep:ADDON_LOADED(loadedAddOnName)
    -- print("Harmless Quest Rep Reward Loaded")
    if loadedAddOnName == addOnName then
        QRepDB = QRepDB or {}
        if (not QRepDB.factionLength) then
            QRepDB.factionLength = 3
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
    if db_item
    then
        for i, q in ipairs(ns.quest_rep_db[questID]) do
            if (compact) then
                if (QRepDB.factionLength and QRepDB.factionLength > 0) then 
                    questRep = string.sub(q[1], 1, QRepDB.factionLength)
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